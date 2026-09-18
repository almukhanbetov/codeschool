# STAGE 35G — Teacher, Parent, Notifications & Chat

Продолжение мобильного приложения CodeSchool.kz (Flutter). Реализованы кабинет
преподавателя, кабинет родителя, уведомления (реальный сигнал бэкенда) и чат
поддержки. Все данные — из реальных Go API, ничего не выдумано.

## 1. Кабинет преподавателя — PASS

Экраны (`lib/features/teacher/presentation/`):

| Экран | Файл | API |
|---|---|---|
| Дашборд | `teacher_home_screen.dart` | `GET /teacher/dashboard` |
| Мои группы | `teacher_groups_screen.dart` | `GET /teacher/groups` |
| Группа + список учеников | `teacher_group_detail_screen.dart` | `GET /teacher/groups/:id`, `GET /teacher/groups/:id/students` |
| Карточка ученика (уроки/работы/квизы) | `teacher_student_detail_screen.dart` | `GET /teacher/groups/:id/students/:studentId` |
| Очередь на проверку (с фильтром по статусу) | `teacher_submissions_screen.dart` | `GET /teacher/submissions?status=` |
| Просмотр решения + выставление оценки | `teacher_submission_detail_screen.dart` | `GET /teacher/submissions/:id`, `POST .../start-review`, `POST .../review` |
| Teacher Academy (дашборд + каталог + запись) | `teacher_academy/presentation/academy_screen.dart` | `GET /teacher-academy/dashboard`, `GET /teacher-academy/courses`, `POST /teacher-academy/courses/:id/enroll` |

Ничего не выдумано: маршруты взяты дословно из `backend/internal/groups/routes.go` и
`backend/internal/academy/routes.go`. Открытие "submitted"-решения автоматически
вызывает `start-review` (submitted → checking, реальный бэкенд-лок), форма оценки
вызывает `review` с `score`/`feedback`/`status` ('passed'/'failed').

**Ограничение (задокументировано, не подделано):** "Teacher Academy" на бэкенде —
это тот же студенческий флоу уроков/квизов/code-runner, перемонтированный под
`/teacher-academy`. Эта стадия реализует каталог/дашборд/запись (собственный новый
функционал), но не переиспользует существующие экраны урока/квиза/code-runner под
этим префиксом — это потребовало бы делать каждый provider в тех фичах
prefix-aware (сквозное изменение), что не было сделано в рамках Stage 35G.
Отражено строкой `teacher.academy.lessonFlowNote` в интерфейсе.

## 2. Родительский кабинет — PASS (кроме сертификатов — см. ниже)

Экраны (`lib/features/parent/presentation/`):

| Экран | Файл | API |
|---|---|---|
| Список детей | `parent_home_screen.dart` | `GET /parent/children` |
| Прогресс ребёнка по курсам | `child_overview_screen.dart` | `GET /parent/children/:id` |
| Задания/квизы по курсу | `child_course_detail_screen.dart` | `GET /parent/children/:id/courses/:courseId` |
| Лента активности | `child_activity_screen.dart` | `GET /parent/children/:id/activity` |

Родитель видит **только своих** детей: список ID никогда не передаётся с клиента —
`GET /parent/children` берёт `parentID` из JWT (`authctx.UserID(c)`); все
per-child маршруты защищены `requireLinked(parentID, childID)` на бэкенде
(`backend/internal/parents/service.go`). Проверено вживую (раздел 6, п. 12).

**Сертификаты ребёнка — BLOCKED (реальное ограничение backend).** Проверены все
публичные методы `certificates.Service` (`Issue`, `ListMine`, `GetMine`,
`PDFForOwner`, `PDFForAdmin`, `Verify`, `AdminList`, `AdminGet`, `Revoke`) — ни
один не принимает "чужой" `userID` от родителя (только владелец или admin). Экран
`ChildOverviewScreen` честно показывает информационную карточку
(`parent.certificatesUnavailable`) вместо выдуманного эндпоинта или тихого
пропуска пункта брифа.

## 3. Уведомления — PASS (реальный сигнал, не выдуманный)

В бэкенде **нет отдельного notifications API** — проверено
`grep -rln "notification" backend/internal --include="*.go" -i` → 0 результатов.
Единственный реальный "уведомительный" сигнал — счётчик непрочитанных сообщений
чата поддержки:

