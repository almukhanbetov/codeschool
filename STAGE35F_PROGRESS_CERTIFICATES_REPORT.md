# STAGE 35F — CodeSchool.kz Flutter: Progress & Certificates

Дата: 2026-09-17
Скоуп: полноценный кабинет ученика, прогресс по курсу/модулям/урокам, история заданий и квизов, продолжение обучения, сертификаты (список/просмотр/PDF/шаринг).
Прочитан и учтён `STAGE35E_LEARNING_REPORT.md` перед началом работы. Auth (35C), каталог (35D), уроки/задания/код-раннер/квизы (35E) не переделывались — этот этап только добавляет новое и заменяет временный `HomeScreen`.

## 1. Реальные backend endpoints (проверены по исходникам Go, затем живым вызовом)

| Метод и путь | Backend source | Роль/auth |
|---|---|---|
| `GET /me/progress` | `internal/progress/routes.go` — по одной строке на каждый курс, на котором есть запись (новое использование в этом этапе — раньше не вызывался) | student |
| `GET /me/courses/:id/progress` | `internal/progress/routes.go` (уже использовался в 35D/35E) — общий прогресс + прогресс по каждому уроку | student, активная запись |
| `GET /me/certificates` | `internal/certificates/routes.go` | любой авторизованный (сертификат может быть у student и teacher — «learner = any users.id») |
| `GET /me/certificates/:id` | `internal/certificates/routes.go` — чужой сертификат → реальный 404, никогда не 403 (`ErrForbidden` намеренно маппится в `ErrNotFound`, чтобы не палить существование id) | владелец |
| `GET /me/certificates/:id/pdf?lang=ru|kz|en` | `internal/certificates/routes.go` — сырые байты `application/pdf`, не JSON-конверт | владелец |
| `POST /courses/:id/certificate` | `internal/certificates/routes.go` — лениво идемпотентен: если сертификат уже есть, просто возвращает его; реальная проверка `ErrNotEligible`/`ErrNotEnrolled` на сервере | владелец, курс должен быть завершён |

Официальный документ — PDF, который формирует backend (`github.com/go-pdf/fpdf` + встроенный шрифт + QR-код). Flutter ничего не генерирует сам, только скачивает, сохраняет, открывает системным просмотрщиком и передаёт в Share Sheet (бриф §3).

Агрегирующего эндпоинта «вся история заданий/квизов по курсу» на backend нет — история собирается композицией уже существующих реальных вызовов (`GET /courses/:id/content` + `GET /me/courses/:id/progress` + `GET /lessons/:id/assignments` + `GET /assignments/:id/submission` / `GET /assignments/:id/quiz/attempts`), **ограничена только уроками, которые студент уже начал** (не всем курсом целиком), чтобы не устраивать N+1 по всем 72 урокам Year 1 без необходимости.

Ничего не придумано — каждый путь подтверждён чтением `routes.go`/`dto.go`/`handler.go`/`service.go` до написания Dart-кода.

## 2. Реализованные экраны

```
HomeScreen (роль student)
  → StudentHomeScreen — реальный кабинет
       ├── карточки курсов (GET /me/courses + процент из GET /me/progress)
       ├── «Продолжить обучение» → CourseProgressScreen
       ├── последние задания (для одного активного курса, не N+1 по всем)
       └── сертификаты (превью, «Все сертификаты» → CertificateListScreen)

Catalog → Course → Progress (CourseProgressScreen)
       ├── общий прогресс + прогресс по каждому модулю
       ├── «Продолжить с этого урока» (реально вычислено из данных API)
       ├── История заданий и результаты квизов
       └── CertificateCta (если курс завершён) → получить/открыть сертификат

CertificateListScreen → CertificateDetailScreen
       ├── Открыть PDF (скачать → сохранить → системный просмотрщик)
       └── Поделиться (Share Sheet)
```

