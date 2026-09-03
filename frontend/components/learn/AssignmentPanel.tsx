"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { CodeAssignmentPanel } from "@/components/learn/CodeAssignmentPanel";
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
  apiPrefix = "",
  basePath = "/learn",
  initialSubmission,
  onSubmittedChange,
}: {
  assignment: Assignment;
  courseId: number;
  apiPrefix?: string;
  basePath?: string;
  initialSubmission: Submission | null;
  onSubmittedChange: (submitted: boolean) => void;
}) {
  if (assignment.assignmentType === "quiz") {
    return (
      <QuizAssignmentPanel
        assignment={assignment}
        courseId={courseId}
        apiPrefix={apiPrefix}
        basePath={basePath}
        onSubmittedChange={onSubmittedChange}
      />
    );
  }
  if (assignment.assignmentType === "code") {
    return (
      <CodeAssignmentPanel
        assignment={assignment}
        apiPrefix={apiPrefix}
        initialSubmission={initialSubmission}
        onSubmittedChange={onSubmittedChange}
      />
    );
  }
  return (
    <TextAssignmentPanel
      assignment={assignment}
      apiPrefix={apiPrefix}
      initialSubmission={initialSubmission}
      onSubmittedChange={onSubmittedChange}
    />
  );
}

/* ================= quiz ================= */

function QuizAssignmentPanel({
  assignment,
  courseId,
  apiPrefix,
  basePath,
  onSubmittedChange,
}: {
  assignment: Assignment;
  courseId: number;
  apiPrefix: string;
  basePath: string;
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
      const h = await getQuizAttempts(assignment.id, apiPrefix);
      setHistory(h);
      notify.current(h.passed);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : q.loadError);
    }
  }, [assignment.id, apiPrefix, q.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  const quizHref = `${basePath}/${courseId}/lesson/${assignment.lessonId}/quiz/${assignment.id}`;
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
                <Link href={quizHref}>
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

/* ================= text / project ================= */

function TextAssignmentPanel({
  assignment,
  apiPrefix,
  initialSubmission,
  onSubmittedChange,
}: {
  assignment: Assignment;
  apiPrefix: string;
  initialSubmission: Submission | null;
  onSubmittedChange: (submitted: boolean) => void;
}) {
  const { t } = useLanguage();
  const isProject = assignment.assignmentType === "project";

  const [submission, setSubmission] = useState<Submission | null>(initialSubmission);
  const [value, setValue] = useState<string>(initialSubmission?.answer ?? "");
  const [pending, setPending] = useState<null | "save" | "submit">(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const editable =
    submission == null || submission.status === "draft" || submission.status === "failed";
  const isFailed = submission?.status === "failed";
  const isPassed = submission?.status === "passed";

  async function persist() {
    return saveSubmissionDraft(assignment.id, { answer: value }, apiPrefix);
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
      const next = await submitAssignment(assignment.id, apiPrefix);
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

      <label className="assignment-label" htmlFor={`a-${assignment.id}`}>
        {t.learn.yourAnswer}
      </label>
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
          <Button type="button" variant="primary" size="sm" onClick={send} disabled={pending !== null}>
            {pending === "submit" ? t.learn.submitting : t.learn.submit}
          </Button>
        </div>
      )}
    </div>
  );
}
