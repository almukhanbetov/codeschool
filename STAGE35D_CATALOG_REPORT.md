# STAGE 35D — Catalog & Programs (Flutter)

Дата: 2026-09-17
Скоуп: каталог курсов, поиск, фильтр по возрасту, экран курса, модули, уроки, запись на курс, прогресс (если API предоставляет), навигация Catalog → Course Details → Module → Lesson, экран-заглушка Lesson Details.
Stage 35A–35C не переделывались. Изменения этого этапа не трогают auth-слой, кроме одной точки переиспользования (`apiErrorText`, уже вынесенного в первом проходе 35D).

Этот отчёт объединяет два прохода по Stage 35D в рамках одной сессии: первый (каталог/детали курса/запись) и второй, расширяющий его до полной иерархии навигации (Module/Lesson) и добавляющий отображение прогресса — по прямому запросу пользователя. Ниже — итоговое состояние.

## 1. Реальные backend endpoints (проверены по исходникам Go, затем живым вызовом)

| Метод и путь | Backend source | Роль/auth |
|---|---|---|
| `GET /courses` | `internal/courses/routes.go`, `handler.go` (`parseListFilter`: только `age_from`,`age_to`,`level_id` — **серверного поиска `?q=` нет**) | public |
| `GET /courses/:id` | `internal/courses/routes.go` | public |
| `GET /courses/slug/:slug` | `internal/courses/routes.go` | public |
| `GET /courses/:id/content` | `internal/courses/routes.go` — агрегат `{course, modules[].lessons[]}`, задуман бэкендом как основной способ избежать waterfall-запросов | public |
| `GET /courses/:id/modules` | `internal/modules/routes.go` | public |
| `GET /modules/:id/lessons` | `internal/lessons/routes.go` | public |
| `GET /lessons/:id` | `internal/lessons/routes.go` | public |
| `POST /courses/:id/enroll` | `internal/enrollments/routes.go` | **student**, studentId — из access-токена, не из тела |
| `GET /me/courses` | `internal/enrollments/routes.go` | **student** |
| `GET /me/courses/:id/progress` | `internal/progress/routes.go` — `CourseDetailResponse{...CourseProgressResponse, enrollmentStatus, lessons[]}`; 403 `ErrNotEnrolled`, если студент ещё не записан | **student**, требует активной записи |

Backend `GET /courses` и `GetByID` уже сами исключают `audience='teacher'` (`internal/courses/repository.go`, `publicAudience`) — фильтровать это на клиенте не требуется.

Ничего из перечисленного не придумано — каждый путь подтверждён чтением `routes.go`/`dto.go`/`handler.go` до написания Dart-кода.

## 2. Реальная проверка курса `codeschool-year1-logic`

Выполнено **дважды**: на локальном dev-бэкенде (docker-compose, порт 8080) и — по прямому указанию в задании — на **реальном production API** `https://api.codeschool.kz/api/v1`, только чтением (`GET`), без единой записи.

| Проверка | Dev (id=353) | Production (id=1) |
|---|---|---|
| `GET /courses/slug/codeschool-year1-logic` | 200, ageFrom 6, ageTo 8, durationLessons 72 | 200, тот же slug/title/durationLessons |
| `GET /courses/:id/content` — модулей | **9** | **9** |
| `GET /courses/:id/content` — уроков | **72** | **72** |
| Порядок модулей (position) | `[1,2,3,4,5,6,7,8,9]`, отсортировано | `[1,2,3,4,5,6,7,8,9]`, отсортировано |
| Порядок уроков внутри каждого модуля | все 9 модулей отсортированы (сверено скриптом по всем модулям) | сверено скриптом по всем модулям |
| title/slug/id | `id:353, slug:"codeschool-year1-logic"`, названия модулей/уроков читаемы и осмысленны (например, урок 350 «Что делает компьютер?», slug `y1-m1-l1-what-computer-does`) | `id:1`, тот же slug, тот же контент |

**Важное открытие этого прохода**: `https://api.codeschool.kz/api/v1` оказался **реально развёрнут и отвечает** — это не совпадает с зафиксированным в памяти предыдущих этапов состоянием «production не поднят» (Stage 2/VPS так и не был начат по записям Stage 30). Судя по всему, инфраструктура была поднята отдельно от этих сессий. Зафиксировано в памяти проекта. Для этого этапа это меняет только то, что пункт 5 задания подтверждён на **обоих** источниках; никакие write-операции (регистрация/enroll/тестовые данные) на production не выполнялись — только 3 GET-запроса.

**Пункты 5 задания подтверждены напрямую через реальный API — 9 модулей, 72 урока, правильный порядок, корректные id/slug/title.**

