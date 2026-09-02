"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { ApiError, getParentChild, getParentChildActivity } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Button } from "@/components/ui/Button";
import type {
  ParentActivityItem,
  ParentActivitySummary,
  ParentChildOverview,
} from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notFound" }
  | { kind: "error" }
  | { kind: "ready"; overview: ParentChildOverview; activity: ParentActivitySummary };

export function ParentChildDetail({ childId }: { childId: number }) {
  const { t } = useLanguage();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [overview, activity] = await Promise.all([
          getParentChild(childId),
          getParentChildActivity(childId),
        ]);
        if (!cancelled) setState({ kind: "ready", overview, activity });
      } catch (err) {
        if (cancelled) return;
        if (err instanceof ApiError && (err.status === 404 || err.status === 403)) {
          setState({ kind: "notFound" });
        } else {
          setState({ kind: "error" });
        }
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [childId]);

  if (state.kind === "loading") return <Centered>{t.family.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.family.loadError}</Centered>;
  if (state.kind === "notFound") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.family.loadError}</p>
          <Button href="/parent" variant="primary">
            {t.family.backToChildren}
          </Button>
        </div>
      </section>
    );
  }

  const { overview, activity } = state;
  const name = `${overview.child.firstName} ${overview.child.lastName ?? ""}`.trim();

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{t.family.dashTitle}</span>
            <h1 className="student-dash-title">{name}</h1>
          </div>
          <Link href="/parent" className="student-viewall">
            {t.family.backToChildren}
          </Link>
        </div>

        <h2 className="teacher-section-title">{t.family.childCourses}</h2>
        {overview.courses.length === 0 ? (
          <p className="filter-empty">—</p>
        ) : (
          <div className="course-grid">
            {overview.courses.map((c) => (
              <article className="course-card" key={c.course.id}>
                <div className="course-tag course-tag-neutral">{c.enrollmentStatus}</div>
                <h3>{c.course.title}</h3>
                <ProgressBar
                  percent={c.progress.progressPercent}
                  label={`${c.progress.completedLessons}/${c.progress.totalLessons}`}
                />
                <Button
                  href={`/parent/children/${childId}/courses/${c.course.id}`}
                  variant="primary"
                  size="sm"
                  className="course-btn"
                >
                  {t.family.viewCourse}
                </Button>
              </article>
            ))}
          </div>
        )}

        <h2 className="teacher-section-title">{t.family.activity}</h2>
        {activity.items.length === 0 ? (
          <p className="filter-empty">{t.family.noActivity}</p>
        ) : (
          <ul className="family-activity">
            {activity.items.map((it, i) => (
              <li key={i} className={`family-activity-row family-activity-${it.type}`}>
                <span className="family-activity-label">{activityLabel(it, t)}</span>
                <span className="family-activity-detail">
                  {it.courseTitle}
                  {it.assignmentTitle ? ` · ${it.assignmentTitle}` : ` · ${it.lessonTitle}`}
                  {it.score != null && it.points != null ? ` · ${it.score} / ${it.points}` : ""}
                </span>
                <span className="family-activity-date">{formatDate(it.at)}</span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  );
}

function activityLabel(
  it: ParentActivityItem,
  t: ReturnType<typeof useLanguage>["t"]
): string {
  switch (it.type) {
    case "lesson_completed":
      return t.family.activityLessonCompleted;
    case "assignment_submitted":
      return t.family.activityAssignmentSubmitted;
    case "assignment_passed":
      return t.family.activityAssignmentPassed;
    case "assignment_failed":
      return t.family.activityAssignmentFailed;
  }
}

function formatDate(iso: string): string {
  const d = new Date(iso);
  return (
    d.toLocaleDateString(undefined, { day: "2-digit", month: "short" }) +
    " " +
    d.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })
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
