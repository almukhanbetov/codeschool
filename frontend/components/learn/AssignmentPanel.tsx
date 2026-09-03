"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { CodeEditor } from "@/components/learn/CodeEditor";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import {
  ApiError,
  getQuizAttempts,
  saveSubmissionDraft,
  submitAssignment,
} from "@/lib/api";
import type { Assignment, QuizAttemptHistory, Submission } from "@/types";

export function AssignmentPanel({
  assignment,
  courseId,
  initialSubmission,
  onSubmittedChange,
}: {
  assignment: Assignment;
  courseId: number;
  initialSubmission: Submission | null;
  onSubmittedChange: (submitted: boolean) => void;
}) {
  if (assignment.assignmentType === "quiz") {
    return (
      <QuizAssignmentPanel
        assignment={assignment}
        courseId={courseId}
        onSubmittedChange={onSubmittedChange}
      />
    );
  }
  return (
    <WrittenAssignmentPanel
      assignment={assignment}
      initialSubmission={initialSubmission}
      onSubmittedChange={onSubmittedChange}
    />
  );
}

/* ================= quiz ================= */

function QuizAssignmentPanel({
  assignment,
  courseId,
  onSubmittedChange,
}: {
  assignment: Assignment;
  courseId: number;
  onSubmittedChange: (submitted: boolean) => void;
}) {
  const { t } = useLanguage();
  const q = t.quiz;
  const [history, setHistory] = useState<QuizAttemptHistory | null>(null);
  const [error, setError] = useState<string | null>(null);

  const notify = useRef(onSubmittedChange);
  useEffect(() => {
    notify.current = onSubmittedChange;
  });

  const load = useCallback(async () => {
    try {
      const h = await getQuizAttempts(assignment.id);
      setHistory(h);
      notify.current(h.passed);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : q.loadError);
    }
  }, [assignment.id, q.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  const quizHref = `/learn/${courseId}/lesson/${assignment.lessonId}/quiz/${assignment.id}`;
  const hasAttempts = (history?.attempts.length ?? 0) > 0;
  const label = history?.inProgressId
    ? q.continueQuiz
    : hasAttempts
      ? q.retakeQuiz
      : q.startQuiz;
  const canStart = history?.canStart ?? true;

  return (
    <div className="assignment-panel">
      <div className="assignment-head">
        <h3>{assignment.title}</h3>
        {history?.passed && <span className="quiz-badge quiz-badge-pass">✓ {q.passed}</span>}
      </div>
      {assignment.description && <p className="assignment-desc">{assignment.description}</p>}

      {history && (
        <div className="quiz-summary">
          <span>
            {q.passThreshold}: {history.passPercent}%
          </span>
          {history.bestPercent != null && (
            <span>
              {q.bestResult}: {history.bestScore}/{history.bestMaxScore} ({history.bestPercent}%)
            </span>
          )}
          <span>
            {q.attempts}: {history.attemptsUsed}
            {history.maxAttempts != null ? ` / ${history.maxAttempts}` : ""}
          </span>
        </div>
      )}

      {error && (
        <p className="auth-error" role="alert">
          {error}
        </p>
      )}

      {canStart ? (
        <div className="assignment-actions">
          <Button href={quizHref} variant="primary" size="sm">
            {label}
          </Button>
        </div>
      ) : (
        <p className="assignment-hint">{q.noAttemptsLeft}</p>
      )}

      {hasAttempts && (
        <ul className="quiz-history">
          {history!.attempts
            .filter((a) => a.status === "submitted")
            .map((a) => (
              <li key={a.attemptId}>
                <Link href={`/learn/${courseId}/lesson/${assignment.lessonId}/quiz/${assignment.id}`}>
                  {q.attemptNumber} {a.attemptNumber}
                </Link>
                <span>
                  {a.score}/{a.maxScore} · {a.percent}%
                </span>
                <span className={a.passed ? "quiz-mark-ok" : "quiz-mark-bad"}>
                  {a.passed ? q.passed : q.failed}
                </span>
              </li>
            ))}
        </ul>
      )}
    </div>
  );
}

/* ================= text / code / project ================= */

function WrittenAssignmentPanel({
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

      <div className="assignment-label-row">
        <label className="assignment-label" htmlFor={`a-${assignment.id}`}>
          {usesCodeField ? t.learn.yourCode : t.learn.yourAnswer}
        </label>
        {isCode && editable && assignment.starterCode != null && (
          <button
            type="button"
            className="admin-link"
            onClick={() => setValue(assignment.starterCode ?? "")}
            disabled={pending !== null}
          >
            {t.learn.resetToStarter}
          </button>
        )}
      </div>
      {isCode ? (
        <CodeEditor
          value={value}
          onChange={setValue}
          language={assignment.language ?? "plaintext"}
          readOnly={!editable || pending !== null}
          ariaLabel={t.learn.yourCode}
        />
      ) : (
        <textarea
          id={`a-${assignment.id}`}
          className="assignment-input"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          disabled={!editable || pending !== null}
          rows={5}
          spellCheck
          placeholder={isProject ? t.learn.projectPlaceholder : undefined}
        />
      )}

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