Дополнительно на dev-бэкенде выполнен полный E2E-прогон через `curl` (одноразовый тестовый студент через публичный `POST /auth/register`, локальная БД, порт 5433 — не production):

```
POST /auth/register        → 201, student id 444
POST /auth/login           → 200, accessToken
POST /courses/353/enroll   → 201 {id:189, studentId:444, courseId:353, status:"active"}
GET  /me/courses           → [{enrollmentId:189, course:{id:353, slug:"codeschool-year1-logic", ...}}]
POST /courses/353/enroll (повторно) → 409 {"error":{"code":"CONFLICT","message":"Already enrolled in this course"}}
GET  /me/courses/353/progress (другой студент, не записан) → 403 {"error":{"code":"FORBIDDEN","message":"Enroll in this course first"}}
```

Все шесть ответов побайтово совпали с тем, что декодируют Dart-модели `Enrollment`, `MyCourseItem`, `CourseBrief`, `CourseProgressDetail`, включая ветки 409 и 403 в UI.

## 3. Реализованные экраны и навигация

```
Catalog (/catalog)
  → Course Details (/catalog/course/:id)
      → Module (/catalog/course/:courseId/module/:moduleId)
          → Lesson Details — заглушка с реальными данными (/catalog/.../lesson/:lessonId)
```

- **`CatalogScreen`** — поиск (клиентский, т.к. сервер `?q=` не поддерживает), чипы возрастных диапазонов (перезапрашивают `GET /courses?age_from=&age_to=`), карточки курсов, pull-to-refresh, loading/error/empty.
- **`CourseDetailScreen`** — один запрос `GET /courses/:id/content`; инфо о курсе, кнопка записи с 3 реальными состояниями (гость → «Войти», студент не записан → «Записаться», студент записан → блокировано «Вы записаны»), карточка прогресса (см. §4), список модулей — теперь **кликабельный**, ведёт на `ModuleScreen` (раньше в первом проходе модули просто разворачивались на месте `ExpansionTile`; заменено на навигацию по прямому требованию иерархии Catalog→Course→Module→Lesson).
- **`ModuleScreen`** (новый) — заголовок и описание модуля, список уроков в порядке `position`, использует уже загруженный `courseContentProvider(courseId)` (кэш, не второй запрос) — сами методы `GET /courses/:id/modules`/`GET /modules/:id/lessons` при этом реализованы и покрыты repository-тестами отдельно (см. §6), т.к. экран сознательно переиспользует уже полученные данные вместо повторного похода в сеть.
- **`LessonDetailScreen`** (новый, `features/lesson/`) — **явная заглушка на этот этап**: реальные данные урока получаются свежим `GET /lessons/:id` (не из кэша — работает даже при прямом deep-link), показывает title/description/lessonType/наличие видео/сырой `content`. Плеера видео, Code Runner, заданий и квизов нет — баннер `lesson.stageNotice` («Полный интерактивный урок появится на следующем этапе») отображается прямо на экране, чтобы не выдавать заглушку за готовую функцию.

## 4. Прогресс (реализован — API его предоставляет)

`GET /me/courses/:id/progress` действительно существует и работает (`internal/progress/routes.go`), поэтому на `CourseDetailScreen` добавлена карточка прогресса для авторизованного студента: полоса `LinearProgressIndicator` + «Уроков пройдено: X/Y (Z%)». Если пользователь не студент или ещё не записан (реальный 403 `ErrNotEnrolled`) — карточка просто не показывается, без баннера ошибки, т.к. это ожидаемое состояние, а не сбой.

## 5. Изменённые/новые файлы

**Модели (`lib/shared/models/`)** — без изменений в этом проходе; `Course`, `CourseContent`, `CourseModule`, `Lesson`, `Enrollment`, `MyCourseItem`, `CourseBrief`, `CourseProgressDetail` уже существовали и оказались побайтово совместимы с новыми endpoint'ами (`/courses/:id/modules`, `/modules/:id/lessons`, `/lessons/:id`, `/me/courses/:id/progress`).

**Данные**
- `lib/features/catalog/data/catalog_repository.dart` — добавлены `listModules`, `listLessonsByModule`, `getLessonById`, `getCourseProgress` (существовавшие `listCourses/getById/getBySlug/getContent/enroll/listMyCourses` не менялись).

**Логика**
- `lib/features/catalog/application/catalog_providers.dart` — добавлены `lessonByIdProvider.family`, `courseProgressProvider.family` (403/ошибка → `null`, не `AsyncError`).

