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

-- ---------- Assignments (for 3 "Python Start" lessons) ----------
-- Cleared and re-inserted by lesson, so this stays re-runnable. NOTE: no
-- 'quiz' seed on this stage — quiz has no engine yet.
DELETE FROM assignments
WHERE lesson_id IN (
    SELECT l.id FROM lessons l
    JOIN modules m ON m.id = l.module_id
    WHERE m.course_id = (SELECT id FROM courses WHERE slug = 'python-start')
);

INSERT INTO assignments (lesson_id, title, description, assignment_type, starter_code, expected_output, points, position, is_published)
VALUES
    (
        (SELECT id FROM lessons WHERE slug = 'pervaya-komanda-print'),
        'Hello, Kazakhstan!',
        'Напиши программу, которая выводит на экран строку "Hello, Kazakhstan!".',
        'code',
        'print("...")',
        'Hello, Kazakhstan!',
        10, 1, TRUE
    ),
    (
        (SELECT id FROM lessons WHERE slug = 'peremennye'),
        'Переменная name',
        'Создай переменную name со своим именем и выведи её значение на экран.',
        'code',
        'name = "..."' || E'\n' || 'print(name)',
        NULL,
        10, 1, TRUE
    ),
    (
        (SELECT id FROM lessons WHERE slug = 'usloviya-if'),
        'Проверка возраста',
        'Напиши простое условие: если переменная age больше или равна 12, выведи "Подросток", иначе — "Ребёнок".',
        'text',
        NULL,
        NULL,
        10, 1, TRUE
    );

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

COMMIT;
