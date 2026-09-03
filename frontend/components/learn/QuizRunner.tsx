"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import {
  ApiError,
  getQuizAttempts,
  startQuizAttempt,
  submitQuizAttempt,
} from "@/lib/api";
import type {
  QuizAttemptHistory,
  QuizResult,
  QuizStartResponse,
  QuizSubmitAnswer,
} from "@/types";

type Answers = Record<number, number[]>;

type Phase =
  | { kind: "loading" }
  | { kind: "error"; message: string }
  | { kind: "taking"; start: QuizStartResponse }
  | { kind: "result"; result: QuizResult };

export function QuizRunner({
  courseId,
  lessonId,
  assignmentId,
  apiPrefix = "",
  basePath = "/learn",
}: {
  courseId: number;
  lessonId: number;
  assignmentId: number;
  apiPrefix?: string;
  basePath?: string;
}) {
  const { t } = useLanguage();
  const q = t.quiz;

  const [phase, setPhase] = useState<Phase>({ kind: "loading" });
  const [history, setHistory] = useState<QuizAttemptHistory | null>(null);
  const [index, setIndex] = useState(0);
  const [answers, setAnswers] = useState<Answers>({});
  const [submitting, setSubmitting] = useState(false);

  const begin = useCallback(async () => {
    setPhase({ kind: "loading" });
    setAnswers({});
    setIndex(0);
    try {
      const [start, hist] = await Promise.all([
        startQuizAttempt(assignmentId, apiPrefix),
        getQuizAttempts(assignmentId, apiPrefix),
      ]);
      setHistory(hist);
      setPhase({ kind: "taking", start });
    } catch (err) {
      setPhase({
        kind: "error",
        message: err instanceof ApiError ? err.message : q.loadError,
      });
    }
  }, [assignmentId, apiPrefix, q.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void begin();
  }, [begin]);

  function toggle(questionId: number, optionId: number, single: boolean) {
    setAnswers((prev) => {
      const cur = prev[questionId] ?? [];
      if (single) return { ...prev, [questionId]: [optionId] };
      return {
        ...prev,
        [questionId]: cur.includes(optionId)
          ? cur.filter((id) => id !== optionId)
          : [...cur, optionId],
      };
    });
  }

  async function finish() {
    if (phase.kind !== "taking") return;
    setSubmitting(true);
    try {
      const payload: QuizSubmitAnswer[] = phase.start.quiz.questions
        .map((qq) => ({
          questionId: qq.id,
          selectedOptionIds: answers[qq.id] ?? [],
        }))
        .filter((a) => a.selectedOptionIds.length > 0);
      const result = await submitQuizAttempt(phase.start.attempt.id, payload, apiPrefix);
      setPhase({ kind: "result", result });
    } catch (err) {
      setPhase({
        kind: "error",
        message: err instanceof ApiError ? err.message : q.loadError,
      });
    } finally {
      setSubmitting(false);
    }
  }

  const backToLesson = (
    <Link href={`${basePath}/${courseId}/lesson/${lessonId}`} className="student-viewall">
      {q.backToLesson}
    </Link>
  );

  if (phase.kind === "loading") {
    return <Shell>{backToLesson}<p className="filter-empty">{q.loading}</p></Shell>;
  }

  if (phase.kind === "error") {
    return (
      <Shell>
        {backToLesson}
        <p className="auth-error" role="alert">{phase.message}</p>
        <Button href={`${basePath}/${courseId}/lesson/${lessonId}`} variant="ghost" size="sm">
          {q.backToLesson}
        </Button>
      </Shell>
    );
  }

  if (phase.kind === "result") {
    return (
      <Shell>
        {backToLesson}
        <QuizResultView
          result={phase.result}
          canRetry={history?.canStart ?? true}
          attemptsLeft={history?.attemptsLeft ?? null}
          onRetry={() => void begin()}
          backHref={`${basePath}/${courseId}/lesson/${lessonId}`}
        />
      </Shell>
    );
  }

  const questions = phase.start.quiz.questions;
  const total = questions.length;
  const question = questions[index];
  const selected = answers[question.id] ?? [];
  const single = question.questionType !== "multiple_choice";
  const answeredCount = questions.filter((qq) => (answers[qq.id] ?? []).length > 0).length;
  const isLast = index === total - 1;

  return (
    <Shell>
      {backToLesson}
      <div className="quiz-head">
        <h1 className="learn-lesson-heading">{phase.start.quiz.title}</h1>
        <p className="quiz-progress-label">
          {q.question} {index + 1} {q.of} {total}
        </p>
      </div>
      <ProgressBar percent={Math.round(((index + 1) / total) * 100)} />

      <div className="quiz-card">
        <p className="quiz-question-text">{question.questionText}</p>
        <p className="quiz-question-hint">
          {single ? q.chooseOne : q.chooseMany} · {question.points} {q.points}
        </p>
        <ul className="quiz-options">
          {question.options.map((o) => {
            const checked = selected.includes(o.id);
            return (
              <li key={o.id}>
                <label className={`quiz-option${checked ? " quiz-option-checked" : ""}`}>
                  <input
                    type={single ? "radio" : "checkbox"}
                    name={`q-${question.id}`}
                    checked={checked}
                    onChange={() => toggle(question.id, o.id, single)}
                  />
                  <span>{o.optionText}</span>
                </label>
              </li>
            );
          })}
        </ul>
      </div>

      <div className="quiz-nav">
        <Button
          type="button"
          variant="ghost"
          size="sm"
          onClick={() => setIndex((i) => Math.max(0, i - 1))}
          disabled={index === 0}
        >
          {q.back}
        </Button>
        {isLast ? (
          <Button type="button" variant="primary" size="sm" onClick={finish} disabled={submitting}>
            {submitting ? q.submitting : q.finishQuiz}
          </Button>
        ) : (
          <Button type="button" variant="primary" size="sm" onClick={() => setIndex((i) => Math.min(total - 1, i + 1))}>
            {q.next}
          </Button>
        )}
      </div>
      {answeredCount < total && isLast && (
        <p className="assignment-hint">{q.unansweredWarning}</p>
      )}
    </Shell>
  );
}

