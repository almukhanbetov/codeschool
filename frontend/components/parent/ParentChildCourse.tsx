"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { ApiError, getParentChildCourse } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { Button } from "@/components/ui/Button";
import { Icon } from "@/lib/icons";
import type { ParentChildCourseDetail } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notFound" }
  | { kind: "error" }
  | { kind: "ready"; detail: ParentChildCourseDetail };

export function ParentChildCourse({
  childId,
  courseId,
}: {
  childId: number;
  courseId: number;
}) {
  const { t } = useLanguage();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    getParentChildCourse(childId, courseId)
      .then((detail) => !cancelled && setState({ kind: "ready", detail }))
      .catch((err) => {
        if (cancelled) return;
        if (err instanceof ApiError && (err.status === 404 || err.status === 403)) {
          setState({ kind: "notFound" });
        } else {
          setState({ kind: "error" });
        }
      });
    return () => {
      cancelled = true;
    };
  }, [childId, courseId]);

  if (state.kind === "loading") return <Centered>{t.family.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.family.loadError}</Centered>;
  if (state.kind === "notFound") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.family.loadError}</p>
          <Button href={`/parent/children/${childId}`} variant="primary">
            {t.family.backToChild}
          </Button>
        </div>
      </section>
    );
  }

  const { detail } = state;
  const name = `${detail.child.firstName} ${detail.child.lastName ?? ""}`.trim();

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">
              {name} · {detail.course.title}
            </span>
            <h1 className="student-dash-title">{t.family.assignments}</h1>
          </div>
          <Link href={`/parent/children/${childId}`} className="student-viewall">
            {t.family.backToChild}
          </Link>
        </div>

        <div className="student-overall">
          <span>{t.family.overallProgress}</span>
          <ProgressBar
            percent={detail.progress.progressPercent}
            label={`${detail.progress.completedLessons}/${detail.progress.totalLessons}`}
          />
        </div>

        <h2 className="teacher-section-title">{t.family.lessonProgress}</h2>
        <ul className="learn-lesson-list">
          {detail.lessons.map((l) => (
            <li key={l.lessonId}>
              <div className={`learn-lesson-row learn-lesson-${l.status}`}>
                <span className="learn-lesson-icon" aria-hidden="true">
                  <Icon
                    name={
                      l.status === "completed"
                        ? "trending-up"
                        : l.status === "in_progress"
                          ? "book-open"
                          : "chevron-right"
                    }
                  />
                </span>
                <span className="learn-lesson-title">{l.title}</span>
              </div>
            </li>
          ))}
        </ul>

        <h2 className="teacher-section-title">{t.family.assignments}</h2>
        <div className="family-assignments">
          {detail.assignments.map((a) => {
            const isQuiz = a.assignmentType === "quiz";
            return (
            <div className="assignment-panel" key={a.assignmentId}>
              <div className="assignment-head">
                <h3>{a.title}</h3>
                {isQuiz ? (
                  (a.quizAttempts ?? 0) > 0 ? (
                    <span className={a.quizPassed ? "quiz-mark-ok" : "quiz-mark-bad"}>
                      {a.quizPassed ? t.teach.quizPassed : t.teach.quizFailed}
                    </span>
                  ) : (
                    <span className="teacher-muted">{t.teach.quizNotTaken}</span>
                  )
                ) : a.status ? (
                  <SubmissionBadge status={a.status} />
                ) : (
                  <span className="teacher-muted">{t.family.noSubmission}</span>
                )}
              </div>
              <p className="teacher-meta">
                {t.family.lesson}: {a.lessonTitle}
                {isQuiz
                  ? ` · ${t.teach.quizAttempts}: ${a.quizAttempts ?? 0}${
                      a.quizBestPercent != null ? ` · ${t.teach.quizBest}: ${a.quizBestPercent}%` : ""
                    }`
                  : a.score != null
                    ? ` · ${t.family.score}: ${a.score} / ${a.points}`
                    : ""}
              </p>

              {!isQuiz && (a.status === "submitted" || a.status === "checking") ? (
                <p className="assignment-hint">{t.family.awaitingReview}</p>
              ) : null}

              {a.teacherFeedback && (
                <div
                  className={`review-result ${
                    a.status === "passed" ? "review-result-passed" : "review-result-failed"
                  }`}
                >
                  <p className="review-result-head">{t.family.teacherFeedback}</p>
                  <p className="review-result-feedback">{a.teacherFeedback}</p>
                </div>
              )}
            </div>
            );
          })}
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
