"use client";

import { useCallback, useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { adminApi, ApiError } from "@/lib/api";
import type {
  AdminAssignment,
  AdminQuiz,
  AdminQuizQuestion,
  AdminQuizSettings,
  QuizQuestionType,
} from "@/types";

const TYPES: QuizQuestionType[] = ["single_choice", "multiple_choice", "true_false"];

export function AdminQuizEditor({
  assignment,
  onClose,
}: {
  assignment: AdminAssignment;
  onClose: () => void;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [quiz, setQuiz] = useState<AdminQuiz | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setQuiz(await adminApi.quiz.get(assignment.id));
      setError(null);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : a.loadError);
    }
  }, [assignment.id, a.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  return (
    <div className="admin-dialog-backdrop" onClick={onClose}>
      <div className="admin-dialog admin-dialog-wide" onClick={(e) => e.stopPropagation()}>
        <h3>
          {a.quizEditorTitle}: {assignment.title}
        </h3>
        {error && <p className="auth-error">{error}</p>}

        {quiz && quiz.assignmentType !== "quiz" && <p className="filter-empty">{a.quizNotAQuiz}</p>}

        {quiz && quiz.assignmentType === "quiz" && (
          <>
            <SettingsForm
              assignmentId={assignment.id}
              settings={quiz.settings}
              onSaved={load}
            />
            <QuestionList quiz={quiz} onChanged={load} />
          </>
        )}

        <div className="admin-form-actions">
          <Button type="button" variant="ghost" size="sm" onClick={onClose}>
            {a.cancel}
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ================= settings ================= */

function SettingsForm({
  assignmentId,
  settings,
  onSaved,
}: {
  assignmentId: number;
  settings: AdminQuizSettings;
  onSaved: () => void;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [passPercent, setPassPercent] = useState(String(settings.passPercent));
  const [maxAttempts, setMaxAttempts] = useState(
    settings.maxAttempts == null ? "" : String(settings.maxAttempts)
  );
  const [showCorrect, setShowCorrect] = useState(settings.showCorrectAnswers);
  const [showExpl, setShowExpl] = useState(settings.showExplanations);
  const [pending, setPending] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function save() {
    setPending(true);
    setErr(null);
    try {
      await adminApi.quiz.updateSettings(assignmentId, {
        passPercent: Number(passPercent) || 0,
        maxAttempts: maxAttempts.trim() === "" ? null : Number(maxAttempts),
        showCorrectAnswers: showCorrect,
        showExplanations: showExpl,
      });
      onSaved();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  return (
    <form
      className="admin-form"
      onSubmit={(e) => {
        e.preventDefault();
        void save();
      }}
    >
      <h4>{a.quizSettings}</h4>
      <label className="admin-field">
        <span>{a.quizPassPercent}</span>
        <input type="number" min={0} max={100} value={passPercent} onChange={(e) => setPassPercent(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.quizMaxAttempts}</span>
        <input
          type="number"
          min={1}
          placeholder={a.quizMaxAttemptsHint}
          value={maxAttempts}
          onChange={(e) => setMaxAttempts(e.target.value)}
        />
      </label>
      <label className="admin-field">
        <span>{a.quizShowCorrect}</span>
        <input type="checkbox" checked={showCorrect} onChange={(e) => setShowCorrect(e.target.checked)} />
      </label>
      <label className="admin-field">
        <span>{a.quizShowExplanations}</span>
        <input type="checkbox" checked={showExpl} onChange={(e) => setShowExpl(e.target.checked)} />
      </label>
      {err && <p className="auth-error">{err}</p>}
      <div className="admin-form-actions">
        <Button type="submit" variant="primary" size="sm" disabled={pending}>
          {pending ? a.saving : a.save}
        </Button>
      </div>
    </form>
  );
}

/* ================= questions ================= */

function QuestionList({ quiz, onChanged }: { quiz: AdminQuiz; onChanged: () => void }) {
  const { t } = useLanguage();
  const a = t.admin;
  const [adding, setAdding] = useState(false);

  return (
    <div className="admin-section">
      <div className="admin-section-head">
        <h4>
          {a.quizQuestions} ({quiz.questions.length})
        </h4>
        {!adding && (
          <Button type="button" variant="primary" size="sm" onClick={() => setAdding(true)}>
            {a.quizAddQuestion}
          </Button>
        )}
      </div>

      {adding && (
        <QuestionForm
          onCancel={() => setAdding(false)}
          onSubmit={async (body) => {
            await adminApi.quiz.createQuestion(quiz.assignmentId, body);
            setAdding(false);
            onChanged();
          }}
        />
      )}

      <ol className="quiz-admin-list">
        {quiz.questions.map((q) => (
          <QuestionCard key={q.id} question={q} onChanged={onChanged} />
        ))}
      </ol>
    </div>
  );
}

function typeLabel(a: ReturnType<typeof useLanguage>["t"]["admin"], ty: QuizQuestionType) {
  return ty === "single_choice"
    ? a.quizSingleChoice
    : ty === "multiple_choice"
      ? a.quizMultipleChoice
      : a.quizTrueFalse;
}

function QuestionCard({
  question,
  onChanged,
}: {
  question: AdminQuizQuestion;
  onChanged: () => void;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [editing, setEditing] = useState(false);
  const [addingOption, setAddingOption] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function run(fn: () => Promise<unknown>) {
    setErr(null);
    try {
      await fn();
      onChanged();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    }
  }

  return (
    <li className={`quiz-admin-card${question.isActive ? "" : " quiz-admin-card-inactive"}`}>
      <div className="quiz-admin-card-head">
        <span className="quiz-admin-type">{typeLabel(a, question.questionType)}</span>
        <span>· {question.points} {t.quiz.points}</span>
        {!question.wellFormed && <span className="quiz-admin-warn">⚠ {a.quizNeedsFix}</span>}
        {!question.isActive && <span className="admin-muted">· {a.quizDeactivatedNote}</span>}
      </div>

      {editing ? (
        <QuestionForm
          initial={question}
          onCancel={() => setEditing(false)}
          onSubmit={async (body) => {
            await adminApi.quiz.updateQuestion(question.id, body);
            setEditing(false);
            onChanged();
          }}
        />
      ) : (
        <p className="quiz-admin-qtext">{question.questionText}</p>
      )}

      <ul className="quiz-admin-options">
        {question.options.map((o) => (
          <li key={o.id} className={o.isActive ? "" : "quiz-admin-opt-inactive"}>
            <label>
              <input
                type="checkbox"
                checked={o.isCorrect}
                onChange={(e) => void run(() => adminApi.quiz.updateOption(o.id, { isCorrect: e.target.checked }))}
              />
              {o.optionText}
            </label>
            <button
              type="button"
              className="admin-link admin-link-danger"
              onClick={() => void run(() => adminApi.quiz.deleteOption(o.id))}
            >
              {a.delete}
            </button>
          </li>
        ))}
      </ul>

      {addingOption ? (
        <OptionForm
          onCancel={() => setAddingOption(false)}
          onSubmit={async (body) => {
            await adminApi.quiz.createOption(question.id, body);
            setAddingOption(false);
            onChanged();
          }}
        />
      ) : (
        <div className="quiz-admin-card-actions">
          <button type="button" className="admin-link admin-link-strong" onClick={() => setAddingOption(true)}>
            {a.quizAddOption}
          </button>
          <button type="button" className="admin-link" onClick={() => setEditing((v) => !v)}>
            {a.edit}
          </button>
          <button
            type="button"
            className="admin-link admin-link-danger"
            onClick={() => void run(() => adminApi.quiz.deleteQuestion(question.id))}
          >
            {a.delete}
          </button>
        </div>
      )}
      {err && <p className="auth-error">{err}</p>}
    </li>
  );
}

function QuestionForm({
  initial,
  onCancel,
  onSubmit,
}: {
  initial?: AdminQuizQuestion;
  onCancel: () => void;
  onSubmit: (body: Record<string, unknown>) => Promise<void>;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [text, setText] = useState(initial?.questionText ?? "");
  const [type, setType] = useState<QuizQuestionType>(initial?.questionType ?? "single_choice");
  const [points, setPoints] = useState(String(initial?.points ?? 1));
  const [explanation, setExplanation] = useState(initial?.explanation ?? "");
  const [pending, setPending] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function submit() {
    setPending(true);
    setErr(null);
    try {
      await onSubmit({
        questionText: text,
        questionType: type,
        points: Number(points) || 1,
        explanation,
      });
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  return (
    <form
      className="admin-form"
      onSubmit={(e) => {
        e.preventDefault();
        void submit();
      }}
    >
      <label className="admin-field">
        <span>{a.quizQuestionText} *</span>
        <textarea rows={2} value={text} onChange={(e) => setText(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.quizQuestionType}</span>
        <select value={type} onChange={(e) => setType(e.target.value as QuizQuestionType)}>
          {TYPES.map((ty) => (
            <option key={ty} value={ty}>
              {typeLabel(a, ty)}
            </option>
          ))}
        </select>
      </label>
      <label className="admin-field">
        <span>{t.quiz.points}</span>
        <input type="number" min={1} value={points} onChange={(e) => setPoints(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.quizExplanation}</span>
        <textarea rows={2} value={explanation} onChange={(e) => setExplanation(e.target.value)} />
      </label>
      {err && <p className="auth-error">{err}</p>}
      <div className="admin-form-actions">
        <Button type="button" variant="ghost" size="sm" onClick={onCancel}>
          {a.cancel}
        </Button>
        <Button type="submit" variant="primary" size="sm" disabled={pending}>
          {pending ? a.saving : a.save}
        </Button>
      </div>
    </form>
  );
}

function OptionForm({
  onCancel,
  onSubmit,
}: {
  onCancel: () => void;
  onSubmit: (body: Record<string, unknown>) => Promise<void>;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [text, setText] = useState("");
  const [correct, setCorrect] = useState(false);
  const [pending, setPending] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function submit() {
    setPending(true);
    setErr(null);
    try {
      await onSubmit({ optionText: text, isCorrect: correct });
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  return (
    <form
      className="admin-inline-form"
      onSubmit={(e) => {
        e.preventDefault();
        void submit();
      }}
    >
      <input placeholder={a.quizOptionText} value={text} onChange={(e) => setText(e.target.value)} />
      <label className="quiz-admin-correct-toggle">
        <input type="checkbox" checked={correct} onChange={(e) => setCorrect(e.target.checked)} />
        {a.quizCorrect}
      </label>
      <Button type="submit" variant="primary" size="sm" disabled={pending || !text.trim()}>
        {a.add}
      </Button>
      <Button type="button" variant="ghost" size="sm" onClick={onCancel}>
        {a.cancel}
      </Button>
      {err && <p className="auth-error">{err}</p>}
    </form>
  );
}
