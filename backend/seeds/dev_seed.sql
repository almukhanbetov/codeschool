-- Development seed data — NOT run automatically by migrations or in
-- production. Run manually, see backend/README.md:
--   psql "$DATABASE_URL" -f seeds/dev_seed.sql
--
-- Reuses course names/ages already present in frontend/data/courses.ts and
-- translations.ts where they overlap, and adds "Основы алгоритмов" as
-- called for by this stage's seed spec. Safe to re-run: programs/courses
-- upsert by slug, and levels/modules/lessons are cleared and re-inserted
-- for the rows this script owns.

BEGIN;

-- ---------- Program ----------
INSERT INTO programs (title, slug, description, age_from, age_to, is_active)
VALUES (
    'Computer Science Kids',
    'computer-science-kids',
    'Базовая образовательная программа: алгоритмы, Scratch, Python, робототехника, web-разработка и искусственный интеллект.',
    6, 17, TRUE
)
ON CONFLICT (slug) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    age_from = EXCLUDED.age_from,
    age_to = EXCLUDED.age_to,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- ---------- Level ----------
-- Levels have no unique key of their own; match by program + title. This is
-- an insert-if-absent (NOT a delete + re-insert) so that re-running the seed
-- does not CASCADE-delete courses — and, now, the enrollments / progress /
-- submissions that hang off them.
INSERT INTO levels (program_id, title, description, age_from, age_to, position)
SELECT p.id,
       'Level 1 — 7–9 лет',
       'Первая ступень: знакомство с алгоритмическим мышлением и первыми языками программирования.',
       7, 9, 1
FROM programs p
WHERE p.slug = 'computer-science-kids'
  AND NOT EXISTS (
      SELECT 1 FROM levels
      WHERE program_id = p.id AND title = 'Level 1 — 7–9 лет'
  );

UPDATE levels
SET description = 'Первая ступень: знакомство с алгоритмическим мышлением и первыми языками программирования.',
    age_from = 7, age_to = 9, position = 1
WHERE program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')
  AND title = 'Level 1 — 7–9 лет';

