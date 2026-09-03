"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { CodeEditor } from "@/components/learn/CodeEditor";
import {
  ApiError,
  getAssignmentTests,
  getCodeRuns,
  runCode,
  saveSubmissionDraft,
  submitAssignment,
  submitCodeForGrading,
} from "@/lib/api";
import type {
  Assignment,
  AssignmentTestsResponse,
  CodeGradeResult,
  CodeRunHistoryItem,
  CodeRunResult,
  Submission,
} from "@/types";

export function CodeAssignmentPanel({
  assignment,
  initialSubmission,
  onSubmittedChange,
}: {
  assignment: Assignment;
  initialSubmission: Submission | null;
  onSubmittedChange: (submitted: boolean) => void;
}) {
  const { t } = useLanguage();
  const L = t.learn;

  const [submission, setSubmission] = useState<Submission | null>(initialSubmission);
  const [code, setCode] = useState<string>(initialSubmission?.code ?? assignment.starterCode ?? "");
  const [stdin, setStdin] = useState("");
  const [showStdin, setShowStdin] = useState(false);
  const [pending, setPending] = useState<null | "save" | "run" | "submit">(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const [output, setOutput] = useState<CodeRunResult | null>(null);
  const [history, setHistory] = useState<CodeRunHistoryItem[]>([]);
  const [tests, setTests] = useState<AssignmentTestsResponse | null>(null);
  const [grade, setGrade] = useState<CodeGradeResult | null>(null);

  const notify = useRef(onSubmittedChange);
  useEffect(() => {
    notify.current = onSubmittedChange;
  });

  const editable =
    submission == null || submission.status === "draft" || submission.status === "failed";
  const isPassed = submission?.status === "passed";
  const isFailed = submission?.status === "failed";
  const lang = assignment.language ?? "plaintext";
  const runnable = lang !== "plaintext";

  const refresh = useCallback(async () => {
    try {
      const [ts, hist] = await Promise.all([
        getAssignmentTests(assignment.id).catch(() => null),
        getCodeRuns(assignment.id).catch(() => [] as CodeRunHistoryItem[]),
      ]);
      setTests(ts);
      setHistory(hist);
    } catch {
      /* non-fatal */
    }
  }, [assignment.id]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void refresh();
  }, [refresh]);

  function fail(err: unknown) {
    setError(err instanceof ApiError ? err.message : L.loadError);
  }

  async function persist() {
    return saveSubmissionDraft(assignment.id, { code });
  }

  async function save() {
    setPending("save");
    setNotice(null);
    setError(null);
    try {
      setSubmission(await persist());
      setNotice(L.saved);
    } catch (err) {
      fail(err);
    } finally {
      setPending(null);
    }
  }

  async function run(withStdin?: string) {
    setPending("run");
    setNotice(null);
    setError(null);
    setOutput(null);
    try {
      const res = await runCode(assignment.id, code, withStdin ?? stdin);
      setOutput(res);
      await refresh();
    } catch (err) {
      if (err instanceof ApiError && err.status === 503) setError(L.runnerUnavailable);
      else if (err instanceof ApiError && err.code === "CONFLICT") setError(L.runThrottled);
      else fail(err);
    } finally {
      setPending(null);
    }
  }

  async function submit() {
    setPending("submit");
    setNotice(null);
    setError(null);
    try {
      if (tests?.hasTests) {
        const res = await submitCodeForGrading(assignment.id, code);
        setGrade(res);
        setSubmission((s) =>
          s
            ? { ...s, status: res.status, score: res.score, teacherFeedback: res.feedback }
            : s
        );
        notify.current(res.passed);
        await refresh();
      } else {
        await persist();
        const next = await submitAssignment(assignment.id);
        setSubmission(next);
        notify.current(true);
        setNotice(L.submittedNotice);
      }
    } catch (err) {
      if (err instanceof ApiError && err.status === 503) setError(L.runnerUnavailable);
      else fail(err);
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
          <strong>{L.expectedOutput}:</strong> <code>{assignment.expectedOutput}</code>
        </p>
      )}

      {(isPassed || isFailed) && (
        <div className={`review-result ${isPassed ? "review-result-passed" : "review-result-failed"}`}>
          <p className="review-result-head">
            {isPassed ? `✓ ${L.statusPassed}` : L.statusFailed}
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
        <label className="assignment-label">{L.yourCode}</label>
        {editable && assignment.starterCode != null && (
          <button
            type="button"
            className="admin-link"
            onClick={() => setCode(assignment.starterCode ?? "")}
            disabled={pending !== null}
          >
            {L.resetToStarter}
          </button>
        )}
      </div>

      <CodeEditor
        value={code}
        onChange={setCode}
        language={lang}
        readOnly={!editable || pending !== null}
        ariaLabel={L.yourCode}
      />

      {runnable && (
        <div className="runner-controls">
          <button
            type="button"
            className="admin-link"
            onClick={() => setShowStdin((v) => !v)}
          >
            {L.stdinLabel} {showStdin ? "▲" : "▼"}
          </button>
          {showStdin && (
            <textarea
              className="assignment-input runner-stdin"
              value={stdin}
              onChange={(e) => setStdin(e.target.value)}
              rows={2}
              placeholder={L.stdinHint}
              spellCheck={false}
            />
          )}
        </div>
      )}

      {error && (
        <p className="auth-error" role="alert">
          {error}
        </p>
      )}
      {notice && !error && <p className="assignment-notice">{notice}</p>}

      <div className="assignment-actions">
        {runnable && (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => run()}
            disabled={pending !== null || !code.trim()}
          >
            {pending === "run" ? L.running : `▶ ${L.run}`}
          </Button>
        )}
        {editable && (
          <>
            <Button type="button" variant="ghost" size="sm" onClick={save} disabled={pending !== null}>
              {pending === "save" ? L.saving : L.saveDraft}
            </Button>
            <Button
              type="button"
              variant="primary"
              size="sm"
              onClick={submit}
              disabled={pending !== null || !code.trim()}
            >
              {pending === "submit"
                ? tests?.hasTests
                  ? L.grading
                  : L.submitting
                : tests?.hasTests
                  ? L.submitForGrading
                  : L.submit}
            </Button>
          </>
        )}
      </div>

      {output && <OutputPanel output={output} />}

      {grade && <GradePanel grade={grade} points={assignment.points} />}

      {tests && tests.visible.length > 0 && (
        <details className="runner-tests">
          <summary>
            {L.sampleTests} ({tests.visible.length}
            {tests.total > tests.visible.length ? ` / ${tests.total}` : ""})
          </summary>
          <ul>
            {tests.visible.map((tc) => (
              <li key={tc.id}>
                <div className="runner-test-head">
                  <strong>{tc.name}</strong>
                  {runnable && (
                    <button
                      type="button"
                      className="admin-link"
                      onClick={() => {
                        setStdin(tc.stdin);
                        setShowStdin(true);
                        void run(tc.stdin);
                      }}
                      disabled={pending !== null}
                    >
                      ▶ {L.run}
                    </button>
                  )}
                </div>
                {tc.stdin && (
                  <pre className="runner-io">
                    <span>stdin</span>
                    {tc.stdin}
                  </pre>
                )}
                <pre className="runner-io">
                  <span>{L.expectedLabel}</span>
                  {tc.expectedStdout}
                </pre>
              </li>
            ))}
          </ul>
        </details>
      )}

      {history.length > 0 && (
        <details className="runner-history">
          <summary>
            {L.runHistory} ({history.length})
          </summary>
          <ul>
            {history.map((h) => (
              <li key={h.runId}>
                <span className={`runner-status runner-status-${h.status}`}>{h.status}</span>
                <span>{h.kind === "grade" ? L.autoGraded : ""}</span>
                {h.durationMs != null && <span>{h.durationMs} ms</span>}
                <span className="runner-history-time">
                  {new Date(h.createdAt).toLocaleTimeString()}
                </span>
              </li>
            ))}
          </ul>
        </details>
      )}
    </div>
  );
}

