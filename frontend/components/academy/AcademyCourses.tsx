"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { ApiError, enrollTeacherAcademyCourse, getTeacherAcademyCourses } from "@/lib/api";
import type { AcademyCourseCard } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; courses: AcademyCourseCard[] };

export function AcademyCourses() {
  const { t } = useLanguage();
  const a = t.academy;
  const [state, setState] = useState<State>({ kind: "loading" });
  const [pendingId, setPendingId] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setState({ kind: "ready", courses: await getTeacherAcademyCourses() });
    } catch {
      setState({ kind: "error" });
    }
  }, []);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  async function enroll(courseId: number) {
    setPendingId(courseId);
    setError(null);
    try {
      await enrollTeacherAcademyCourse(courseId);
      await load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t.learn.loadError);
    } finally {
      setPendingId(null);
    }
  }

  if (state.kind === "loading") return <Centered>{t.learn.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.learn.loadError}</Centered>;

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{a.navTitle}</span>
            <h1 className="student-dash-title">{a.browseCourses}</h1>
          </div>
          <Link href="/teacher-academy/dashboard" className="student-viewall">
            {a.myLearning}
          </Link>
        </div>

        {error && <p className="auth-error">{error}</p>}

        <div className="learn-modules">
          {state.courses.map((c) => (
            <div className="learn-module academy-course-row" key={c.id}>
              <div className="academy-course-row-head">
                <h3>{c.title}</h3>
                <span className="academy-track-num">
                  {c.totalLessons} {a.lessonsLabel}
                </span>
              </div>
              {(c.shortDescription || c.description) && (
                <p className="assignment-desc">{c.shortDescription ?? c.description}</p>
              )}
              <div className="assignment-actions">
                {c.enrolled ? (
                  <>
                    <span className="academy-cert-tag">✓ {a.enrolled}</span>
                    <Button href={`/teacher-academy/learn/${c.id}`} variant="primary" size="sm">
                      {a.continueLearning}
                    </Button>
                  </>
                ) : (
                  <Button
                    type="button"
                    variant="primary"
                    size="sm"
                    onClick={() => enroll(c.id)}
                    disabled={pendingId === c.id}
                  >
                    {pendingId === c.id ? a.enrolling : a.enroll}
                  </Button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Centered({ children, error }: { children: React.ReactNode; error?: boolean }) {
  return (
    <section className="section">
      <div className="container">
        <p className={error ? "auth-error" : "filter-empty"}>{children}</p>
      </div>
    </section>
  );
}