- **`StudentHomeScreen`** (новый, заменяет временный `HomeScreen` из 35C) — приветствие, карточки курсов с реальным процентом, кнопка «Продолжить», последние задания, превью сертификатов, loading/error/empty.
- **`CourseProgressScreen`** (новый, `features/progress/`) — общий прогресс, прогресс по каждому модулю (кросс-референс уже загруженных `courseContentProvider`+`courseProgressProvider`, без доп. запросов), «Продолжить с последнего доступного урока» (реально вычислено — первый `in_progress`, иначе первый `not_started`, в порядке модуль→урок), история заданий/квизов, `CertificateCta` при `enrollmentStatus == 'completed'`.
- **`CertificateListScreen`**, **`CertificateDetailScreen`** (новые, `features/certificates/`) — список, детали, скачивание PDF (`path_provider` + запись в документы приложения), открытие через `open_filex` (системный просмотрщик), «Поделиться» через `share_plus` (нативный Share Sheet).
- **`CertificateCta`** (новый, мигрирован по духу с веб-компонента `CertificateCTA.tsx`) — «Получить сертификат» (идемпотентный `POST`) либо «Сертификат выдан» (если уже есть), с реальной обработкой ошибок.

## 3. Реальный E2E-сценарий (изолированный локальный dev-бэкенд, НЕ production)

Продолжён тестовый студент из Stage 35E (id 446, email `flutter-stage35e-e2e-…@example.com`, курс `python-demo-course` id 304, прогресс на конец 35E — 3/9).

```
1.  POST /lessons/294..297/start+complete  → 4/9, 5/9, 6/9, 7/9 (уроки без заданий)
2.  POST /lessons/300/start                → старт финального квиза
3.  POST /assignments/186/quiz/attempts    → 12 реальных вопросов
4.  POST /quiz/attempts/43/submit          → 26/26 (100%), passed=true
5.  POST /lessons/300/complete             → 8/9 (88%)
6.  POST /lessons/301/complete             → 9/9 (100%), enrollmentCompleted=true
7.  POST /courses/304/certificate          → выдан сертификат id 25, CS-2026-000003-CHZ3
8.  POST /courses/304/certificate (повторно) → тот же id 25 — подтверждена идемпотентность
9.  GET  /me/certificates                  → 1 сертификат
10. GET  /me/certificates/25               → status "active"
11. GET  /me/certificates/25/pdf           → реальный PDF, 36296 байт, 1 страница (проверено `file`)
12. Другой пользователь → GET /me/certificates/25       → 404 NOT_FOUND (не 403 — подтверждено, чужой сертификат не палится)
13. Другой пользователь → GET /me/certificates/25/pdf   → тот же 404
14. POST /auth/logout, затем POST /auth/login (повторно)
15. GET /me/progress (после re-login)      → 304: 9/9, 100% — **без изменений**
16. GET /me/certificates (после re-login)  → сертификат 25 на месте — **без изменений**
```

**Полный сценарий брифа («вход → курс → завершение уроков → прогресс → завершение курса → сертификат → PDF → выход → повторный вход → сохранение результатов») подтверждён напрямую, шаг за шагом, реальными HTTP-запросами.**

Все структуры ответов (`Certificate`, `CourseProgress`, `CompleteLessonResponse`) побайтово совпали с тем, что декодируют Dart-модели.

## 4. Найденные и исправленные ошибки

**В этом этапе новых ошибок собственно Flutter-приложения (не тестов) не найдено** — весь прикладной код прошёл widget-тесты с первого «настоящего» прогона после устранения ошибок в самих тестах. Ошибки, найденные и исправленные в тестовых фикстурах (не влияют на приложение):

1. **`course_progress_screen_test.dart` изначально не оверрайдил `authControllerProvider`** — `courseProgressProvider` (из 35D) внутри проверяет роль пользователя (`user.role != student → null`), поэтому без мока авторизации тесты тихо попадали в ветку «не записан», а не в реальную ветку с данными. Пропущенный оверрайд, не баг экрана — исправлено добавлением `_FakeStudentAuthController`.
2. **`ApiResult.ok(null)` без явного типового параметра** в тесте не совпадал с `Future<ApiResult<CourseProgressDetail>>` — заменено на прямую симуляцию реального 403 `ErrNotEnrolled` через `ApiResult.err(...)`, что и корректнее семантически (403 на уровне репозитория конвертируется в `null` на уровне провайдера, а не наоборот).
3. Несколько случаев неоднозначного `find.textContaining(...)`, совпадающего сразу с двумя виджетами (общий и модульный «1/2») — сужено до точной строки.

