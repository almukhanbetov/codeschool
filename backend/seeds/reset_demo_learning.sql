-- ===========================================================================
-- RESET the demo student's learning state for "python-demo-course"
-- (development only — never run in production)
--
--   psql "$DATABASE_URL" -f seeds/reset_demo_learning.sql
--
-- Removes ONLY demo.student@codeschool.local's learning state for the demo
-- course, so you can walk the flow again from zero:
--   certificate → quiz attempts (+ answers + selected options) → code runs
--   → submissions → lesson_progress → enrollment.
--
-- Does NOT touch: the course / modules / lessons / assignments / quiz
-- questions / assignment tests, or any real user or other course.
-- ===========================================================================

BEGIN;

DO $reset$
DECLARE
    uid BIGINT;
    cid BIGINT;
BEGIN
    SELECT id INTO uid FROM users  WHERE lower(email) = 'demo.student@codeschool.local';
    SELECT id INTO cid FROM courses WHERE slug = 'python-demo-course';

    IF uid IS NULL OR cid IS NULL THEN
        RAISE NOTICE 'reset_demo_learning: demo student or python-demo-course missing — nothing to do';
        RETURN;
    END IF;

    -- issued certificate for this learner + course
    DELETE FROM certificates
    WHERE user_id = uid AND course_id = cid;

    -- quiz attempts for the demo course's quiz assignments
    -- (quiz_attempt_answers + quiz_attempt_answer_options cascade on delete)
    DELETE FROM quiz_attempts qa
    USING assignments a, lessons l, modules m
    WHERE qa.assignment_id = a.id
      AND l.id = a.lesson_id
      AND m.id = l.module_id
      AND m.course_id = cid
      AND qa.student_id = uid;

    -- code runner history for the demo course's code assignments
    DELETE FROM code_runs cr
    USING assignments a, lessons l, modules m
    WHERE cr.assignment_id = a.id
      AND l.id = a.lesson_id
      AND m.id = l.module_id
      AND m.course_id = cid
      AND cr.student_id = uid;

    -- submissions (text/code) for the demo course's assignments
    DELETE FROM submissions s
    USING assignments a, lessons l, modules m
    WHERE s.assignment_id = a.id
      AND l.id = a.lesson_id
      AND m.id = l.module_id
      AND m.course_id = cid
      AND s.student_id = uid;

    -- lesson progress for the demo course's lessons
    DELETE FROM lesson_progress lp
    USING lessons l, modules m
    WHERE lp.lesson_id = l.id
      AND m.id = l.module_id
      AND m.course_id = cid
      AND lp.student_id = uid;

    -- enrollment (active or completed)
    DELETE FROM enrollments
    WHERE student_id = uid AND course_id = cid;

    RAISE NOTICE 'reset_demo_learning: cleared learning state for user % on course % (python-demo-course)', uid, cid;
END
$reset$;

COMMIT;
