-- ===========================================================================
-- DEMO LEARNING FLOW — content seed (development only, never run in production)
--
--   psql "$DATABASE_URL" -f seeds/demo_learning.sql
--
-- Creates ONE complete, realistic student learning scenario end to end:
--   login → open course → enrol → study lessons → pass quiz → pass code task
--   → pass final exam → course 100% → certificate eligible → issue → verify.
--
-- This seed creates CONTENT ONLY. It does NOT enrol the demo student, create
-- lesson progress, quiz attempts, code runs or a certificate — you walk the
-- flow yourself (see README "Demo learning flow"). Reset the demo student's
-- learning state any time with seeds/reset_demo_learning.sql.
--
-- Reuses the existing engine unchanged: programs / levels / courses / modules
-- / lessons / assignments / quiz_settings / quiz_questions / quiz_options /
-- assignment_tests. No parallel systems.
--
-- Idempotent: the program / level / course rows upsert by slug; the module
-- tree is built only on the first run (guarded by "has modules?") so a
-- re-run never disturbs a mid-walkthrough demo student.
-- ===========================================================================

BEGIN;

-- ---------- Program: "Программирование для детей" ----------
INSERT INTO programs (title, slug, description, age_from, age_to, is_active)
VALUES (
    'Программирование для детей',
    'programming-for-kids',
    'Учебная программа по программированию для детей и подростков: от первой программы до собственных проектов.',
    8, 16, TRUE
)
ON CONFLICT (slug) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    age_from = EXCLUDED.age_from,
    age_to = EXCLUDED.age_to,
    is_active = TRUE,
    updated_at = NOW();

-- ---------- Level: "Начальный" (insert-if-absent, no natural key) ----------
INSERT INTO levels (program_id, title, description, age_from, age_to, position)
SELECT p.id, 'Начальный', 'Первая ступень: основы Python на практике.', 8, 16, 1
FROM programs p
WHERE p.slug = 'programming-for-kids'
  AND NOT EXISTS (
      SELECT 1 FROM levels WHERE program_id = p.id AND title = 'Начальный'
  );