function OutputPanel({ output }: { output: CodeRunResult }) {
  const { t } = useLanguage();
  const L = t.learn;
  return (
    <div className="runner-output">
      <div className="runner-output-head">
        <span>{L.runOutput}</span>
        {output.timedOut && <span className="runner-badge runner-badge-warn">{L.runTimedOut}</span>}
        {output.truncated && <span className="runner-badge">{L.outputTruncated}</span>}
        {output.exitCode != null && !output.timedOut && (
          <span className={`runner-badge ${output.exitCode === 0 ? "runner-badge-ok" : "runner-badge-warn"}`}>
            {L.exitCode}: {output.exitCode}
          </span>
        )}
        {output.durationMs != null && <span className="runner-badge">{output.durationMs} ms</span>}
      </div>
      {output.stdout ? (
        <pre className="runner-stream">{output.stdout}</pre>
      ) : (
        <pre className="runner-stream runner-stream-empty">{L.noOutput}</pre>
      )}
      {output.stderr && <pre className="runner-stream runner-stream-err">{output.stderr}</pre>}
    </div>
  );
}

function GradePanel({ grade, points }: { grade: CodeGradeResult; points: number }) {
  const { t } = useLanguage();
  const L = t.learn;
  return (
    <div className={`runner-grade ${grade.passed ? "runner-grade-pass" : "runner-grade-fail"}`}>
      <p className="runner-grade-head">
        {grade.passed ? `✓ ${L.statusPassed}` : L.statusFailed} — {grade.testsPassed}/{grade.testsTotal}{" "}
        {L.testsPassed} ({grade.percent}%)
        {grade.score != null && (
          <span className="runner-grade-score">
            {" "}
            · {grade.score} / {points}
          </span>
        )}
      </p>
      <ul className="runner-grade-list">
        {grade.outcomes.map((o) => (
          <li key={o.testId} className={o.passed ? "runner-mark-ok" : "runner-mark-bad"}>
            {o.passed ? "✓" : "✗"} {o.name}
            {o.hidden && <span className="runner-hidden-tag">{L.hiddenTest}</span>}
            {o.timedOut && <span className="runner-badge runner-badge-warn">{L.runTimedOut}</span>}
            {!o.passed && !o.hidden && (o.expected != null || o.got != null) && (
              <div className="runner-diff">
                {o.stdin ? (
                  <pre className="runner-io">
                    <span>stdin</span>
                    {o.stdin}
                  </pre>
                ) : null}
                <pre className="runner-io">
                  <span>{L.expectedLabel}</span>
                  {o.expected}
                </pre>
                <pre className="runner-io runner-io-got">
                  <span>{L.gotLabel}</span>
                  {o.got || "—"}
                </pre>
                {o.stderr ? <pre className="runner-stream runner-stream-err">{o.stderr}</pre> : null}
              </div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}
