#!/usr/bin/env python3
"""
End-to-end walkthrough of the seeded demo learning flow (development only).

Drives the REAL public API exactly as the browser would:

  login -> enrol -> complete lessons -> quiz (fail then pass) -> code task
  (fail then pass) -> final exam (fail then pass) -> course 100% ->
  issue certificate (twice: same row) -> download PDF -> public verify.

Prereqs:
  * stack running (docker compose up -d)
  * seeds/dev_seed_users.sql and seeds/demo_learning.sql applied

The script RESETS the demo student's learning state before and after, so it
never permanently mutates the dev seed.

  python3 backend/seeds/demo_e2e.py

Env overrides: API_BASE (default http://localhost:8080/api/v1),
               PSQL (default: docker compose exec -T postgres psql -U codeschool -d codeschool)
"""
import json
import os
import subprocess
import sys

import requests

API = os.environ.get("API_BASE", "http://localhost:8080/api/v1")
PSQL = os.environ.get(
    "PSQL", "docker compose exec -T postgres psql -U codeschool -d codeschool"
).split()
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

EMAIL = "demo.student@codeschool.local"
PASSWORD = "Password123!"
COURSE_SLUG = "python-demo-course"

fails = 0


def check(label, ok, detail=""):
    global fails
    mark = "PASS" if ok else "FAIL"
    if not ok:
        fails += 1
    print(f"  [{mark}] {label}" + (f"  — {detail}" if detail else ""))


def q(sql):
    """Run a single-value / tab-separated SQL query via psql, return rows as lists."""
    out = subprocess.run(
        PSQL + ["-tAF\t", "-c", sql],
        cwd=REPO_ROOT, capture_output=True, text=True, check=True,
    ).stdout.strip()
    return [line.split("\t") for line in out.splitlines() if line]


def run_sql_file(path):
    with open(os.path.join(REPO_ROOT, path)) as f:
        subprocess.run(PSQL, cwd=REPO_ROOT, input=f.read(),
                       capture_output=True, text=True, check=True)


class Client:
    def __init__(self):
        self.s = requests.Session()
        self.token = None

    def _h(self, auth):
        h = {"Content-Type": "application/json"}
        if auth and self.token:
            h["Authorization"] = f"Bearer {self.token}"
        return h

    def post(self, path, body=None, auth=True):
        r = self.s.post(API + path, headers=self._h(auth), data=json.dumps(body or {}))
        return r

    def get(self, path, auth=True):
        return self.s.get(API + path, headers=self._h(auth))


def data(r):
    return r.json().get("data")