-- ---------- Course: "python-demo-course" ----------
INSERT INTO courses (
    level_id, title, slug, description, short_description,
    age_from, age_to, duration_lessons, projects_count, difficulty,
    audience, is_published, position
)
VALUES (
    (SELECT l.id FROM levels l JOIN programs p ON p.id = l.program_id
        WHERE p.slug = 'programming-for-kids' AND l.title = 'Начальный'),
    'Python с нуля — демонстрационный курс',
    'python-demo-course',
    E'Демонстрационный курс для сквозного теста платформы: текстовые уроки, проверочный квиз, задание на код с автопроверкой и финальный экзамен. После прохождения курс достигает 100 %, и становится доступен сертификат.\n\nKZ: Python нөлден — демонстрациялық курс\nEN: Python from Zero — Demo Course',
    'Полный демо-путь ученика: уроки → квиз → код → финальный экзамен → сертификат.',
    10, 14, 9, 1, 'beginner',
    'student', TRUE, 10
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
    audience = EXCLUDED.audience,
    is_published = EXCLUDED.is_published,
    updated_at = NOW();

-- ---------- Content: modules / lessons / assignments / quiz / tests ----------
-- Built only once. A re-run with the tree already present is a no-op, so it
-- never cascade-deletes a demo student's in-progress attempts.
DO $demo$
DECLARE
    cid BIGINT;
    m1 BIGINT; m2 BIGINT; m3 BIGINT;
    les BIGINT; aid BIGINT; qid BIGINT;
BEGIN
    SELECT id INTO cid FROM courses WHERE slug = 'python-demo-course';

    IF EXISTS (SELECT 1 FROM modules WHERE course_id = cid) THEN
        RAISE NOTICE 'demo_learning: course content already present — skipping content build';
        RETURN;
    END IF;

    -- ===== MODULE 1 — Основы Python =====
    INSERT INTO modules (course_id, title, description, position)
    VALUES (cid, 'Основы Python', 'Что такое программа, вывод на экран и переменные.', 1)
    RETURNING id INTO m1;

    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published) VALUES
    (m1, 'Что такое программа', 'demo-what-is-program',
     'Разбираемся, что такое программа и как компьютер выполняет команды.',
     E'Программа — это список команд, которые компьютер выполняет по порядку, сверху вниз.\n\nМы пишем команды на языке Python, а компьютер их выполняет.',
     'text', 1, TRUE),
    (m1, 'Команда print()', 'demo-print',
     'Первая настоящая команда: вывод текста на экран.',
     E'print() выводит текст на экран:\n\n    print("Привет!")\n\nНа экране появится:  Привет!',
     'text', 2, TRUE),
    (m1, 'Переменные', 'demo-variables',
     'Как сохранять данные в переменные и использовать их.',
     E'Переменная — это коробка с подписью, в которую можно положить значение:\n\n    name = "Ayan"\n    age = 11\n\n    print(name)   # Ayan\n    print(age)    # 11\n\nЗначение переменной можно поменять в любой момент.',
     'text', 3, TRUE);

    -- ===== MODULE 2 — Условия и логика =====
    INSERT INTO modules (course_id, title, description, position)
    VALUES (cid, 'Условия и логика', 'Ветвление программы через if и проверочный квиз.', 2)
    RETURNING id INTO m2;

    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published) VALUES
    (m2, 'Условие if', 'demo-if',
     'Как программа принимает решения.',
     E'if проверяет условие. Если оно истинно — выполняется код с отступом:\n\n    age = 11\n    if age >= 10:\n        print("Ты уже большой!")',
     'text', 1, TRUE),
    (m2, 'Практика: сравнения', 'demo-if-practice',
     'Операторы сравнения: ==, !=, >, <, >=, <=.',
     E'==  равно            !=  не равно\n>   больше           <   меньше\n>=  больше или равно  <=  меньше или равно\n\n    x = 5\n    print(x == 5)   # True\n    print(x != 5)   # False\n    print(x > 3)    # True',
     'code', 2, TRUE);

    -- L6 — first quiz (pass 70 %, up to 3 attempts)
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m2, 'Проверка знаний — основы Python', 'demo-quiz-basics',
            'Небольшой тест по print(), переменным и типам данных. Проходной балл — 70 %.',
            NULL, 'quiz', 3, TRUE)
    RETURNING id INTO les;

    INSERT INTO assignments (lesson_id, title, description, assignment_type, points, position, is_published)
    VALUES (les, 'Проверка знаний — основы Python',
            'Тест по основам Python. Проходной балл 70 %, до 3 попыток.',
            'quiz', 0, 1, TRUE)
    RETURNING id INTO aid;

    INSERT INTO quiz_settings (assignment_id, pass_percent, max_attempts, show_correct_answers, show_explanations)
    VALUES (aid, 70, 3, TRUE, TRUE);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Что делает команда print()?', 'single_choice', 2, 1,
            'print() выводит текст (или значение) на экран.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Выводит текст на экран', TRUE, 1),
        (qid, 'Удаляет переменную', FALSE, 2),
        (qid, 'Завершает программу', FALSE, 3);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Python учитывает регистр букв: name и Name — это разные имена?', 'true_false', 2, 2,
            'Да. Python чувствителен к регистру: name, Name и NAME — три разные переменные.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Верно', TRUE, 1),
        (qid, 'Неверно', FALSE, 2);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Какие из перечисленных — допустимые типы данных в Python?', 'multiple_choice', 3, 3,
            'string (строка), integer (целое число) и boolean (True/False) — базовые типы. "television" типом не является.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'string (строка)', TRUE, 1),
        (qid, 'integer (целое число)', TRUE, 2),
        (qid, 'boolean (логический)', TRUE, 3),
        (qid, 'television', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, E'Что выведет код?\n\n    x = 5\n    print(x)', 'single_choice', 2, 4,
            'print(x) печатает значение переменной x, то есть 5.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '5', TRUE, 1),
        (qid, 'x', FALSE, 2),
        (qid, '"5"', FALSE, 3),
        (qid, 'Ошибка', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Как правильно создать переменную name со значением "Аян"?', 'single_choice', 2, 5,
            'Слева имя переменной, потом =, потом значение: name = "Аян".')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'name = "Аян"', TRUE, 1),
        (qid, '"Аян" = name', FALSE, 2),
        (qid, 'var name = "Аян"', FALSE, 3),
        (qid, 'name := "Аян"', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Текст (строку) в Python нужно писать в кавычках.', 'true_false', 2, 6,
            'Да: "Привет" или ''Привет''. Без кавычек Python примет это за имя переменной.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Верно', TRUE, 1),
        (qid, 'Неверно', FALSE, 2);

    -- ===== MODULE 3 — Финальная практика =====
    INSERT INTO modules (course_id, title, description, position)
    VALUES (cid, 'Финальная практика', 'Задание на код с автопроверкой, финальный экзамен и итог.', 3)
    RETURNING id INTO m3;

    -- L7 — code task with visible + hidden tests (auto-graded by the code runner)
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m3, 'Практика: приветствие пользователя', 'demo-code-greeting',
            E'Задание на код. Прочитай имя пользователя и поприветствуй его.\n\nПодсказка:  name = input()  читает строку,  print("Hello, " + name + "!")  выводит приветствие.',
            NULL, 'code', 1, TRUE)
    RETURNING id INTO les;

    INSERT INTO assignments (lesson_id, title, description, assignment_type, starter_code, expected_output, language, points, position, is_published)
    VALUES (les, 'Приветствие пользователя',
            E'Прочитай имя пользователя со стандартного ввода и выведи:  Hello, <имя>!\n\nПример:\n  ввод:   Ayan\n  вывод:  Hello, Ayan!',
            'code', E'name = input()\n', NULL, 'python', 20, 1, TRUE)
    RETURNING id INTO aid;

    INSERT INTO assignment_tests (assignment_id, name, stdin, expected_stdout, is_hidden, weight, position) VALUES
        (aid, 'Пример из условия',     'Ayan', 'Hello, Ayan!', FALSE, 1, 1),
        (aid, 'Скрытый тест: Dana',    'Dana', 'Hello, Dana!', TRUE,  1, 2),
        (aid, 'Скрытый тест: Ali',     'Ali',  'Hello, Ali!',  TRUE,  1, 3);

    -- L8 — FINAL EXAM (separate quiz assignment, pass 80 %, up to 3 attempts)
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m3, 'Финальный тест курса Python', 'demo-final-exam',
            'Итоговый тест по всему курсу. Проходной балл — 80 %. От результата зависит завершение курса и доступ к сертификату.',
            NULL, 'quiz', 2, TRUE)
    RETURNING id INTO les;

    INSERT INTO assignments (lesson_id, title, description, assignment_type, points, position, is_published)
    VALUES (les, 'Финальный тест курса Python',
            'Итоговый экзамен: print, переменные, строки, числа, input, if, операторы сравнения и логика. Проходной балл 80 %, до 3 попыток.',
            'quiz', 0, 1, TRUE)
    RETURNING id INTO aid;

    INSERT INTO quiz_settings (assignment_id, pass_percent, max_attempts, show_correct_answers, show_explanations)
    VALUES (aid, 80, 3, TRUE, TRUE);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, E'Что выведет код?\n\n    x = 5\n    print(x)', 'single_choice', 2, 1, 'print(x) выводит значение x — число 5.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '5', TRUE, 1), (qid, 'x', FALSE, 2), (qid, '"x = 5"', FALSE, 3), (qid, 'ничего', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Какая функция читает ввод пользователя?', 'single_choice', 2, 2, 'input() читает строку, введённую пользователем.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'input()', TRUE, 1), (qid, 'print()', FALSE, 2), (qid, 'read()', FALSE, 3), (qid, 'get()', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, E'Что делает строка?\n\n    if age >= 10:', 'single_choice', 2, 3, 'if проверяет условие «age больше или равно 10».')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Проверяет условие «age больше или равно 10»', TRUE, 1),
        (qid, 'Присваивает age значение 10', FALSE, 2),
        (qid, 'Выводит age на экран', FALSE, 3),
        (qid, 'Повторяет код 10 раз', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Какие из этих значений — числа?', 'multiple_choice', 3, 4, '10 — целое число, 3.14 — дробное. "10" в кавычках — это строка.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '10', TRUE, 1), (qid, '"10"', FALSE, 2), (qid, '3.14', TRUE, 3), (qid, '"привет"', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Что означает оператор ==?', 'single_choice', 2, 5, '== — это сравнение на равенство. = — это присваивание.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Сравнение на равенство', TRUE, 1),
        (qid, 'Присваивание значения', FALSE, 2),
        (qid, '«Не равно»', FALSE, 3),
        (qid, 'Сложение', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, E'Что выведет код?\n\n    print("2" + "3")', 'single_choice', 2, 6, 'Для строк + означает склеивание: "2" + "3" даёт "23".')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '23', TRUE, 1), (qid, '5', FALSE, 2), (qid, '"5"', FALSE, 3), (qid, 'Ошибка', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Запись  age = 11  создаёт переменную age со значением 11.', 'true_false', 2, 7, 'Да: слева имя, справа значение, между ними знак присваивания =.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Верно', TRUE, 1), (qid, 'Неверно', FALSE, 2);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Оператор != означает…', 'single_choice', 2, 8, '!= — это «не равно».')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '«Не равно»', TRUE, 1), (qid, '«Равно»', FALSE, 2), (qid, '«Больше»', FALSE, 3), (qid, '«Меньше или равно»', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Что из этого — операторы сравнения?', 'multiple_choice', 3, 9, '> и == сравнивают значения. + складывает, = присваивает.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '>', TRUE, 1), (qid, '==', TRUE, 2), (qid, '+', FALSE, 3), (qid, '=', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, E'Что выведет код?\n\n    x = 3\n    y = 4\n    print(x + y)', 'single_choice', 2, 10, 'x и y — числа, поэтому + складывает их: 3 + 4 = 7.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, '7', TRUE, 1), (qid, '34', FALSE, 2), (qid, '"7"', FALSE, 3), (qid, 'x + y', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Строки в Python пишут…', 'single_choice', 2, 11, 'Строку заключают в кавычки: "текст" или ''текст''.')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'В кавычках: "..." или ''...''', TRUE, 1),
        (qid, 'Без кавычек', FALSE, 2),
        (qid, 'В квадратных скобках [...]', FALSE, 3),
        (qid, 'После знака #', FALSE, 4);

    INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation)
    VALUES (aid, 'Если условие в if ложно, код внутри if не выполняется.', 'true_false', 2, 12, 'Да: тело if выполняется только когда условие истинно (True).')
    RETURNING id INTO qid;
    INSERT INTO quiz_options (question_id, option_text, is_correct, position) VALUES
        (qid, 'Верно', TRUE, 1), (qid, 'Неверно', FALSE, 2);

    -- L9 — course summary (plain text, no assignment)
    INSERT INTO lessons (module_id, title, slug, description, content, lesson_type, position, is_published)
    VALUES (m3, 'Итог курса', 'demo-summary',
            'Поздравляем! Курс пройден.',
            E'Ты научился:\n  • выводить текст через print()\n  • хранить данные в переменных\n  • принимать решения через if\n  • сравнивать значения\n  • читать ввод пользователя через input()\n\nКурс достиг 100 %. Теперь можно получить сертификат — кнопка «Получить сертификат» в разделе «Мои сертификаты».',
            'text', 3, TRUE);

    RAISE NOTICE 'demo_learning: content built for course % (python-demo-course)', cid;
END
$demo$;

COMMIT;
