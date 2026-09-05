"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import type { SupportLearningContext } from "@/types";

/** Manager's read-only learning-context panel. Everything is read live from
 *  LMS state by the backend on each request — nothing is stored in the chat. */
export function ContextPanel({ context }: { context: SupportLearningContext }) {
  const { t } = useLanguage();
  const c = t.support;
  const ctx = context;

  return (
    <aside className="support-context">
      <h3>{c.adminContext}</h3>

      <dl className="support-ctx-block">
        <div>
          <dt>{c.ctxStudent}</dt>
          <dd>
            {ctx.student.name}
            {ctx.student.email ? <span className="admin-muted"> · {ctx.student.email}</span> : null}
          </dd>
        </div>
        {ctx.parent && (
          <div>
            <dt>{c.ctxParent}</dt>
            <dd>
              {ctx.parent.name}
              {" "}
              <span
                className={ctx.parentLinked ? "support-ctx-ok" : "support-ctx-warn"}
              >
                ({ctx.parentLinked ? c.ctxLinked : c.ctxNotLinked})
              </span>
            </dd>
          </div>
        )}
      </dl>

      <div className="support-ctx-block">
        <h4>{c.ctxCourses}</h4>
        {ctx.courses.length === 0 && <p className="admin-muted">—</p>}
        {ctx.courses.map((co) => (
          <div key={co.id} className={`support-ctx-course${co.isFocus ? " focus" : ""}`}>
            <div className="support-ctx-course-head">
              <span>{co.title}</span>
              <span className="admin-muted">{co.progressPercent}%</span>
            </div>
            <div className="support-ctx-bar">
              <span style={{ width: `${co.progressPercent}%` }} />
            </div>
            <span className="admin-muted">
              {co.completedLessons}/{co.totalLessons} · {co.enrollmentStatus}
            </span>
            {co.isFocus && (
              <Link href={`/courses/${co.slug}`} className="admin-link" target="_blank">
                {c.ctxOpenCourse} →
              </Link>
            )}
          </div>
        ))}
      </div>

      {ctx.currentLesson && (
        <p className="support-ctx-line">
          <strong>{c.ctxCurrentLesson}:</strong> {ctx.currentLesson}
        </p>
      )}

      {ctx.latestQuiz && (
        <p className="support-ctx-line">
          <strong>{c.ctxLatestQuiz}:</strong> {ctx.latestQuiz.assignmentTitle} —{" "}
          {ctx.latestQuiz.latestPercent ?? "—"}% / {ctx.latestQuiz.passPercent}% ·{" "}
          {ctx.latestQuiz.attempts} {c.ctxAttempts} ·{" "}
          <span className={ctx.latestQuiz.passed ? "support-ctx-ok" : "support-ctx-warn"}>
            {ctx.latestQuiz.passed ? c.ctxPassed : c.ctxNotPassed}
          </span>
        </p>
      )}

      {ctx.latestSubmission && (
        <p className="support-ctx-line">
          <strong>{c.ctxLatestSubmission}:</strong> {ctx.latestSubmission.assignmentTitle} (
          {ctx.latestSubmission.assignmentType}) — {ctx.latestSubmission.status}
          {ctx.latestSubmission.score != null ? ` · ${ctx.latestSubmission.score}` : ""}
        </p>
      )}

      {ctx.latestCodeRun && (
        <p className="support-ctx-line">
          <strong>{c.ctxLatestCodeRun}:</strong> {ctx.latestCodeRun.assignmentTitle} ·{" "}
          {ctx.latestCodeRun.language} · {ctx.latestCodeRun.status} ({ctx.latestCodeRun.kind})
        </p>
      )}

      {ctx.certificate && (
        <p className="support-ctx-line">
          <strong>{c.ctxCertificate}:</strong>{" "}
          {ctx.certificate.issued ? (
            <span className="support-ctx-ok">
              {c.ctxIssued}
              {ctx.certificate.certificateNumber ? ` · ${ctx.certificate.certificateNumber}` : ""}
            </span>
          ) : (
            <span className={ctx.certificate.eligible ? "support-ctx-ok" : "admin-muted"}>
              {ctx.certificate.eligible ? c.ctxEligible : c.ctxNotEligible}
            </span>
          )}
        </p>
      )}
    </aside>
  );
}
