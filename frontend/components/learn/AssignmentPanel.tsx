"use client";

import { useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { ApiError, saveSubmissionDraft, submitAssignment } from "@/lib/api";
import type { Assignment, Submission } from "@/types";

export function AssignmentPanel({
  assignment,
  initialSubmission,
  onSubmittedChange,
}: {
  assignment: Assignment;
  initialSubmission: Submission | null;
  onSubmittedChange: (submitted: boolean) => void;
}) {
  const { t } = useLanguage();
  const isCode = assignment.assignmentType === "code";
  const isProject = assignment.assignmentType === "project";
  const usesCodeField = isCode;

  const [submission, setSubmission] = useState<Submission | null>(initialSubmission);
  const [value, setValue] = useState<string>(
    (usesCodeField ? initialSubmission?.code : initialSubmission?.answer) ??
      (usesCodeField ? (assignment.starterCode ?? "") : "")
  );
  const [pending, setPending] = useState<null | "save" | "submit">(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Editable while there is no submission, or it is a draft, or the teacher
  // sent it back (failed → the student revises and resubmits).
  const editable =
    submission == null || submission.status === "draft" || submission.status === "failed";
  const isFailed = submission?.status === "failed";
  const isPassed = submission?.status === "passed";

  async function persist() {
    return saveSubmissionDraft(
      assignment.id,
      usesCodeField ? { code: value } : { answer: value }
    );
  }

  async function save() {
    setPending("save");
    setNotice(null);
    setError(null);
    try {
      setSubmission(await persist());
      setNotice(t.learn.saved);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t.learn.loadError);
    } finally {
      setPending(null);
    }
  }

  async function send() {
    setPending("submit");
    setNotice(null);
    setError(null);
    try {
      await persist();
      const next = await submitAssignment(assignment.id);
      setSubmission(next);
      onSubmittedChange(true);
      setNotice(t.learn.submittedNotice);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t.learn.loadError);
    } finally {
      setPending(null);
    }
  }

  return (
    <div className="assignment-panel">
      <div className="assignment-head">
        <h3>{assignment.title}</h3>
        {submission && <SubmissionBadge status={submission.status} />}
      </div>
      {assignment.description && <p className="assignment-desc">{assignment.description}</p>}

      {assignment.expectedOutput && (
        <p className="assignment-expected">
          <strong>{t.learn.expectedOutput}:</strong> <code>{assignment.expectedOutput}</code>
        </p>
      )}

      {/* Teacher verdict, when reviewed */}
      {(isPassed || isFailed) && (
        <div className={`review-result ${isPassed ? "review-result-passed" : "review-result-failed"}`}>
          <p className="review-result-head">
            {isPassed ? `✓ ${t.learn.statusPassed}` : t.learn.statusFailed}
            {submission?.score != null && (
              <span className="review-result-score">
                {" "}
                {submission.score} / {assignment.points}
              </span>
            )}
          </p>
          {submission?.teacherFeedback && (
            <p className="review-result-feedback">{submission.teacherFeedback}</p>
          )}
        </div>
      )}

      <label className="assignment-label" htmlFor={`a-${assignment.id}`}>
        {usesCodeField ? t.learn.yourCode : t.learn.yourAnswer}
      </label>
      <textarea
        id={`a-${assignment.id}`}
        className={usesCodeField ? "assignment-input assignment-code" : "assignment-input"}
        value={value}
        onChange={(e) => setValue(e.target.value)}
        disabled={!editable || pending !== null}
        rows={usesCodeField ? 8 : 5}
        spellCheck={!usesCodeField}
        placeholder={isProject ? t.learn.projectPlaceholder : undefined}
      />

      {error && (
        <p className="auth-error" role="alert">
          {error}
        </p>
      )}
      {notice && !error && <p className="assignment-notice">{notice}</p>}

      {editable && (
        <div className="assignment-actions">
          <Button type="button" variant="ghost" size="sm" onClick={save} disabled={pending !== null}>
            {pending === "save" ? t.learn.saving : t.learn.saveDraft}
          </Button>
          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={send}
            disabled={pending !== null}
          >
            {pending === "submit" ? t.learn.submitting : t.learn.submit}
          </Button>
        </div>
      )}
    </div>
  );
}
