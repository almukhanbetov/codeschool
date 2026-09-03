"use client";

import { useCallback, useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { adminAcademyApi, ApiError } from "@/lib/api";
import type { AcademyLearnerRow, AcademySubmissionDetail, AcademySubmissionRow } from "@/types";

export function AdminAcademy() {
  const { t } = useLanguage();
  const a = t.academy;
  const adm = t.admin;
  const [learners, setLearners] = useState<AcademyLearnerRow[] | null>(null);
  const [pending, setPending] = useState<AcademySubmissionRow[] | null>(null);
  const [reviewing, setReviewing] = useState<AcademySubmissionDetail | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const [l, p] = await Promise.all([
        adminAcademyApi.learners(),
        adminAcademyApi.submissions(),
      ]);
      setLearners(l);
      setPending(p);
      setError(null);
    } catch {
      setError(adm.loadError);
    }
  }, [adm.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  async function openReview(id: number) {
    try {
      setReviewing(await adminAcademyApi.submission(id));
    } catch (err) {
      setError(err instanceof ApiError ? err.message : adm.loadError);
    }
  }

  return (
    <>
      <h1 className="student-dash-title">{a.adminTitle}</h1>
      {error && <p className="auth-error">{error}</p>}

      <div className="admin-section">
        <div className="admin-section-head">
          <h2>{a.adminLearners}</h2>
        </div>
        {learners === null ? (
          <p className="filter-empty">{adm.loading}</p>
        ) : learners.length === 0 ? (
          <p className="filter-empty">{adm.nothing}</p>
        ) : (
          <div className="teacher-table-wrap">
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>{adm.fFirstName}</th>
                  <th>{adm.fEmail}</th>
                  <th>{a.coursesInProgress}</th>
                  <th>{a.coursesCompleted}</th>
                </tr>
              </thead>
              <tbody>
                {learners.map((l) => (
                  <tr key={l.teacherId}>
                    <td data-label={adm.fFirstName}>{l.name}</td>
                    <td data-label={adm.fEmail}>{l.email ?? "—"}</td>
                    <td data-label={a.coursesInProgress}>{l.coursesEnrolled - l.coursesCompleted}</td>
                    <td data-label={a.coursesCompleted}>{l.coursesCompleted}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="admin-section">
        <div className="admin-section-head">
          <h2>{a.adminReviewQueue}</h2>
        </div>
        {pending === null ? (
          <p className="filter-empty">{adm.loading}</p>
        ) : pending.length === 0 ? (
          <p className="filter-empty">{a.adminNoPending}</p>
        ) : (
          <div className="teacher-table-wrap">
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>{adm.fFirstName}</th>
                  <th>{adm.assignments}</th>
                  <th>{adm.fLessonType}</th>
                  <th>{adm.actions}</th>
                </tr>
              </thead>
              <tbody>
                {pending.map((s) => (
                  <tr key={s.id}>
                    <td data-label={adm.fFirstName}>{s.teacherName}</td>
                    <td data-label={adm.assignments}>
                      <span className="teacher-cell-title">{s.assignmentName}</span>
                      <span className="admin-muted"> · {s.courseTitle}</span>
                    </td>
                    <td data-label={adm.fLessonType}>{s.assignmentType}</td>
                    <td data-label={adm.actions}>
                      <button
                        type="button"
                        className="admin-link admin-link-strong"
                        onClick={() => void openReview(s.id)}
                      >
                        {a.adminReview}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {reviewing && (
        <ReviewDialog
          submission={reviewing}
          onClose={() => setReviewing(null)}
          onDone={async () => {
            setReviewing(null);
            await load();
          }}
        />
      )}
    </>
  );
}

function ReviewDialog({
  submission,
  onClose,
  onDone,
}: {
  submission: AcademySubmissionDetail;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useLanguage();
  const a = t.academy;
  const adm = t.admin;
  const [score, setScore] = useState(submission.score != null ? String(submission.score) : "");
  const [feedback, setFeedback] = useState(submission.teacherFeedback ?? "");
  const [pending, setPending] = useState<null | "passed" | "failed">(null);
  const [err, setErr] = useState<string | null>(null);

  async function review(status: "passed" | "failed") {
    setPending(status);
    setErr(null);
    try {
      await adminAcademyApi.review(submission.id, {
        score: score.trim() === "" ? null : Number(score),
        feedback,
        status,
      });
      onDone();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : adm.loadError);
    } finally {
      setPending(null);
    }
  }

  return (
    <div className="admin-dialog-backdrop" onClick={onClose}>
      <div className="admin-dialog admin-dialog-wide" onClick={(e) => e.stopPropagation()}>
        <h3>
          {a.adminReview}: {submission.assignmentName}
        </h3>
        <p className="admin-muted">
          {submission.teacherName} · {submission.courseTitle} · {submission.lessonTitle}
        </p>
        {submission.status !== "submitted" && submission.status !== "checking" && (
          <p className="assignment-notice">
            <SubmissionBadge status={submission.status} />
          </p>
        )}
        {submission.answer && <pre className="learn-content-body">{submission.answer}</pre>}
        {submission.code && <pre className="learn-content-body review-code">{submission.code}</pre>}

        <label className="admin-field">
          <span>
            {adm.fPoints} / {submission.points}
          </span>
          <input
            type="number"
            min={0}
            max={submission.points}
            value={score}
            onChange={(e) => setScore(e.target.value)}
          />
        </label>
        <label className="admin-field">
          <span>{adm.auditSummary}</span>
          <textarea rows={3} value={feedback} onChange={(e) => setFeedback(e.target.value)} />
        </label>
        {err && <p className="auth-error">{err}</p>}

        <div className="admin-form-actions">
          <Button type="button" variant="ghost" size="sm" onClick={onClose}>
            {adm.cancel}
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => review("failed")}
            disabled={pending !== null}
          >
            {pending === "failed" ? adm.saving : a.adminMarkFailed}
          </Button>
          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={() => review("passed")}
            disabled={pending !== null}
          >
            {pending === "passed" ? adm.saving : a.adminMarkPassed}
          </Button>
        </div>
      </div>
    </div>
  );
}