- Счётчик: `GET /support/unread-count` → колокольчик в `AppBar` (`home_screen.dart`,
  `_NotificationsButton`), с бейджем при `threads > 0`.
  Показывается только для student/parent (единственные роли с доступом к чату).
- Список: `GET /support/threads` (та же экранная форма, что и чат — `SupportThreadListScreen`).
- Отметка о прочтении: `POST /support/threads/:id/read`, вызывается при открытии треда.
  (в этом проекте нет отдельно адресуемых "уведомлений", есть только сами треды).
- Переход к связанному событию: у каждого треда есть `about`
  (`studentName`/`courseTitle`/`lessonTitle`/`assignmentName`) — контекст уже
  приходит с бэкенда и показан в шапке треда (`chat.about`).

Честно отражено в интерфейсе строкой `common.notificationsNote`
("There's no separate notifications feed in the API — this is the support
unread-thread counter").

## 4. Чат поддержки — PASS

API существует (`backend/internal/support/routes.go`, `RequireRole("student","parent")`
— учителя намеренно исключены комментарием в самом бэкенде). Экраны
(`lib/features/support_chat/presentation/`):

| Экран | Файл | API |
|---|---|---|
| Список тредов | `support_thread_list_screen.dart` | `GET /support/threads` |
| Переписка | `support_thread_detail_screen.dart` | `GET /support/threads/:id`, `GET .../messages`, `POST .../messages`, `POST .../read` |
| Новое обращение | `support_new_thread_screen.dart` | `POST /support/threads` |

- Статусы загрузки/ошибки: `LoadingView`/`ErrorView` + инлайн-ошибка отправки под
  полем ввода (не блокирует весь экран).
- Обновление переписки: `Timer.periodic` (15 сек) на уровне виджета — намеренно
  **не** в provider-слое, чтобы виджет-тесты могли управлять им явными
  `tester.pump()`, а не зависать на `pumpAndSettle()` (повторяющийся таймер никогда
  не "успокаивается").
- Длинные сообщения: пузырь чата ограничен `78%` ширины экрана
  (`BoxConstraints(maxWidth: ...)`), `SelectableText` переносит текст по словам —
  проверено вживую сообщением на ~280 символов (раздел 6, п. 19).
- Категория треда — только реальные значения из CHECK-constraint миграции 00027
  (`supportThreadCategories`, 11 значений), выбор через `DropdownButtonFormField`.

## 5. Роли и безопасность — PASS

Все проверки — реальные HTTP-запросы к локальному dev-бэкенду
(`docker compose`, порт 8080/5433), не unit-моки. Полный транскрипт в разделе 6.

| Проверка | Результат |
|---|---|
| Parent → не привязанный childId (343) | `404 CHILD_NOT_FOUND` — не 200, данные не утекли |
| Parent → studentId (343) не свой ребёнок в `createThread` | `403 FORBIDDEN` |
| Teacher → несуществующая группа (99999) | `404 GROUP_NOT_FOUND` |
| Teacher → несуществующее submission (99999) | `404 SUBMISSION_NOT_FOUND` |
| Parent token → teacher-эндпоинт (`/teacher/dashboard`) | `403 FORBIDDEN` |
| Teacher token → чат поддержки (`/support/threads`) | `403 FORBIDDEN` (бэкенд явно исключает teacher) |
| Student token → `/teacher-academy/dashboard` | `403 FORBIDDEN` |
| Без токена → любой защищённый эндпоинт | `401 UNAUTHORIZED` |

Чувствительные данные в логах: в новом коде (`teacher/`, `parent/`,
`support_chat/`, `teacher_academy/`) нет ни одного `print`/`debugPrint` —
проверено `grep`. Существующий `LogInterceptor` в `ApiClient` уже отключает
`requestBody`/`responseBody` (см. `api_client.dart`, не менялся в этой стадии).

Production PostgreSQL не затрагивалась — все запросы шли на локальный
docker-compose (`localhost:8080` / `localhost:5433`, dev DB `codeschool`),
с существующими сид-аккаунтами (`teacher@codeschool.local`,
`parent@codeschool.local`, `student@codeschool.local`, пароль `Password123!`
из `backend/seeds/dev_seed_users.sql`). Пользовательские записи production не
менялись.

## 6. Тестирование

### 6.1 Unit / repository-тесты — PASS (20 тестов)

Мокается только `ApiClient` (mocktail), проверяются точные маршруты из реальных
`routes.go`:

- `test/features/teacher/teacher_repository_test.dart` — 6 тестов, включая
  ключевой: `listSubmissions` читает `meta` из **соседнего** поля `ApiOk.meta`
  (бэкенд отдаёт `{"data": items, "meta": {...}}`), а не из середины `data`
  (реальная ошибка, найденная и исправленная до появления тестов — см.
  предыдущую сессию).
- `test/features/parent/parent_repository_test.dart` — 5 тестов, включая
  RBAC-403 от бэкенда, проброшенный как есть.
- `test/features/support_chat/support_repository_test.dart` — 5 тестов.
- `test/features/teacher_academy/academy_repository_test.dart` — 4 теста,
  включая переиспользование существующей модели `Enrollment`.

### 6.2 Widget-тесты — PASS (5 тестов)

- `test/features/teacher/teacher_home_screen_test.dart` — реальные цифры
  дашборда, бейдж непрочитанных на быстрой ссылке.
- `test/features/parent/parent_home_screen_test.dart` — пустое состояние и
  список реальных детей.
- `test/features/support_chat/support_thread_list_screen_test.dart` —
  "недоступно для роли" (teacher), пустое состояние, реальные треды с
  бейджем непрочитанных.

### 6.3 Полный прогон — PASS

```
flutter analyze   → No issues found!
flutter test      → 00:18 +116: All tests passed!  (116/116, весь проект)
flutter build apk --debug → ✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

### 6.4 Устройство — NOT TESTED

`flutter devices` / `adb devices`: только `linux`, `chrome` — физический/
эмулированный Android-девайс не подключён (то же ограничение среды, что и во
всех предыдущих стадиях). APK собран и готов к установке, но приложение не
запускалось на реальном/виртуальном Android-устройстве.

### 6.5 E2E-сценарий против локального dev-бэкенда — PASS

Все запросы — реальный HTTP к `http://localhost:8080/api/v1` (docker-compose,
не production), сид-аккаунты `teacher@codeschool.local` / `parent@codeschool.local`.

