"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { ApiError, getAcademyDashboard } from "@/lib/api";
import type { AcademyDashboard as Dashboard } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; data: Dashboard };

export function AcademyDashboard() {
  const { t } = useLanguage();
  const a = t.academy;
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    getAcademyDashboard()
      .then((data) => !cancelled && setState({ kind: "ready", data }))
      .catch((err) => {
        if (cancelled) return;
        setState({ kind: err instanceof ApiError ? "error" : "error" });
      });
    return () => {
      cancelled = true;
    };
  }, []);

  if (state.kind === "loading") return <Centered>{t.learn.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.learn.loadError}</Centered>;

  const d = state.data;

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{a.navTitle}</span>
            <h1 className="student-dash-title">{a.myLearning}</h1>
          </div>
          <Link href="/teacher-academy/courses" className="student-viewall">
            {a.browseCourses}
          </Link>
        </div>

        <div className="teacher-cards admin-cards">
          <StatCard label={a.coursesInProgress} value={d.coursesInProgress} />
          <StatCard label={a.coursesCompleted} value={d.coursesCompleted} />
          <StatCard label={a.totalProgress} value={`${d.overallPercent}%`} />
        </div>

        {d.courses.length === 0 ? (
          <div className="student-empty">
            <p className="filter-empty">{a.noCourses}</p>
            <Button href="/teacher-academy/courses" variant="primary">
              {a.browseCourses}
            </Button>
          </div>
        ) : (
          <div className="learn-modules">
            {d.courses.map((c) => (
              <div className="learn-module academy-course-row" key={c.courseId}>
                <div className="academy-course-row-head">
                  <h3>{c.title}</h3>
                  {c.courseCompleted ? (
                    <span className="quiz-badge quiz-badge-pass">✓ {a.courseComplete}</span>
                  ) : null}
                </div>
                {c.shortDescription && <p className="assignment-desc">{c.shortDescription}</p>}
                <ProgressBar
                  percent={c.progressPercent}
                  label={`${c.completedLessons}/${c.totalLessons} ${a.lessonsLabel}`}
                />
                <div className="assignment-actions">
                  <Button
                    href={`/teacher-academy/learn/${c.courseId}`}
                    variant="primary"
                    size="sm"
                  >
                    {c.courseCompleted ? a.browseCourses : a.continueLearning}
                  </Button>
                  {c.certificateEligible && (
                    <span className="academy-cert-tag">{a.certificateReady}</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  );
}

function StatCard({ label, value }: { label: string; value: number | string }) {
  return (
    <div className="teacher-stat">
      <span className="teacher-stat-value">{value}</span>
      <span className="teacher-stat-label">{label}</span>
    </div>
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
