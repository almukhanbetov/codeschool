"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { ApiError, getTeacherStudent } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { Button } from "@/components/ui/Button";
import { Icon } from "@/lib/icons";
import type { TeacherStudentDetail as Detail } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notFound" }
  | { kind: "error" }
  | { kind: "ready"; detail: Detail };

export function TeacherStudentDetail({
  groupId,
  studentId,
}: {
  groupId: number;
  studentId: number;
}) {
  const { t } = useLanguage();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    getTeacherStudent(groupId, studentId)
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
  }, [groupId, studentId]);

  if (state.kind === "loading") return <Centered>{t.teach.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.teach.loadError}</Centered>;
  if (state.kind === "notFound") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.teach.loadError}</p>
          <Button href={`/teacher/groups/${groupId}`} variant="primary">
            {t.teach.backToGroup}
          </Button>
        </div>
      </section>
    );
  }

  const { detail } = state;

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{detail.course.title}</span>
            <h1 className="student-dash-title">
              {detail.student.firstName} {detail.student.lastName ?? ""}
            </h1>
          </div>
          <Link href={`/teacher/groups/${groupId}`} className="student-viewall">
            {t.teach.backToGroup}
          </Link>
        </div>

        <div className="student-overall">
          <span>{t.teach.progress}</span>
          <ProgressBar
            percent={detail.progress.progressPercent}
            label={`${detail.progress.completedLessons}/${detail.progress.totalLessons}`}
          />
        </div>

        <h2 className="teacher-section-title">{t.teach.lessonProgress}</h2>
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

        <h2 className="teacher-section-title">{t.teach.assignments}</h2>
        <div className="teacher-table-wrap">
          <table className="teacher-table">
            <thead>
              <tr>
                <th>{t.teach.assignment}</th>
                <th>{t.teach.lesson}</th>
                <th>{t.teach.score}</th>
                <th>{t.learn.statusDraft}</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {detail.submissions.map((s) => (
                <tr key={s.assignmentId}>
                  <td data-label={t.teach.assignment}>
                    <span className="teacher-cell-title">{s.assignmentTitle}</span>
                  </td>
                  <td data-label={t.teach.lesson}>{s.lessonTitle}</td>
                  <td data-label={t.teach.score}>
                    {s.score != null ? `${s.score} / ${s.points}` : "—"}
                  </td>
                  <td data-label={t.learn.statusDraft}>
                    {s.status ? (
                      <SubmissionBadge status={s.status} />
                    ) : (
                      <span className="teacher-muted">{t.teach.noSubmission}</span>
                    )}
                  </td>
                  <td>
                    {s.submissionId && s.status && s.status !== "draft" ? (
                      <Link
                        href={`/teacher/submissions/${s.submissionId}`}
                        className="teacher-row-link"
                      >
                        {t.teach.review}
                      </Link>
                    ) : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {detail.quizResults.length > 0 && (
          <>
            <h2 className="teacher-section-title">{t.teach.quizResults}</h2>
            <div className="teacher-table-wrap">
              <table className="teacher-table">
                <thead>
                  <tr>
                    <th>{t.teach.assignment}</th>
                    <th>{t.teach.lesson}</th>
                    <th>{t.teach.quizBest}</th>
                    <th>{t.teach.quizAttempts}</th>
                    <th>{t.teach.score}</th>
                  </tr>
                </thead>
                <tbody>
                  {detail.quizResults.map((qr) => (
                    <tr key={qr.assignmentId}>
                      <td data-label={t.teach.assignment}>
                        <span className="teacher-cell-title">{qr.title}</span>
                      </td>
                      <td data-label={t.teach.lesson}>{qr.lessonTitle}</td>
                      <td data-label={t.teach.quizBest}>
                        {qr.bestPercent != null ? `${qr.bestPercent}%` : t.teach.quizNotTaken}
                      </td>
                      <td data-label={t.teach.quizAttempts}>{qr.attempts}</td>
                      <td data-label={t.teach.score}>
                        {qr.attempts === 0 ? (
                          <span className="teacher-muted">—</span>
                        ) : (
                          <span className={qr.passed ? "quiz-mark-ok" : "quiz-mark-bad"}>
                            {qr.passed ? t.teach.quizPassed : t.teach.quizFailed}
                          </span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
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
