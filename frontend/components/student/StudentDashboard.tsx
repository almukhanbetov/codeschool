"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { getMyCourses, getMyProgress } from "@/lib/api";
import { AskCuratorButton } from "@/components/support/AskCuratorButton";
import type { CourseProgress, MyCourseItem } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; courses: MyCourseItem[]; progress: Map<number, CourseProgress> };

export function StudentDashboard() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [courses, progress] = await Promise.all([getMyCourses(), getMyProgress()]);
        if (cancelled) return;
        setState({
          kind: "ready",
          courses,
          progress: new Map(progress.map((p) => [p.courseId, p])),
        });
      } catch {
        if (!cancelled) setState({ kind: "error" });
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const greeting = user ? t.auth.welcome.replace("{name}", user.firstName) : t.student.title;

  return (
    <section className="section">
      <div className="container student-dash">
        <span className="eyebrow">{t.student.title}</span>
        <h1 className="student-dash-title">{greeting}</h1>
        <p className="support-inline-actions">
          <AskCuratorButton label={t.support.askCurator} />
        </p>

        {state.kind === "loading" && <p className="filter-empty">{t.learn.loading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.learn.loadError}</p>}

        {state.kind === "ready" && state.courses.length === 0 && (
          <div className="student-empty">
            <p className="filter-empty">{t.student.noCourses}</p>
            <Button href="/courses" variant="primary">
              {t.student.browseCourses}
            </Button>
          </div>
        )}

        {state.kind === "ready" && state.courses.length > 0 && (
          <>
            <div className="student-overall">
              <span>{t.student.overallProgress}</span>
              <ProgressBar percent={overallPercent(state.progress)} />
            </div>

            <div className="student-dash-head">
              <h2>{t.student.myCourses}</h2>
              <div className="student-dash-links">
                <Link href="/student/certificates" className="student-viewall">
                  {t.certificates.navTitle}
                </Link>
                <Link href="/student/courses" className="student-viewall">
                  {t.student.viewAll}
                </Link>
              </div>
            </div>

            <div className="course-grid">
              {state.courses.map((item) => {
                const p = state.progress.get(item.course.id);
                return (
                  <article className="course-card" key={item.enrollmentId}>
                    <div className="course-tag course-tag-neutral">
                      {item.status === "completed" ? t.student.completed : t.student.inProgress}
                    </div>
                    <h3>{item.course.title}</h3>
                    {item.course.shortDescription && (
                      <p className="student-card-desc">{item.course.shortDescription}</p>
                    )}
                    <ProgressBar
                      percent={p?.progressPercent ?? 0}
                      label={`${p?.completedLessons ?? 0}/${p?.totalLessons ?? item.course.durationLessons ?? 0} ${t.student.lessonsDone}`}
                    />
                    <Button
                      href={`/learn/${item.course.id}`}
                      variant="primary"
                      size="sm"
                      className="course-btn"
                    >
                      {t.student.continueLearning}
                    </Button>
                  </article>
                );
              })}
            </div>
          </>
        )}
      </div>
    </section>
  );
}

function overallPercent(progress: Map<number, CourseProgress>): number {
  const rows = [...progress.values()];
  if (rows.length === 0) return 0;
  const totalDone = rows.reduce((s, p) => s + p.completedLessons, 0);
  const totalAll = rows.reduce((s, p) => s + p.totalLessons, 0);
  return totalAll === 0 ? 0 : (totalDone / totalAll) * 100;
}
