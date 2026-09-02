"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import {
  ApiError,
  getTeacherSubmission,
  reviewSubmission,
  startSubmissionReview,
} from "@/lib/api";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { Button } from "@/components/ui/Button";
import type { TeacherSubmissionDetail } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notFound" }
  | { kind: "error" }
  | { kind: "ready"; sub: TeacherSubmissionDetail };

export function TeacherReview({ submissionId }: { submissionId: number }) {
  const { t } = useLanguage();
  const [state, setState] = useState<State>({ kind: "loading" });
  const [score, setScore] = useState("");
  const [feedback, setFeedback] = useState("");
  const [pending, setPending] = useState<null | "passed" | "failed">(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const startedFor = useRef<number | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const sub = await getTeacherSubmission(submissionId);
        if (cancelled) return;
        setState({ kind: "ready", sub });
        setScore(sub.score != null ? String(sub.score) : "");
        setFeedback(sub.teacherFeedback ?? "");

        // Move submitted -> checking, once.
        if (sub.status === "submitted" && startedFor.current !== submissionId) {
          startedFor.current = submissionId;
          startSubmissionReview(submissionId)
            .then((updated) => {
              if (!cancelled) setState({ kind: "ready", sub: updated });
            })
            .catch(() => {
              /* non-fatal */
            });
        }
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
  }, [submissionId]);

  if (state.kind === "loading") return <Centered>{t.teach.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.teach.loadError}</Centered>;
  if (state.kind === "notFound") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.teach.loadError}</p>
          <Button href="/teacher/submissions" variant="primary">
            {t.teach.backToQueue}
          </Button>
        </div>
      </section>
    );
  }

  const { sub } = state;
  const a = sub.assignment;
  const isCode = a.assignmentType === "code";
  const decided = sub.status === "passed" || sub.status === "failed";

  async function submitReview(status: "passed" | "failed") {
    setError(null);
    setNotice(null);
    if (status === "failed" && feedback.trim() === "") {
      setError(t.teach.feedbackRequired);
      return;
    }
    const parsed = score.trim() === "" ? null : Number(score);
    if (parsed != null && (Number.isNaN(parsed) || parsed < 0 || parsed > a.points)) {
      setError(t.teach.reviewError);
      return;
    }

    setPending(status);
    try {
      const updated = await reviewSubmission(submissionId, {
        score: parsed,
        feedback: feedback.trim() || undefined,
        status,
      });
      setState({ kind: "ready", sub: updated });
      setNotice(t.teach.reviewSaved);
    } catch (err) {
      if (err instanceof ApiError && err.status === 409) setError(t.teach.notReviewable);
      else if (err instanceof ApiError) setError(err.message);
      else setError(t.teach.reviewError);
    } finally {
      setPending(null);
    }
  }

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">
              {sub.student.firstName} {sub.student.lastName ?? ""} · {sub.course.title}
            </span>
            <h1 className="student-dash-title">{a.title}</h1>
            <p className="teacher-meta">
              {sub.group.title} · {sub.lesson.title} · <SubmissionBadge status={sub.status} />
            </p>
          </div>
          <Link href="/teacher/submissions" className="student-viewall">
            {t.teach.backToQueue}
          </Link>
        </div>

        <div className="review-grid">
          <div className="review-col">
            <h3>{t.teach.description}</h3>
            {a.description && <p className="assignment-desc">{a.description}</p>}
            {a.expectedOutput && (
              <p className="assignment-expected">
                <strong>{t.learn.expectedOutput}:</strong> <code>{a.expectedOutput}</code>
              </p>
            )}
            {a.starterCode && (
              <>
                <h3>{t.teach.starterCode}</h3>
                <pre className="learn-content-body">{a.starterCode}</pre>
              </>
            )}
            <p className="teacher-meta">
              {t.teach.maxPoints}: {a.points}
            </p>
          </div>

          <div className="review-col">
            <h3>{isCode ? t.teach.studentCode : t.teach.studentAnswer}</h3>
            <pre className={isCode ? "learn-content-body review-code" : "learn-content-body"}>
              {(isCode ? sub.code : sub.answer) || "—"}
            </pre>
          </div>
        </div>

        <div className="review-form">
          <div className="review-score-row">
            <label htmlFor="score">
              {t.teach.score}
              <span className="auth-hint"> / {a.points}</span>
            </label>
            <input
              id="score"
              type="number"
              min={0}
              max={a.points}
              className="assignment-input review-score-input"
              value={score}
              onChange={(e) => setScore(e.target.value)}
              disabled={decided || pending !== null}
            />
          </div>

          <label htmlFor="feedback">{t.teach.feedback}</label>
          <textarea
            id="feedback"
            className="assignment-input"
            rows={4}
            value={feedback}
            onChange={(e) => setFeedback(e.target.value)}
            placeholder={t.teach.feedbackPlaceholder}
            disabled={decided || pending !== null}
          />

          {error && (
            <p className="auth-error" role="alert">
              {error}
            </p>
          )}
          {notice && !error && <p className="assignment-notice">{notice}</p>}

          {!decided && (
            <div className="assignment-actions">
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => submitReview("failed")}
                disabled={pending !== null}
              >
                {pending === "failed" ? t.teach.saving : t.teach.markFailed}
              </Button>
              <Button
                type="button"
                variant="primary"
                size="sm"
                onClick={() => submitReview("passed")}
                disabled={pending !== null}
              >
                {pending === "passed" ? t.teach.saving : t.teach.markPassed}
              </Button>
            </div>
          )}
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