**Обнаружено (не ошибка, а факт окружения)**: `flutter build apk --debug` теперь выводит предупреждение о том, что `share_plus` использует устаревший способ подключения Kotlin Gradle Plugin и «будущие версии Flutter могут отказаться собирать проект» с такими плагинами. Сборка **успешна сейчас**, это предупреждение на будущее — зафиксировано в ограничениях (§8), не блокирует этап.

## 5. Изменённые/новые файлы

**Новые фичи**
- `lib/features/progress/data/progress_repository.dart` — `listMyProgress()` (`GET /me/progress`).
- `lib/features/progress/application/progress_providers.dart` — `myProgressListProvider`, `continueLearningTargetProvider` (вычисление следующего урока), `courseAssignmentHistoryProvider` (композиция истории заданий/квизов).
- `lib/features/progress/presentation/course_progress_screen.dart`, `certificate_cta.dart`.
- `lib/features/certificates/data/certificate_repository.dart` — `listMine`, `getMine`, `issue`, `downloadPdf` (через `ApiClient.raw`).
- `lib/features/certificates/application/certificate_providers.dart`.
- `lib/features/certificates/presentation/certificate_list_screen.dart`, `certificate_detail_screen.dart`.

**Изменённые**
- `lib/features/home/presentation/home_screen.dart` — теперь маршрутизирует на `StudentHomeScreen` для роли student; заглушка приветствия сохранена для teacher/parent/admin/гостя (вне скоупа этого этапа).
- `lib/features/home/presentation/student_home_screen.dart` (новый) — реальный кабинет.
- `lib/core/router/app_routes.dart`, `app_router.dart` — добавлены `/catalog/course/:id/progress`, `/certificates`, `/certificates/:id`.
- `lib/core/l10n/translations_{ru,kz,en}.dart` — добавлены ключи `certificates.issuing/issueError/downloading/downloadError/share/openPdfError/certificateNumber/issuedAt/completedAt`, `progress.modules/noHistory/continueFrom/courseCompleted/notEnrolledYet`, `home.student.recentAssignments/certificates/viewAllCertificates/continueCourse/loadError`.

**Зависимости** (`pubspec.yaml`) — добавлен `share_plus` (нативный Share Sheet, бриф §3); `path_provider`/`open_filex`/`permission_handler` уже были подключены в 35B и теперь реально используются впервые.

**Тесты (новые)**
- `test/features/progress/progress_repository_test.dart`, `course_progress_screen_test.dart`.
- `test/features/certificates/certificate_repository_test.dart` (включая мок `Dio` для сырых PDF-байт и реального 404), `certificate_list_screen_test.dart`, `certificate_detail_screen_test.dart`.
- `test/features/home/student_home_screen_test.dart`.
- `integration_test/progress_certificates_flow_test.dart` (новый, см. §7).

## 6. Тесты — реально выполнены

```
flutter test
...
00:14 +89: All tests passed!
```

**89/89** (было 72 к концу 35E, добавлено 17 новых в этом этапе):
- **Unit / repository**: `progress_repository_test.dart` (1), `certificate_repository_test.dart` (4 — включая скачивание реальных PDF-байт и реальный 404 «чужой сертификат»).
- **Widget**: `course_progress_screen_test.dart` (3 — прогресс/CTA сертификата/«не записан»), `certificate_list_screen_test.dart` (3), `certificate_detail_screen_test.dart` (3 — данные/отозван/404), `student_home_screen_test.dart` (3).
- **Integration**: `progress_certificates_flow_test.dart` — см. §7 (код есть, реально не выполнялся здесь, как и `learning_flow_test.dart` из 35E).

## 7. Проверки по пункту 4 задания