function Shell({ children }: { children: React.ReactNode }) {
  return (
    <section className="section learn-section">
      <div className="container quiz-container">{children}</div>
    </section>
  );
}

export function QuizResultView({
  result,
  canRetry,
  attemptsLeft,
  onRetry,
  backHref,
}: {
  result: QuizResult;
  canRetry: boolean;
  attemptsLeft: number | null;
  onRetry: () => void;
  backHref: string;
}) {
  const { t } = useLanguage();
  const q = t.quiz;

  return (
    <div className="quiz-result">
      <div className={`quiz-result-banner ${result.passed ? "quiz-result-pass" : "quiz-result-fail"}`}>
        <p className="quiz-result-heading">{q.result}</p>
        <p className="quiz-result-score">
          {result.score} / {result.maxScore}
        </p>
        <p className="quiz-result-percent">{result.percent}%</p>
        <p className="quiz-result-verdict">
          {result.passed ? `✓ ${q.passed}` : q.failed}
        </p>
        <p className="quiz-result-threshold">
          {q.passThreshold}: {result.passPercent}%
        </p>
      </div>

      <div className="quiz-result-actions">
        {!result.passed && canRetry && (
          <Button type="button" variant="primary" size="sm" onClick={onRetry}>
            {q.tryAgain}
          </Button>
        )}
        {attemptsLeft != null && (
          <span className="quiz-attempts-left">
            {q.attemptsLeft}: {attemptsLeft}
          </span>
        )}
        <Button href={backHref} variant="ghost" size="sm">
          {q.backToLesson}
        </Button>
      </div>

      <h2 className="quiz-review-title">{q.reviewAnswers}</h2>
      <ol className="quiz-review-list">
        {result.questions.map((rq) => (
          <li key={rq.questionId} className="quiz-review-card">
            <p className="quiz-review-q">
              <span className={`quiz-review-mark ${rq.isCorrect ? "quiz-mark-ok" : "quiz-mark-bad"}`}>
                {rq.isCorrect ? q.correct : q.incorrect}
              </span>{" "}
              {rq.questionText}
              <span className="quiz-review-points">
                {" "}
                {rq.pointsAwarded}/{rq.points} {q.points}
              </span>
            </p>
            <ul className="quiz-review-options">
              {rq.options.map((o) => {
                const cls = [
                  "quiz-review-opt",
                  o.selected ? "quiz-review-opt-selected" : "",
                  o.isCorrect === true ? "quiz-review-opt-correct" : "",
                  o.isCorrect === false && o.selected ? "quiz-review-opt-wrong" : "",
                ]
                  .filter(Boolean)
                  .join(" ");
                return (
                  <li key={o.id} className={cls}>
                    {o.optionText}
                    {o.selected && <span className="quiz-review-tag">{q.yourAnswer}</span>}
                    {o.isCorrect === true && (
                      <span className="quiz-review-tag quiz-review-tag-correct">{q.correctAnswer}</span>
                    )}
                  </li>
                );
              })}
            </ul>
            {rq.explanation && (
              <p className="quiz-review-explanation">
                <strong>{q.explanation}:</strong> {rq.explanation}
              </p>
            )}
          </li>
        ))}
      </ol>
    </div>
  );
}