-- ---------- Courses ----------
INSERT INTO courses (
    level_id, title, slug, description, short_description, image_url,
    age_from, age_to, duration_lessons, projects_count, difficulty,
    is_published, position
)
VALUES
    (
        (SELECT id FROM levels WHERE title = 'Level 1 — 7–9 лет'
            AND program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')),
        'Основы алгоритмов', 'algorithms-basics',
        'Введение в алгоритмическое мышление через игры и головоломки — без экрана и без кода.',
        'Первые шаги в программировании через логику и алгоритмы.',
        NULL, 7, 9, 16, 6, 'beginner', TRUE, 1
    ),
    (
        (SELECT id FROM levels WHERE title = 'Level 1 — 7–9 лет'
            AND program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')),
        'Scratch Junior', 'scratch-junior',
        'Создание первых интерактивных историй и игр в визуальной среде Scratch.',
        'Визуальное программирование для самых юных.',
        NULL, 8, 10, 20, 10, 'beginner', TRUE, 2
    ),
    (
        (SELECT id FROM levels WHERE title = 'Level 1 — 7–9 лет'
            AND program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')),
        'Python Start', 'python-start',
        'Первый настоящий язык программирования: переменные, условия, циклы и собственные мини-проекты.',
        'Знакомство с Python через практику.',
        NULL, 10, 12, 24, 12, 'beginner', TRUE, 3
    ),
    (
        (SELECT id FROM levels WHERE title = 'Level 1 — 7–9 лет'
            AND program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')),
        'Robotics Arduino', 'robotics-arduino',
        'Сборка и программирование простых устройств на базе Arduino: датчики, моторы, автоматика.',
        'От электроники к работающим устройствам.',
        NULL, 12, 14, 22, 9, 'intermediate', TRUE, 4
    ),
    (
        (SELECT id FROM levels WHERE title = 'Level 1 — 7–9 лет'
            AND program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')),
        'Web Development', 'web-development',
        'Создание собственных сайтов: HTML, CSS, JavaScript и первый персональный проект в интернете.',
        'Первый сайт своими руками.',
        NULL, 12, 14, 28, 14, 'intermediate', TRUE, 5
    ),
    (
        (SELECT id FROM levels WHERE title = 'Level 1 — 7–9 лет'
            AND program_id = (SELECT id FROM programs WHERE slug = 'computer-science-kids')),
        'AI Junior', 'ai-junior',
        'Основы искусственного интеллекта и машинного обучения на практических примерах.',
        'Первые шаги в мире искусственного интеллекта.',
        NULL, 14, 17, 26, 11, 'advanced', TRUE, 6
    )
ON CONFLICT (slug) DO UPDATE SET
    level_id = EXCLUDED.level_id,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    short_description = EXCLUDED.short_description,
    age_from = EXCLUDED.age_from,
    age_to = EXCLUDED.age_to,
    duration_lessons = EXCLUDED.duration_lessons,
    projects_count = EXCLUDED.projects_count,
    difficulty = EXCLUDED.difficulty,
    is_published = EXCLUDED.is_published,
    position = EXCLUDED.position,
    updated_at = NOW();

-- ---------- Modules for "Python Start" ----------
DELETE FROM modules
WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start');

INSERT INTO modules (course_id, title, description, position)
VALUES
    ((SELECT id FROM courses WHERE slug = 'python-start'), 'Первые программы', 'Знакомство с Python и интерпретатором.', 1),
    ((SELECT id FROM courses WHERE slug = 'python-start'), 'Переменные', 'Хранение и изменение данных в программе.', 2),
    ((SELECT id FROM courses WHERE slug = 'python-start'), 'Условия', 'Ветвление программы: if / else.', 3),
    ((SELECT id FROM courses WHERE slug = 'python-start'), 'Циклы', 'Повторение действий: for и while.', 4);

-- ---------- Lessons ----------
DELETE FROM lessons
WHERE module_id IN (
    SELECT id FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start')
);

INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
VALUES
    (
        (SELECT id FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start') AND title = 'Первые программы'),
        'Что такое программа', 'chto-takoe-programma',
        'Разбираемся, что такое программа и как компьютер выполняет код.',
        'Программа — это последовательность команд, которые компьютер выполняет по порядку.',
        'text', 1, TRUE
    ),
    (
        (SELECT id FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start') AND title = 'Первые программы'),
        'Первая команда print()', 'pervaya-komanda-print',
        'Пишем и запускаем самую первую строку кода на Python.',
        'print("Hello, world!") — выводит текст на экран.',
        'code', 2, TRUE
    ),
    (
        (SELECT id FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start') AND title = 'Переменные'),
        'Переменные', 'peremennye',
        'Учимся сохранять данные в переменные и использовать их.',
        'name = "Аружан"' || E'\n' || 'age = 10',
        'text', 1, TRUE
    ),
    (
        (SELECT id FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start') AND title = 'Условия'),
        'Условия if', 'usloviya-if',
        'Учимся принимать решения в коде с помощью if / else.',
        'if age >= 10:' || E'\n' || '    print("Ты уже большой!")',
        'code', 1, TRUE
    ),
    (
        (SELECT id FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'python-start') AND title = 'Циклы'),
        'Цикл for', 'tsikl-for',
        'Учимся повторять действия с помощью цикла for.',
        'for i in range(5):' || E'\n' || '    print(i)',
        'code', 1, TRUE
    );

-- ---------- Assignments (for "Python Start" lessons) ----------
-- Cleared and re-inserted by lesson, so this stays re-runnable. The 'quiz'
-- assignment on "Цикл for" is fleshed out with settings + questions below.
DELETE FROM assignments
WHERE lesson_id IN (
    SELECT l.id FROM lessons l
    JOIN modules m ON m.id = l.module_id
    WHERE m.course_id = (SELECT id FROM courses WHERE slug = 'python-start')
);

INSERT INTO assignments (lesson_id, title, description, assignment_type, starter_code, expected_output, language, points, position, is_published)
VALUES
    (
        (SELECT id FROM lessons WHERE slug = 'pervaya-komanda-print'),
        'Hello, Kazakhstan!',
        'Напиши программу, которая выводит на экран строку "Hello, Kazakhstan!".',
        'code',
        'print("...")',
        'Hello, Kazakhstan!',
        'python',
        10, 1, TRUE
    ),
    (
        (SELECT id FROM lessons WHERE slug = 'peremennye'),
        'Переменная name',
        'Создай переменную name со своим именем и выведи её значение на экран.',
        'code',
        'name = "..."' || E'\n' || 'print(name)',
        NULL,
        'python',
        10, 1, TRUE
    ),
    (
        (SELECT id FROM lessons WHERE slug = 'usloviya-if'),
        'Проверка возраста',
        'Напиши простое условие: если переменная age больше или равна 12, выведи "Подросток", иначе — "Ребёнок".',
        'text',
        NULL,
        NULL,
        NULL,
        10, 1, TRUE
    ),
    (
        (SELECT id FROM lessons WHERE slug = 'tsikl-for'),
        'Тест: Циклы Python',
        'Небольшой тест по циклам for и функции range().',
        'quiz',
        NULL,
        NULL,
        NULL,
        0, 1, TRUE
    );

-- ---------- Code runner seed: I/O tests for "Hello, Kazakhstan!" ----------
-- Cascades off the assignment deleted above, so this re-inserts a fresh set.
INSERT INTO assignment_tests (assignment_id, name, stdin, expected_stdout, is_hidden, weight, position)
SELECT a.id, 'Печатает приветствие', '', 'Hello, Kazakhstan!', FALSE, 1, 1
FROM assignments a JOIN lessons l ON l.id = a.lesson_id AND l.slug = 'pervaya-komanda-print'
WHERE a.assignment_type = 'code';

INSERT INTO assignment_tests (assignment_id, name, stdin, expected_stdout, is_hidden, weight, position)
SELECT a.id, 'Точное совпадение (скрытый)', '', 'Hello, Kazakhstan!', TRUE, 1, 2
FROM assignments a JOIN lessons l ON l.id = a.lesson_id AND l.slug = 'pervaya-komanda-print'
WHERE a.assignment_type = 'code';

-- ---------- Quiz engine seed: "Тест: Циклы Python" ----------
-- quiz_questions / quiz_options / quiz_settings cascade off the assignment
-- deleted above, so this always inserts a fresh set (spec §73, §74).
INSERT INTO quiz_settings (assignment_id, pass_percent, max_attempts, show_correct_answers, show_explanations)
SELECT a.id, 70, NULL, TRUE, TRUE
FROM assignments a
JOIN lessons l ON l.id = a.lesson_id AND l.slug = 'tsikl-for'
WHERE a.assignment_type = 'quiz'
ON CONFLICT (assignment_id) DO UPDATE SET
    pass_percent = EXCLUDED.pass_percent,
    max_attempts = EXCLUDED.max_attempts,
    show_correct_answers = EXCLUDED.show_correct_answers,
    show_explanations = EXCLUDED.show_explanations,
    updated_at = NOW();

DO $quiz$
DECLARE
    aid BIGINT;
    qid BIGINT;
BEGIN
    SELECT a.id INTO aid
    FROM assignments a
    JOIN lessons l ON l.id = a.lesson_id AND l.slug = 'tsikl-for'
    WHERE a.assignment_type = 'quiz';

    IF aid IS NULL THEN
        RETURN;
    END IF;

    -- Q1 — single_choice
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, E'Что выведет код?\n\nfor i in range(3):\n    print(i)', 'single_choice', 2, 1,
            'range(3) даёт числа 0, 1, 2 — цикл печатает их по одному.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '1 2 3', FALSE, 1),
        (qid, '0 1 2', TRUE, 2),
        (qid, '0 1 2 3', FALSE, 3),
        (qid, 'Ошибка', FALSE, 4);

    -- Q2 — single_choice
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Что делает range(3)?', 'single_choice', 2, 2,
            'range(3) — это последовательность 0, 1, 2 (три числа, начиная с нуля).')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Последовательность 1, 2, 3', FALSE, 1),
        (qid, 'Последовательность 0, 1, 2', TRUE, 2),
        (qid, 'Последовательность 0, 1, 2, 3', FALSE, 3);

    -- Q3 — single_choice
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Какое ключевое слово используется для цикла по последовательности?', 'single_choice', 2, 3,
            'Цикл по элементам последовательности в Python пишется через for.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'for', TRUE, 1),
        (qid, 'loop', FALSE, 2),
        (qid, 'foreach', FALSE, 3),
        (qid, 'repeat', FALSE, 4);

    -- Q4 — true_false
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Цикл for может выполнять блок кода несколько раз.', 'true_false', 2, 4,
            'Да — тело цикла повторяется для каждого элемента последовательности.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Верно', TRUE, 1),
        (qid, 'Неверно', FALSE, 2);

    -- Q5 — multiple_choice
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Какие из этих конструкций являются циклами в Python?', 'multiple_choice', 2, 5,
            'Циклы в Python — это for и while. if — это условие, def — объявление функции.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'for', TRUE, 1),
        (qid, 'while', TRUE, 2),
        (qid, 'if', FALSE, 3),
        (qid, 'def', FALSE, 4);
END
$quiz$;

-- ============================================================
-- Teacher Academy — the teacher's own professional learning.
-- Reuses the entire LMS engine; audience = 'teacher' is the only
-- new bit of metadata (migration 00025).
-- ============================================================

INSERT INTO programs (title, slug, description, age_from, age_to, is_active)
VALUES (
    'Teacher Academy',
    'teacher-academy',
    'Подготовка преподавателей программирования: методика, инструменты, безопасность и AI-грамотность.',
    NULL, NULL, TRUE
)
ON CONFLICT (slug) DO UPDATE SET
    title = EXCLUDED.title, description = EXCLUDED.description, is_active = TRUE, updated_at = NOW();

INSERT INTO levels (program_id, title, description, position)
SELECT p.id, 'Основной трек', 'Базовые модули для действующих и будущих преподавателей.', 1
FROM programs p
WHERE p.slug = 'teacher-academy'
  AND NOT EXISTS (SELECT 1 FROM levels WHERE program_id = p.id AND title = 'Основной трек');

INSERT INTO courses (
    level_id, title, slug, description, short_description, image_url,
    age_from, age_to, duration_lessons, projects_count, difficulty,
    audience, is_published, position
)
VALUES (
    (SELECT l.id FROM levels l JOIN programs p ON p.id = l.program_id
        WHERE p.slug = 'teacher-academy' AND l.title = 'Основной трек'),
    'Методика преподавания Python', 'academy-python-methodology',
    'Как объяснять Python детям: от первой программы до работы над ошибками. Методические материалы, квиз, практика кода и разработка плана урока.',
    'Методика преподавания Python для школьников.',
    NULL, NULL, NULL, 6, 1, 'beginner',
    'teacher', TRUE, 1
)
ON CONFLICT (slug) DO UPDATE SET
    level_id = EXCLUDED.level_id,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    short_description = EXCLUDED.short_description,
    difficulty = EXCLUDED.difficulty,
    audience = EXCLUDED.audience,
    is_published = EXCLUDED.is_published,
    position = EXCLUDED.position,
    updated_at = NOW();

-- Modules + lessons + assignments are cleared and rebuilt for this course.
DELETE FROM modules WHERE course_id = (SELECT id FROM courses WHERE slug = 'academy-python-methodology');

DO $academy$
DECLARE
    cid   BIGINT;
    m1 BIGINT; m2 BIGINT; m3 BIGINT;
    les BIGINT;
    aid BIGINT;
    qid BIGINT;
BEGIN
    SELECT id INTO cid FROM courses WHERE slug = 'academy-python-methodology';

    INSERT INTO modules (course_id, title, description, position) VALUES
        (cid, 'Как дети воспринимают программирование', 'Возрастные особенности, язык объяснений, типичные страхи.', 1) RETURNING id INTO m1;
    INSERT INTO modules (course_id, title, description, position) VALUES
        (cid, 'Первые темы Python', 'Первая программа, переменные, условия и циклы через жизненные примеры.', 2) RETURNING id INTO m2;
    INSERT INTO modules (course_id, title, description, position) VALUES
        (cid, 'Практика преподавания', 'Работа над ошибками и разработка собственного урока.', 3) RETURNING id INTO m3;

    -- M1 L1 — text methodology lesson
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m1, 'Как объяснить цикл for ребёнку 9 лет', 'academy-loop-for-kids',
            'Методический разбор: аналогии, ошибки объяснения, проверочные вопросы.',
            E'Цикл — это «повторяй, пока не закончится список».\n\nАналогия: раздать каждому ученику по тетради — «для каждого ученика: дай тетрадь».\n\nЧего избегать: слов «итерация», «инкремент». Сначала действие, потом термин.',
            'text', 1, TRUE);

    -- M1 L2 — quiz assignment
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m1, 'Методика объяснения переменных', 'academy-variables-method',
            'Проверьте себя: как вводить понятие переменной без сложных терминов.', NULL, 'quiz', 2, TRUE)
    RETURNING id INTO les;
    INSERT INTO assignments (lesson_id, title, description, assignment_type, points, position, is_published)
    VALUES (les, 'Квиз: объяснение переменных', 'Короткий тест по методике.', 'quiz', 0, 1, TRUE)
    RETURNING id INTO aid;
    INSERT INTO quiz_settings (assignment_id, pass_percent, show_correct_answers, show_explanations)
    VALUES (aid, 70, TRUE, TRUE);
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'С какой аналогии лучше начинать объяснение переменной?', 'single_choice', 2, 1,
            'Коробка с подписью — простой и наглядный образ хранения значения.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Ячейка памяти по адресу 0x1F', FALSE, 1),
        (qid, 'Коробка с подписью, в которую кладут значение', TRUE, 2),
        (qid, 'Указатель на область кучи', FALSE, 3);
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Что стоит показать сразу после введения переменной?', 'single_choice', 2, 2,
            'Изменение значения делает понятие «живым» и показывает смысл имени.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Как поменять значение переменной', TRUE, 1),
        (qid, 'Типизацию и приведение типов', FALSE, 2),
        (qid, 'Область видимости', FALSE, 3);
    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Термин «переменная» вводим до или после практики?', 'true_false', 2, 3,
            'Сначала ребёнок делает — потом получает название.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'После практики', TRUE, 1),
        (qid, 'До практики', FALSE, 2);

    -- M2 L1 — code assignment (python)
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m2, 'Подготовьте простой пример Python для ученика', 'academy-python-example',
            'Напишите короткую программу-пример, которую покажете на первом уроке.', NULL, 'code', 1, TRUE)
    RETURNING id INTO les;
    INSERT INTO assignments (lesson_id, title, description, assignment_type, starter_code, language, points, position, is_published)
    VALUES (les, 'Пример: приветствие по имени', E'Программа читает имя со стандартного ввода и печатает: Привет, <имя>!',
            'code', E'name = input()\n# допишите вывод', 'python', 10, 1, TRUE)
    RETURNING id INTO aid;
    INSERT INTO assignment_tests (assignment_id, name, stdin, expected_stdout, is_hidden, weight, position) VALUES
        (aid, 'Пример из условия', 'Аружан', 'Привет, Аружан!', FALSE, 1, 1),
        (aid, 'Другое имя (скрытый)', 'Тимур', 'Привет, Тимур!', TRUE, 1, 2);

    -- M3 L1 — text: work over mistakes
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m3, 'Работа над ошибками ученика', 'academy-mistakes',
            'Как реагировать на ошибку: не «неправильно», а «давай посмотрим, что произошло».',
            E'Ошибка — это данные, а не приговор.\n\nАлгоритм: 1) прочитать сообщение вслух вместе; 2) найти строку; 3) спросить «что мы хотели?»; 4) дать ученику самому исправить.',
            'text', 1, TRUE);

    -- M3 L2 — practical teaching assignment (project)
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m3, 'Практическое занятие: план урока', 'academy-lesson-plan',
            'Итоговое задание трека.', NULL, 'project', 2, TRUE)
    RETURNING id INTO les;
    INSERT INTO assignments (lesson_id, title, description, assignment_type, points, position, is_published)
    VALUES (les, 'Подготовьте план 45-минутного урока на тему «Цикл for»',
            E'Оформите план: цель урока, объяснение темы, практическое упражнение для учеников, домашнее задание. Отправьте текстом.',
            'project', 20, 1, TRUE);