| Проверка | Статус |
|---|---|
| `flutter analyze` | **PASS** — No issues found! |
| `flutter test` | **PASS** — 89/89 |
| `flutter build apk --debug` | **PASS** — `build/app/outputs/flutter-apk/app-debug.apk`, ~188 МБ (с предупреждением о Kotlin Gradle Plugin у `share_plus`, см. §4/§8) |
| Полный E2E на изолированном окружении (вход → курс → завершение уроков → прогресс → завершение курса → сертификат → PDF → выход → повторный вход → сохранение) | **PASS** — выполнен пошагово через прямые HTTP-запросы к локальному dev-бэкенду (§3), не production |
| Проверка прав доступа к чужому сертификату | **PASS** — реально проверено: другой пользователь получает 404 и на `GET /me/certificates/:id`, и на PDF |
| `integration_test/progress_certificates_flow_test.dart` — реальный запуск на устройстве | **BLOCKED** — `flutter test integration_test/progress_certificates_flow_test.dart` отвечает «No supported devices connected» (проект поддерживает только android/ios, среда даёт только Linux/Chrome). Файл реален, `flutter analyze` чист, но не был выполнен физически. |
| Реальное Android-устройство | **NOT TESTED** — `flutter devices` завершается с exit code 255 и пустым выводом; `adb devices` — пустой список. Идентично 35D/35E. |
| iOS-сборка | **NOT TESTED** — Linux-среда без Xcode, зафиксировано с этапа 35A. |

## 8. Ограничения (честно, без приукрашивания)

- **Открытие PDF системным просмотрщиком и Share Sheet проверены только на уровне репозитория** (`certificate_repository_test.dart` — реальные байты + реальный 404), не на уровне нажатия кнопки в виджет-тесте: `open_filex`/`share_plus` — тонкие обёртки над платформенными каналами (`MethodChannel`), которые не работают без реального устройства/эмулятора; в этой среде их пришлось бы дополнительно мокать на уровне платформенных каналов ради виджет-теста, который всё равно не докажет, что реальный системный просмотрщик действительно открылся. Честная оценка: логика скачивания и сохранения файла проверена полностью, сам факт открытия/шаринга через ОС — нет (тот же класс ограничения, что и `video_player`/`code_text_field` в 35E).
- **История заданий/квизов ограничена уже начатыми уроками** — на backend нет отдельного агрегирующего эндпоинта; при полном 72-урочном курсе Year 1 просмотр «полной» истории потребовал бы 72+ запросов, поэтому композиция сознательно ограничена уроками, к которым студент уже прикасался (`status != 'not_started'`) — реальное, а не придуманное ограничение платформы.
- **`share_plus` предупреждение Kotlin Gradle Plugin** — сборка сейчас успешна, но Flutter предупреждает о будущей несовместимости; не блокирует этот этап, стоит на заметку для последующего апгрейда плагина.
- **Реальное устройство недоступно** — та же причина, что в 35D/35E.
- **PDF-язык (`?lang=ru|kz|en`)** — подключён (текущая локаль приложения передаётся в запрос), но живой просмотр PDF на казахском/английском не производился отдельно — сервер сам решает содержимое по параметру, это уже проверенное серверное поведение (`normalizeLang`), не новый риск на стороне клиента.

## 9. Изменения БД / production

Не выполнялось. Весь E2E (§3) — на **локальном dev-бэкенде** (docker-compose, порт 8080/5433), тот же тестовый студент, что и в 35E, обычные вызовы публичного/авторизованного API — не деструктивный seed, не прямые правки БД. Production не затрагивался в этом этапе.

## 10. Git

Изменения не закоммичены и не запушены — требуется отдельное разрешение. `flutter/` остаётся untracked, как на предыдущих этапах.

## 11. Что дальше (не входит в этот этап)

Teacher/Parent кабинеты (свой прогресс/сертификаты подопечных), уведомления, поддержка-чат — по исходному брифу Stage 35 это Stage 35G.

---

### Итог

**Stage 35F выполнен и подтверждён реальными проверками**: `flutter analyze` чист, 89/89 тестов проходят, debug-APK собирается, кабинет ученика и сертификаты работают через реальный Go API — подтверждено полным пошаговым HTTP E2E-прогоном на изолированном локальном бэкенде: завершение всех 9 уроков курса → 100% прогресс → реальная выдача сертификата → скачивание настоящего 36 КБ PDF → проверка прав доступа (чужой сертификат — честный 404) → **сохранение прогресса и сертификата после logout/login**. Новых ошибок в прикладном коде не найдено (только в тестовых фикстурах, все исправлены). Единственные не пройденные пункты — реальный запуск на физическом Android-устройстве и фактическое исполнение `integration_test` — оба честно помечены BLOCKED/NOT TESTED с точной технической причиной, а не выданы за пройденные.