def main():
    print(f"API: {API}")
    print("\n=== reset demo learning state (before) ===")
    run_sql_file("backend/seeds/reset_demo_learning.sql")

    c = Client()

    # ---- 1. login ----------------------------------------------------------
    print("\n=== 1. POST /auth/login ===")
    r = c.post("/auth/login", {"email": EMAIL, "password": PASSWORD}, auth=False)
    check("login 200", r.status_code == 200, f"status {r.status_code}")
    c.token = data(r)["accessToken"]
    uid = q(f"SELECT id FROM users WHERE email='{EMAIL}'")[0][0]

    # ---- 2. resolve course + content ------------------------------------------
    course = data(c.get(f"/courses/slug/{COURSE_SLUG}", auth=False))
    cid = course["id"]
    print(f"\n=== course #{cid}  '{course['title']}' ===")
    check("course is published & student audience",
          course["audience"] in ("student", "both"), course["audience"])

    print("DB proof — before enrolment:",
          q(f"SELECT count(*) FROM enrollments WHERE student_id={uid} AND course_id={cid}")[0][0], "enrollment rows")

    # ---- 3. enrol --------------------------------------------------------------
    print("\n=== 2. POST /courses/:id/enroll ===")
    r = c.post(f"/courses/{cid}/enroll")
    check("enroll 201/200", r.status_code in (200, 201), f"status {r.status_code}")
    st = q(f"SELECT status FROM enrollments WHERE student_id={uid} AND course_id={cid}")[0][0]
    check("enrollment.status = active", st == "active", st)

    content = data(c.get(f"/courses/{cid}/content", auth=False))
    lessons = [(m["position"], l["position"], l["id"], l["title"], l["lessonType"])
               for m in content["modules"] for l in m["lessons"]]
    by_title = {t: (lid) for _, _, lid, t, _ in lessons}

    # assignment ids
    quiz_aid = q(f"""SELECT a.id FROM assignments a JOIN lessons l ON l.id=a.lesson_id
                     WHERE l.slug='demo-quiz-basics'""")[0][0]
    code_aid = q(f"""SELECT a.id FROM assignments a JOIN lessons l ON l.id=a.lesson_id
                     WHERE l.slug='demo-code-greeting'""")[0][0]
    exam_aid = q(f"""SELECT a.id FROM assignments a JOIN lessons l ON l.id=a.lesson_id
                     WHERE l.slug='demo-final-exam'""")[0][0]

    # ---- 4. complete the 6 plain text/code lessons --------------------------
    print("\n=== 3. plain lessons: POST /lessons/:id/start + /complete ===")
    plain = ["Что такое программа", "Команда print()", "Переменные",
             "Условие if", "Практика: сравнения"]
    for t in plain:
        lid = by_title[t]
        c.post(f"/lessons/{lid}/start")
        r = c.post(f"/lessons/{lid}/complete")
        check(f"complete '{t}'", r.status_code == 200, f"status {r.status_code}")

    # ---- 5. QUIZ: fail then pass -------------------------------------------
    print("\n=== 4. quiz 'Проверка знаний' — attempt 1 (wrong) ===")
    att = data(c.post(f"/assignments/{quiz_aid}/quiz/attempts"))
    qids = [x["id"] for x in att["quiz"]["questions"]]
    wrong = {int(r[0]): int(r[1]) for r in q(
        f"SELECT question_id, min(id) FROM quiz_options "
        f"WHERE question_id = ANY(ARRAY{qids}) AND is_correct=false GROUP BY question_id")}
    ans = [{"questionId": qid, "selectedOptionIds": [wrong[qid]]} for qid in qids if qid in wrong]
    res = data(c.post(f"/quiz/attempts/{att['attempt']['id']}/submit", {"answers": ans}))
    check("attempt 1 FAILED (<70%)", res["passed"] is False, f"{res['percent']}%")

    print("=== quiz — attempt 2 (correct) ===")
    att = data(c.post(f"/assignments/{quiz_aid}/quiz/attempts"))
    qids = [x["id"] for x in att["quiz"]["questions"]]
    correct = {}
    for r in q(f"SELECT question_id, id FROM quiz_options "
               f"WHERE question_id = ANY(ARRAY{qids}) AND is_correct=true"):
        correct.setdefault(int(r[0]), []).append(int(r[1]))
    ans = [{"questionId": qid, "selectedOptionIds": correct[qid]} for qid in qids]
    res = data(c.post(f"/quiz/attempts/{att['attempt']['id']}/submit", {"answers": ans}))
    check("attempt 2 PASSED (>=70%)", res["passed"] is True, f"{res['percent']}%")
    attempts = q(f"SELECT count(*), bool_or(passed) FROM quiz_attempts WHERE assignment_id={quiz_aid} AND student_id={uid}")[0]
    check("quiz_attempts history kept", attempts[0] == "2", f"{attempts[0]} rows, passed={attempts[1]}")

    lid = by_title["Проверка знаний — основы Python"]
    c.post(f"/lessons/{lid}/start")
    check("complete quiz lesson", c.post(f"/lessons/{lid}/complete").status_code == 200)

    # ---- 6. CODE TASK: fail then pass ------------------------------------
    print("\n=== 5. code task 'Приветствие пользователя' ===")
    r = c.post(f"/assignments/{code_aid}/run", {"code": 'print("Hello")', "stdin": "Ayan"})
    check("free run works", r.status_code == 200, f"status {r.status_code}")
    bad = data(c.post(f"/assignments/{code_aid}/code/submit", {"code": 'print("Hello")'}))
    check("wrong code -> failed", bad["status"] == "failed",
          f"{bad['testsPassed']}/{bad['testsTotal']} tests")
    good = data(c.post(f"/assignments/{code_aid}/code/submit",
                       {"code": 'name = input()\nprint("Hello, " + name + "!")'}))
    check("correct code -> passed (all hidden tests)", good["status"] == "passed",
          f"{good['testsPassed']}/{good['testsTotal']} tests")

    lid = by_title["Практика: приветствие пользователя"]
    c.post(f"/lessons/{lid}/start")
    check("complete code lesson", c.post(f"/lessons/{lid}/complete").status_code == 200)

    # ---- 7. FINAL EXAM: fail (course stays incomplete) then pass -----------
    print("\n=== 6. final exam 'Финальный тест курса Python' ===")
    att = data(c.post(f"/assignments/{exam_aid}/quiz/attempts"))
    qids = [x["id"] for x in att["quiz"]["questions"]]
    wrong = {int(r[0]): int(r[1]) for r in q(
        f"SELECT question_id, min(id) FROM quiz_options "
        f"WHERE question_id = ANY(ARRAY{qids}) AND is_correct=false GROUP BY question_id")}
    ans = [{"questionId": qid, "selectedOptionIds": [wrong[qid]]} for qid in qids if qid in wrong]
    res = data(c.post(f"/quiz/attempts/{att['attempt']['id']}/submit", {"answers": ans}))
    check("exam attempt 1 FAILED (<80%)", res["passed"] is False, f"{res['percent']}%")

    lid = by_title["Финальный тест курса Python"]
    c.post(f"/lessons/{lid}/start")
    r = c.post(f"/lessons/{lid}/complete")
    check("exam lesson NOT completable while failed", r.status_code != 200, f"status {r.status_code}")

    att = data(c.post(f"/assignments/{exam_aid}/quiz/attempts"))
    qids = [x["id"] for x in att["quiz"]["questions"]]
    correct = {}
    for r in q(f"SELECT question_id, id FROM quiz_options "
               f"WHERE question_id = ANY(ARRAY{qids}) AND is_correct=true"):
        correct.setdefault(int(r[0]), []).append(int(r[1]))
    ans = [{"questionId": qid, "selectedOptionIds": correct[qid]} for qid in qids]
    res = data(c.post(f"/quiz/attempts/{att['attempt']['id']}/submit", {"answers": ans}))
    check("exam attempt 2 PASSED (>=80%)", res["passed"] is True, f"{res['percent']}%")
    check("exam lesson now completable", c.post(f"/lessons/{lid}/complete").status_code == 200)

    # ---- 8. summary lesson + course completion --------------------------
    lid = by_title["Итог курса"]
    c.post(f"/lessons/{lid}/start")
    c.post(f"/lessons/{lid}/complete")

    prog = [p for p in data(c.get("/me/progress")) if p["courseId"] == cid][0]
    check("course progress = 100%", prog["progressPercent"] == 100,
          f"{prog['completedLessons']}/{prog['totalLessons']}")
    detail = data(c.get(f"/me/courses/{cid}/progress"))
    check("enrollment auto-completed", detail["enrollmentStatus"] == "completed",
          detail["enrollmentStatus"])

    # ---- 9. certificate: issue once, idempotent -----------------------------
    print("\n=== 7. POST /courses/:id/certificate (issue + idempotency) ===")
    cert1 = data(c.post(f"/courses/{cid}/certificate"))
    cert2 = data(c.post(f"/courses/{cid}/certificate"))
    check("certificate issued", bool(cert1["certificateNumber"]), cert1["certificateNumber"])
    check("re-issue returns SAME certificate", cert1["id"] == cert2["id"] and
          cert1["certificateNumber"] == cert2["certificateNumber"], f"id {cert1['id']}")
    rows = q(f"SELECT count(*) FROM certificates WHERE user_id={uid} AND course_id={cid}")[0][0]
    check("exactly one certificate row", rows == "1", f"{rows} rows")

    # ---- 10. PDF ---------------------------------------------------------------
    pr = c.s.get(API + f"/me/certificates/{cert1['id']}/pdf", headers={"Authorization": f"Bearer {c.token}"})
    check("PDF content-type application/pdf", pr.headers.get("content-type") == "application/pdf",
          pr.headers.get("content-type"))
    check("PDF body is a real PDF", pr.content[:5] == b"%PDF-", f"{len(pr.content)} bytes")

    # ---- 11. public verification (no auth) -------------------------------
    print("\n=== 8. GET /certificates/verify/:code (public, no auth) ===")
    v = data(requests.get(API + f"/certificates/verify/{cert1['verificationCode']}"))
    check("verify valid", v["valid"] is True and v["status"] == "active")
    check("verify learner name", v["learnerName"] == "Demo Student", v["learnerName"])
    check("verify course title", v["courseTitle"] == course["title"], v["courseTitle"])
    check("verify has no private fields",
          not any(k in v for k in ("email", "phone", "userId", "enrollmentId")))

    # ---- DB proof ------------------------------------------------------------
    print("\n=== DB proof (demo student, python-demo-course) ===")
    proof = q(f"""
      SELECT
        (SELECT status FROM enrollments WHERE student_id={uid} AND course_id={cid}),
        (SELECT count(*) FROM lesson_progress lp JOIN lessons l ON l.id=lp.lesson_id
           JOIN modules m ON m.id=l.module_id WHERE lp.student_id={uid} AND m.course_id={cid} AND lp.status='completed'),
        (SELECT count(*) FROM quiz_attempts WHERE student_id={uid}),
        (SELECT count(*) FROM quiz_attempts WHERE student_id={uid} AND passed),
        (SELECT count(*) FROM code_runs WHERE student_id={uid}),
        (SELECT count(*) FROM submissions WHERE student_id={uid} AND status='passed'),
        (SELECT certificate_number FROM certificates WHERE user_id={uid} AND course_id={cid})
    """)[0]
    for lbl, val in zip(
        ["enrollment.status", "completed lessons", "quiz_attempts", "  ...passed",
         "code_runs", "passed submissions", "certificate_number"], proof):
        print(f"  {lbl:22} {val}")

    print("\n=== reset demo learning state (after) ===")
    run_sql_file("backend/seeds/reset_demo_learning.sql")

    print("\n" + ("✅ E2E PASSED" if fails == 0 else f"❌ {fails} FAILURE(S)"))
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