END
$academy$;

-- ---------- Enrol the dev teacher in the academy course ----------
INSERT INTO enrollments (student_id, course_id, status)
SELECT u.id, c.id, 'active'
FROM users u
CROSS JOIN courses c
WHERE u.email = 'teacher@codeschool.local' AND u.role = 'teacher'
  AND c.slug = 'academy-python-methodology'
ON CONFLICT (student_id, course_id) WHERE status = 'active' DO NOTHING;

-- ---------- Auto-enrol the dev student in "Python Start" ----------
-- No-op if seeds/dev_seed_users.sql has not been run yet, and idempotent
-- (the partial unique index blocks a second active enrollment).
INSERT INTO enrollments (student_id, course_id, status)
SELECT u.id, c.id, 'active'
FROM users u
CROSS JOIN courses c
WHERE u.email = 'student@codeschool.local'
  AND c.slug = 'python-start'
ON CONFLICT (student_id, course_id) WHERE status = 'active' DO NOTHING;

-- ---------- Teacher group ("Python Kids — Group 01") ----------
-- All of the following no-op cleanly if dev_seed_users.sql has not run yet.
-- Groups have no natural key, so this is match-by (teacher, course, title).
INSERT INTO groups (course_id, teacher_id, title, description, status, max_students)
SELECT c.id, t.id,
       'Python Kids — Group 01',
       'Демо-группа для проверки преподавательского интерфейса.',
       'active', 12