1. `POST /auth/login` (teacher, parent) → токены получены.
2. `GET /teacher/dashboard` → `{groupsCount:1, studentsCount:2, pendingSubmissions:1, reviewedSubmissions:0}`.
3. `GET /teacher/groups` → группа "Python Kids — Group 01" (id=1, 2 ученика, 50% прогресс).
4. `GET /teacher/groups/1` + `GET /teacher/groups/1/students` → Ayan (100%), Dana (0%, 1 работа на проверке).
5. `GET /teacher/submissions` → submission id=39 (Dana, статус `submitted`).
6. `GET /teacher/submissions/39` → полный ответ (answer, assignment, lesson, module, group).
7. `POST /teacher/submissions/39/start-review` → статус `submitted → checking`.
8. `POST /teacher/submissions/39/review` `{score:8, feedback:"...", status:"passed"}` → статус `checking → passed`, `checkedAt` проставлен.
9. `GET /parent/children` → 3 привязанных ребёнка (Ayan, Dana, Demo Student).
10. `GET /parent/children/3` → курс "Python Start", 100%.
11. `GET /parent/children/17/activity` → событие `assignment_passed` с **тем же** score=8 и `checkedAt`, что подтверждает, что оценка учителя реально видна родителю (сквозная проверка потока данных).
12–15, 21, 26 — проверки безопасности (см. раздел 5, все PASS).
16. `GET /support/unread-count` → `{threads:0, messages:0}`.
17. `POST /support/threads` (parent, category=`parent_question`, `studentId:17`) → тред создан, `about.studentName = "Dana Student"` (бэкенд сам разрешил контекст).
18. `GET /support/threads` → тред виден в списке.
19. `POST /support/threads/17/messages` с сообщением ~280 символов → сохранено полностью, без обрезки.
20. `POST /support/threads/17/read` → `{"ok":true}`.
24–25. `GET /teacher-academy/dashboard` + `/courses` → реальный академический курс "Методика преподавания Python" (100% завершён, уже есть запись).

Тестовые данные (submission id=39 → passed, новый support-тред id=17) остались в
dev-БД как часть сценария — это тот же локальный docker-compose, что использовали
предыдущие стадии (там уже есть их тестовые аккаунты/сущности), production не
затронут.

## 7. Итоговая таблица