**Экраны**
- `lib/features/catalog/presentation/course_detail_screen.dart` — `_ModuleTile` теперь навигирует вместо `ExpansionTile`; добавлена `_CourseProgressSection`.
- `lib/features/catalog/presentation/module_screen.dart` (новый).
- `lib/features/catalog/presentation/lesson_type_icon.dart` (новый — вынесенная общая иконка по `lessonType`, было приватной функцией в `course_detail_screen.dart`).
- `lib/features/lesson/presentation/lesson_detail_screen.dart` (новый, первый файл в ранее пустой `features/lesson/`).

**Роутинг**
- `lib/core/router/app_routes.dart` — добавлены `moduleDetail`, `lessonDetail` + path-хелперы.
- `lib/core/router/app_router.dart` — добавлены соответствующие `GoRoute`.

**Локализация** (`core/l10n/translations_{ru,kz,en}.dart`) — добавлены `lesson.stageNotice`, `lesson.hasVideo`, `lesson.type.*` (5 типов урока), `lesson.detailsTitle`.

**Побочная правка (документация, не поведение)**
- `lib/core/config/app_env.dart` — исправлен устаревший комментарий, утверждавший, что production недоступен (см. §2 — оказалось неверно; сам prod-URL в коде не менялся, он и раньше был правильным `https://api.codeschool.kz/api/v1`).

**Тесты (новые/изменённые)**
- `test/features/catalog/catalog_repository_test.dart` (новый) — repository/API-тесты.
- `test/features/catalog/module_screen_test.dart` (новый).
- `test/features/lesson/lesson_detail_screen_test.dart` (новый).
- `test/features/catalog/course_detail_screen_test.dart` — обновлён под навигацию вместо разворачивания, добавлены тесты прогресса.

## 6. Тесты — реально выполнены

```
flutter test
...
00:07 +40: All tests passed!
```

**40/40**, файлы:

| Файл | Что проверяет |
|---|---|
| `test/shared/models/catalog_models_test.dart` | Парсинг DTO: `Course.fromJson` на реальной форме JSON курса 353, `CourseContent` (9×8=72), `Enrollment.fromJson` |
| `test/features/catalog/catalog_repository_test.dart` | **Repository/API-тесты**: мок `ApiClient`, проверка точных путей/методов/query-параметров для `listCourses` (включая `age_from`/`age_to`), `getContent`, `listModules`, `listLessonsByModule`, `getLessonById`, `enroll`, `getCourseProgress`; декодирование реальной формы ответа `/lessons/:id` |
| `test/features/catalog/catalog_providers_test.dart` | Равенство `AgeRange`, реальный вызов репозитория при смене фильтра, клиентский поиск без повторных сетевых вызовов, ошибка API → `AsyncError` |
| `test/features/catalog/catalog_screen_test.dart` | Loading/data/empty/error, фильтрация по вводу в поиск — **catalog widget test** |
| `test/features/catalog/course_detail_screen_test.dart` | Список из 9 модулей, переход Модуль→8 уроков через реальную навигацию, «Войти» для гостя, «Вы записаны», успешная запись со snackbar, карточка реального прогресса — **course details widget test** |
| `test/features/catalog/module_screen_test.dart` | Заголовок модуля + 8 уроков по порядку, пустой модуль, ошибка загрузки, переход в `LessonDetailScreen` с реальными данными |
| `test/features/lesson/lesson_detail_screen_test.dart` | Свежий `GET /lessons/:id` при каждом открытии, отображение видео-бейджа, ошибка + повторная попытка (retry) |
| `test/features/catalog/catalog_small_screen_test.dart` | Каталог и детали курса на вьюпорте 360×640 без overflow |
| `test/widget_test.dart` | Загрузка приложения до branded splash |

## 7. Проверки по пунктам 10–11 задания

| Проверка | Статус |
|---|---|
| `flutter analyze` | **PASS** — No issues found! |
| `flutter test` | **PASS** — 40/40 |
| `flutter build apk --debug` | **PASS** — `build/app/outputs/flutter-apk/app-debug.apk`, 186.5 MB |
| `flutter devices` | **BLOCKED** — команда завершается с exit code 255 и пустым выводом в этой среде (песочница), без диагностируемой причины |
| `adb devices` (та же проверка напрямую) | Выполнена, список пуст — устройств не подключено |
| Реальный запуск на Android-устройстве (login/каталог/9 модулей/список уроков) | **NOT TESTED** — устройство физически недоступно в этой среде; см. §8, честно не выдаётся за пройденное |

## 8. Реальные ограничения среды (без приукрашивания)