FROM courses c
JOIN users t ON t.email = 'teacher@codeschool.local' AND t.role = 'teacher'
WHERE c.slug = 'python-start'
  AND NOT EXISTS (
    SELECT 1 FROM groups g
    WHERE g.teacher_id = t.id AND g.course_id = c.id AND g.title = 'Python Kids — Group 01'
  );

-- ---------- Group members (+ guaranteed enrollment) ----------
INSERT INTO group_students (group_id, student_id)
SELECT g.id, s.id
FROM groups g
JOIN users t ON t.id = g.teacher_id AND t.email = 'teacher@codeschool.local'
JOIN users s ON s.email IN ('student@codeschool.local', 'student2@codeschool.local')
WHERE g.title = 'Python Kids — Group 01'
ON CONFLICT (group_id, student_id) DO NOTHING;

INSERT INTO enrollments (student_id, course_id, status)
SELECT s.id, g.course_id, 'active'
FROM group_students gs
JOIN groups g ON g.id = gs.group_id AND g.title = 'Python Kids — Group 01'
JOIN users s ON s.id = gs.student_id
ON CONFLICT (student_id, course_id) WHERE status = 'active' DO NOTHING;

-- ---------- One pending submission (for the teacher review queue) ----------
-- student2 submits the "Проверка возраста" text assignment. DO NOTHING keeps
-- any real submission a Student E2E already created.
INSERT INTO submissions (assignment_id, student_id, answer, status, submitted_at)
SELECT a.id, s.id,
       'Если age >= 12, то Подросток, иначе Ребёнок',
       'submitted', NOW()
FROM assignments a
JOIN lessons l ON l.id = a.lesson_id AND l.slug = 'usloviya-if'
JOIN users s ON s.email = 'student2@codeschool.local'
ON CONFLICT (student_id, assignment_id) DO NOTHING;

-- ---------- Parent → children links ----------
-- Bekzat (parent) is linked to both dev students. No-op if dev_seed_users.sql
-- has not run yet; idempotent (composite PK). The role guards make sure the
-- link is always parent → student.
INSERT INTO parent_children (parent_id, child_id)
SELECT p.id, s.id
FROM users p
JOIN users s ON s.email IN ('student@codeschool.local', 'student2@codeschool.local') AND s.role = 'student'
WHERE p.email = 'parent@codeschool.local' AND p.role = 'parent'
ON CONFLICT (parent_id, child_id) DO NOTHING;

COMMIT;
