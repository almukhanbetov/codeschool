"use client";

import { useCallback, useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { adminApi, ApiError } from "@/lib/api";
import type { AdminAssignment, AdminAssignmentTest } from "@/types";

export function AdminTestsEditor({
  assignment,
  onClose,
}: {
  assignment: AdminAssignment;
  onClose: () => void;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [rows, setRows] = useState<AdminAssignmentTest[] | null>(null);
  const [editing, setEditing] = useState<number | "new" | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setRows(await adminApi.tests.list(assignment.id));
      setError(null);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : a.loadError);
    }
  }, [assignment.id, a.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  async function remove(id: number) {
    if (!window.confirm(a.confirmDelete)) return;
    try {
      await adminApi.tests.remove(id);
      await load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : a.loadError);
    }
  }

  return (
    <div className="admin-dialog-backdrop" onClick={onClose}>
      <div className="admin-dialog admin-dialog-wide" onClick={(e) => e.stopPropagation()}>
        <h3>
          {a.testsEditorTitle}: {assignment.title}
        </h3>

        {assignment.assignmentType !== "code" ? (
          <p className="filter-empty">{a.testsNotCode}</p>
        ) : (
          <>
            {error && <p className="auth-error">{error}</p>}

            <div className="admin-section-head">
              <span className="admin-muted">
                {rows?.length ?? 0} {a.manageTests.toLowerCase()}
              </span>
              {editing === null && (
                <Button type="button" variant="primary" size="sm" onClick={() => setEditing("new")}>
                  {a.newTest}
                </Button>
              )}
            </div>

            {editing === "new" && (
              <TestForm
                onCancel={() => setEditing(null)}
                onSubmit={async (body) => {
                  await adminApi.tests.create(assignment.id, body);
                  setEditing(null);
                  await load();
                }}
              />
            )}

            <ul className="runner-admin-list">
              {(rows ?? []).map((tc) =>
                editing === tc.id ? (
                  <li key={tc.id}>
                    <TestForm
                      initial={tc}
                      onCancel={() => setEditing(null)}
                      onSubmit={async (body) => {
                        await adminApi.tests.update(tc.id, body);
                        setEditing(null);
                        await load();
                      }}
                    />
                  </li>
                ) : (
                  <li key={tc.id} className="runner-admin-card">
                    <div className="runner-admin-card-head">
                      <strong>{tc.name}</strong>
                      {tc.isHidden && <span className="runner-hidden-tag">{a.testHiddenBadge}</span>}
                      <span className="admin-muted">{a.fTestWeight}: {tc.weight}</span>
                      <span className="runner-admin-actions">
                        <button type="button" className="admin-link" onClick={() => setEditing(tc.id)}>
                          {a.edit}
                        </button>
                        <button
                          type="button"
                          className="admin-link admin-link-danger"
                          onClick={() => void remove(tc.id)}
                        >
                          {a.delete}
                        </button>
                      </span>
                    </div>
                    <pre className="runner-io">
                      <span>stdin</span>
                      {tc.stdin || "—"}
                    </pre>
                    <pre className="runner-io">
                      <span>{a.fTestExpected}</span>
                      {tc.expectedStdout || "—"}
                    </pre>
                  </li>
                )
              )}
            </ul>
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

function TestForm({
  initial,
  onCancel,
  onSubmit,
}: {
  initial?: AdminAssignmentTest;
  onCancel: () => void;
  onSubmit: (body: Record<string, unknown>) => Promise<void>;
}) {
  const { t } = useLanguage();
  const a = t.admin;
  const [name, setName] = useState(initial?.name ?? "");
  const [stdin, setStdin] = useState(initial?.stdin ?? "");
  const [expected, setExpected] = useState(initial?.expectedStdout ?? "");
  const [hidden, setHidden] = useState(initial?.isHidden ?? false);
  const [weight, setWeight] = useState(String(initial?.weight ?? 1));
  const [position, setPosition] = useState(String(initial?.position ?? 0));
  const [pending, setPending] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function submit() {
    setPending(true);
    setErr(null);
    try {
      await onSubmit({
        name,
        stdin,
        expectedStdout: expected,
        isHidden: hidden,
        weight: Number(weight) || 1,
        position: Number(position) || 0,
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
        <span>{a.fTestName} *</span>
        <input value={name} onChange={(e) => setName(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.fTestStdin}</span>
        <textarea rows={2} value={stdin} onChange={(e) => setStdin(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.fTestExpected}</span>
        <textarea rows={2} value={expected} onChange={(e) => setExpected(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.fTestHidden}</span>
        <input type="checkbox" checked={hidden} onChange={(e) => setHidden(e.target.checked)} />
      </label>
      <label className="admin-field">
        <span>{a.fTestWeight}</span>
        <input type="number" min={1} value={weight} onChange={(e) => setWeight(e.target.value)} />
      </label>
      <label className="admin-field">
        <span>{a.fPosition}</span>
        <input type="number" value={position} onChange={(e) => setPosition(e.target.value)} />
      </label>
      {err && <p className="auth-error">{err}</p>}
      <div className="admin-form-actions">
        <Button type="button" variant="ghost" size="sm" onClick={onCancel}>
          {a.cancel}
        </Button>
        <Button type="submit" variant="primary" size="sm" disabled={pending || !name.trim()}>
          {pending ? a.saving : a.save}
        </Button>
      </div>
    </form>
  );
}