| Раздел брифа | Статус |
|---|---|
| §1 Кабинет преподавателя | PASS |
| §2 Родительский кабинет | PASS (сертификаты ребёнка — BLOCKED, backend-ограничение, честно отражено в UI) |
| §3 Уведомления | PASS (реальный сигнал — счётчик непрочитанных чата, отдельного API нет) |
| §4 Чат поддержки | PASS |
| §5 Роли и безопасность | PASS (8 реальных проверок против dev-бэкенда) |
| §6 Тестирование — analyze/test/build apk | PASS |
| §6 Тестирование — устройство | NOT TESTED (нет подключённого Android) |
| §6 Тестирование — E2E сценарий | PASS |

## 8. Изменённые/новые файлы

**Модели:** `lib/shared/models/{teacher,parent,support,academy}.dart`

**Данные:** `lib/features/{teacher,parent,support_chat,teacher_academy}/data/*_repository.dart`

**Провайдеры:** `lib/features/{teacher,parent,support_chat,teacher_academy}/application/*_providers.dart`

**Экраны (новые в этой сессии):**
- `lib/features/teacher/presentation/{teacher_home_screen,teacher_groups_screen,teacher_group_detail_screen,teacher_student_detail_screen,teacher_submissions_screen,teacher_submission_detail_screen}.dart`
- `lib/features/parent/presentation/{parent_home_screen,child_overview_screen,child_course_detail_screen,child_activity_screen}.dart`
- `lib/features/support_chat/presentation/{support_thread_list_screen,support_thread_detail_screen,support_new_thread_screen}.dart`
- `lib/features/teacher_academy/presentation/academy_screen.dart`

**Роутинг:** `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart` — новые маршруты для всех экранов выше.

**Домашний экран:** `lib/features/home/presentation/home_screen.dart` — диспетчеризация по роли (teacher/parent теперь реальные кабинеты вместо заглушки) + кнопка уведомлений.

**Локализация:** `lib/core/l10n/translations_{ru,kz,en}.dart` — ключи `teacher.*`, `parent.*`, `chat.*`, `home.teacher.*`, `home.parent.*`, `common.notifications*`.

**Тесты (новые):**
- `test/features/teacher/{teacher_repository_test,teacher_home_screen_test}.dart`
- `test/features/parent/{parent_repository_test,parent_home_screen_test}.dart`
- `test/features/support_chat/{support_repository_test,support_thread_list_screen_test}.dart`
- `test/features/teacher_academy/academy_repository_test.dart`

## 9. Ошибки, найденные и исправленные

**`TeacherRepository.listSubmissions` — неверное чтение `meta`.** Изначально код
предполагал, что бэкенд вкладывает `{items, meta}` внутрь `data`. Перечитав
`backend/internal/groups/handler.go` (`c.JSON(http.StatusOK, gin.H{"data": items,
"meta": meta})`), обнаружил, что `meta` — это **соседнее** поле, а не вложенное.
Исправлено до первого запуска теста (self-review против реального Go-кода), затем
закреплено регрессионным тестом
`listSubmissions reads meta from the sibling ApiOk.meta field, not from inside data`.

**Виджет-тест `TeacherHomeScreen` — бейдж не находился.** Второй `_QuickLink`
(submissions) оказывался за пределами дефолтного тестового вьюпорта 600px
(GridView со статистикой съедает первую половину экрана). Исправлено увеличением
тестовой поверхности (`tester.view.physicalSize = Size(800, 2000)`), не изменением
самого экрана — реального бага в UI не было, слой был просто ниже "фолда" в узком
тестовом окне.

## 10. Ограничения

1. Сертификаты ребёнка для родителя — backend не предоставляет такой API (см. §2).
2. "Teacher Academy" — только каталог/дашборд/запись; прохождение урока внутри
   академии переиспользует студенческий бэкенд-флоу, но не студенческие
   Flutter-экраны (см. §1) — задокументировано, не является багом.
3. Устройство Android не подключено — визуальная/тактильная проверка на реальном
   телефоне не выполнена (NOT TESTED), только сборка debug APK и headless-тесты.
4. Опрос новых сообщений в чате — polling (15 сек), не WebSocket/push — в
   бэкенде нет real-time инфраструктуры для этого (как и в брифе §3 указано не
   реализовывать push без подтверждённой инфраструктуры).

---

git push, деплой или публикация приложения не выполнялись — ожидают отдельного разрешения.