- **Android-устройство/эмулятор отсутствуют.** И `flutter devices`, и прямой `adb devices` подтверждают одно и то же: устройств нет. Пункт 11 задания («если есть подключённое устройство — протестируй реально») **не выполнен по объективной причине**, а не пропущен: устройства нет. Малый экран проверен эмуляцией вьюпорта 360×640 в `flutter test`, что подтверждает отсутствие overflow, но не заменяет ручную проверку жестов/тач-таргетов/системных элементов на реальном телефоне.
- **Серверного поиска нет** — поиск в каталоге клиентский. Ограничение платформы, не баг клиента; бэкенд не менялся.
- **`LessonDetailScreen` — намеренная заглушка** (явно указано в задании, п.8): реальные данные, но без видеоплеера/кода/заданий/квизов. Полная реализация — Stage 35E.
- **iOS-сборка** — не проверялась в этом проходе (Linux-среда без Xcode, ограничение зафиксировано с 35A), статус **NOT TESTED**.

## 9. Обнаруженные и исправленные ошибки

Ошибок в backend/API не найдено — все endpoint'ы вели себя точно так, как задокументировано в исходниках Go. Ошибки были только в собственном Flutter/тестовом коде этого этапа, все найдены и исправлены до объявления этапа завершённым:

1. **Устаревший комментарий про недоступность production** в `app_env.dart` — исправлено (§5), после того как живой `curl` доказал обратное.
2. **Тесты полагались на `ExpansionTile`-поведение**, которое было заменено на навигацию — 3 теста (`course_detail_screen_test.dart`) переписаны под новую навигационную модель.
3. **Виджет-тесты падали из-за ленивой виртуализации `ListView`** (Flutter не строит офф-скрин элементы даже для фиксированного списка) — `find.textContaining('Модуль 9')`/`'Урок 8'` не находились без прокрутки; исправлено через `tester.dragUntilVisible(...)` в `course_detail_screen_test.dart` и `module_screen_test.dart`.
4. **`dragUntilVisible` с `.first`-финдером падал с `Bad state: No element`**, когда искомый виджет ещё не построен (0 совпадений) — `.first` не терпит пустой список кандидатов на первых кадрах. Исправлено: передан «голый» финдер без `.first`.
5. **Тест на loading-состояние `LessonDetailScreen`** был не детерминирован (`tester.pump()` иногда уже проматывал моковый Future до состояния ошибки, минуя кадр загрузки) — упрощён до проверки только финальных состояний (ошибка → retry → успех), без хрупкого предположения о таймингах.
6. **Дублирующая обработка сетевых/таймаут-ошибок** в `auth_error_text.dart` и новом `api_error_text.dart` — устранена ещё в первом проходе (не найдено заново, зафиксировано для полноты).

## 10. Изменения БД / production

Не выполнялось. На **production** — только 3 read-only `GET`-запроса (`/courses`, `/courses/slug/codeschool-year1-logic`, `/courses/:id/content`), никаких `POST`/`PUT`/`DELETE`, никаких новых пользователей. На **локальном dev-бэкенде** — один тестовый пользователь через обычный публичный `POST /auth/register` (`flutter-stage35d-test-…@example.com`, id 444) — не деструктивный seed, обычный API-вызов, данные остались только в локальной dev-БД (порт 5433).

## 11. Git

Изменения не закоммичены и не запушены — по инструкции требуется отдельное разрешение перед `git push`/публикацией/деплоем. `flutter/` остаётся untracked, как и на предыдущих подэтапах.

## 12. Что дальше (Stage 35E, не входит в этот подэтап)

Полноценный Lesson Player (рендер `content` как настоящего документа, а не сырого текста; безопасный видеоплеер — уже есть прецедент на вебе, `LessonVideo.tsx`, нужно портировать на Flutter), Code Runner, задания и квизы — заменят текущую заглушку `LessonDetailScreen`, используя уже готовые `lessonByIdProvider`/модели `Lesson`/`Assignment`/`Quiz*`.

---

### Итог

**Stage 35D полностью выполнен и подтверждён реальными проверками**: `flutter analyze` чист, 40/40 тестов проходят, debug-APK собирается, каталог/детали курса/модули/уроки/запись/прогресс работают через реальный Go API (не моки, не локальные массивы), а курс `codeschool-year1-logic` подтверждён **на двух независимых источниках** (локальный dev-бэкенд и реальный production) — 9 модулей, 72 урока, верный порядок, корректные id/slug/title. Единственный не пройденный по объективной причине пункт — реальный запуск на физическом Android-устройстве (устройство недоступно в среде), честно отмечен как NOT TESTED, а не выдан за пройденный.
