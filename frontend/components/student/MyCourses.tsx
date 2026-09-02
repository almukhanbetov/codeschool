"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { getMyCourses, getMyProgress } from "@/lib/api";
import type { CourseProgress, MyCourseItem } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; courses: MyCourseItem[]; progress: Map<number, CourseProgress> };

export function MyCourses() {
  const { t } = useLanguage();
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

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{t.student.title}</span>
            <h1 className="student-dash-title">{t.student.myCourses}</h1>
          </div>
          <Link href="/student" className="student-viewall">
            {t.learn.backToDashboard}
          </Link>
        </div>

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
                    label={`${p?.completedLessons ?? 0}/${p?.totalLessons ?? 0} ${t.student.lessonsDone}`}
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
        )}
      </div>
    </section>
  );
}
