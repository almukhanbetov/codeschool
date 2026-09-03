"use client";

import { useCallback, useEffect, useState, type ReactNode } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { ApiError } from "@/lib/api";

export interface FieldDef {
  key: string;
  label: string;
  type?: "text" | "textarea" | "number" | "bool" | "select" | "password";
  options?: { value: string; label: string }[];
  required?: boolean;
  createOnly?: boolean;
  placeholder?: string;
  /** for select fields whose value is a numeric id */
  numeric?: boolean;
}

export interface ColumnDef<Row> {
  label: string;
  render: (row: Row) => ReactNode;
}

export interface Crud<Row> {
  list: (query?: Record<string, string | number | boolean | undefined>) => Promise<Row[]>;
  create: (body: unknown) => Promise<Row>;
  update: (id: number, body: unknown) => Promise<Row>;
  remove: (id: number) => Promise<unknown>;
}

interface Props<Row> {
  title: string;
  crud: Crud<Row>;
  query?: Record<string, string | number | boolean | undefined>;
  fields: FieldDef[];
  columns: ColumnDef<Row>[];
  rowId: (row: Row) => number;
  rowValues: (row: Row) => Record<string, unknown>;
  fixed?: Record<string, unknown>;
  newLabel: string;
  onChanged?: () => void;
  extraAction?: { label: string; onClick: (row: Row) => void };
}

type FormState = Record<string, string | boolean>;

export function EntityManager<Row>({
  title,
  crud,
  query,
  fields,
  columns,
  rowId,
  rowValues,
  fixed,
  newLabel,
  onChanged,
  extraAction,
}: Props<Row>) {
  const { t } = useLanguage();
  const a = t.admin;
  const [rows, setRows] = useState<Row[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState<number | "new" | null>(null);
  const [form, setForm] = useState<FormState>({});
  const [pending, setPending] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const queryKey = JSON.stringify(query ?? {});

  const load = useCallback(async () => {
    try {
      setRows(await crud.list(query));
      setError(null);
    } catch {
      setError(a.loadError);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [crud, queryKey, a.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  function startNew() {
    const f: FormState = {};
    for (const fd of fields) f[fd.key] = fd.type === "bool" ? false : "";
    setForm(f);
    setFormError(null);
    setEditing("new");
  }

  function startEdit(row: Row) {
    const vals = rowValues(row);
    const f: FormState = {};
    for (const fd of fields) {
      if (fd.createOnly) continue;
      const v = vals[fd.key];
      f[fd.key] = fd.type === "bool" ? Boolean(v) : v == null ? "" : String(v);
    }
    setForm(f);
    setFormError(null);
    setEditing(rowId(row));
  }

  function buildBody(isNew: boolean): Record<string, unknown> {
    const body: Record<string, unknown> = isNew ? { ...(fixed ?? {}) } : {};
    for (const fd of fields) {
      if (!isNew && fd.createOnly) continue;
      const raw = form[fd.key];
      if (fd.type === "bool") {
        body[fd.key] = Boolean(raw);
      } else if (fd.type === "number") {
        const s = String(raw).trim();
        body[fd.key] = s === "" ? null : Number(s);
      } else if (fd.type === "select" && fd.numeric) {
        const s = String(raw).trim();
        if (s === "") {
          if (isNew) continue; // required select left blank on create → let the server reject
        } else {
          body[fd.key] = Number(s);
        }
      } else {
        body[fd.key] = String(raw);
      }
    }
    return body;
  }

  async function save() {
    setPending(true);
    setFormError(null);
    try {
      if (editing === "new") {
        await crud.create(buildBody(true));
      } else if (typeof editing === "number") {
        await crud.update(editing, buildBody(false));
      }
      setEditing(null);
      await load();
      onChanged?.();
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  async function del(id: number) {
    if (!window.confirm(a.confirmDelete)) return;
    try {
      await crud.remove(id);
      await load();
      onChanged?.();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : a.loadError);
    }
  }

  return (
    <div className="admin-section">
      <div className="admin-section-head">
        <h2>{title}</h2>
        {editing === null && (
          <Button type="button" variant="primary" size="sm" onClick={startNew}>
            {newLabel}
          </Button>
        )}
      </div>

      {error && <p className="auth-error">{error}</p>}

      {editing !== null && (
        <form
          className="admin-form"
          onSubmit={(e) => {
            e.preventDefault();
            void save();
          }}
        >
          {fields
            .filter((fd) => editing === "new" || !fd.createOnly)
            .map((fd) => (
              <label key={fd.key} className="admin-field">
                <span>
                  {fd.label}
                  {fd.required ? " *" : ""}
                </span>
                {fd.type === "bool" ? (
                  <input
                    type="checkbox"
                    checked={Boolean(form[fd.key])}
                    onChange={(e) => setForm((s) => ({ ...s, [fd.key]: e.target.checked }))}
                  />
                ) : fd.type === "select" ? (
                  <select
                    value={String(form[fd.key] ?? "")}
                    onChange={(e) => setForm((s) => ({ ...s, [fd.key]: e.target.value }))}
                  >
                    <option value="">{a.none}</option>
                    {fd.options?.map((o) => (
                      <option key={o.value} value={o.value}>
                        {o.label}
                      </option>
                    ))}
                  </select>
                ) : fd.type === "textarea" ? (
                  <textarea
                    rows={3}
                    value={String(form[fd.key] ?? "")}
                    placeholder={fd.placeholder}
                    onChange={(e) => setForm((s) => ({ ...s, [fd.key]: e.target.value }))}
                  />
                ) : (
                  <input
                    type={fd.type === "number" ? "number" : fd.type === "password" ? "password" : "text"}
                    value={String(form[fd.key] ?? "")}
                    placeholder={fd.placeholder}
                    onChange={(e) => setForm((s) => ({ ...s, [fd.key]: e.target.value }))}
                  />
                )}
              </label>
            ))}
          {formError && <p className="auth-error">{formError}</p>}
          <div className="admin-form-actions">
            <Button type="button" variant="ghost" size="sm" onClick={() => setEditing(null)}>
              {a.cancel}
            </Button>
            <Button type="submit" variant="primary" size="sm" disabled={pending}>
              {pending ? a.saving : a.save}
            </Button>
          </div>
        </form>
      )}

      {rows === null ? (
        <p className="filter-empty">{a.loading}</p>
      ) : rows.length === 0 ? (
        <p className="filter-empty">{a.nothing}</p>
      ) : (
        <div className="teacher-table-wrap">
          <table className="teacher-table">
            <thead>
              <tr>
                {columns.map((col) => (
                  <th key={col.label}>{col.label}</th>
                ))}
                <th>{a.actions}</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={rowId(row)}>
                  {columns.map((col) => (
                    <td key={col.label} data-label={col.label}>
                      {col.render(row)}
                    </td>
                  ))}
                  <td data-label={a.actions} className="admin-row-actions">
                    {extraAction && (
                      <button
                        type="button"
                        className="admin-link admin-link-strong"
                        onClick={() => extraAction.onClick(row)}
                      >
                        {extraAction.label}
                      </button>
                    )}
                    <button type="button" className="admin-link" onClick={() => startEdit(row)}>
                      {a.edit}
                    </button>
                    <button
                      type="button"
                      className="admin-link admin-link-danger"
                      onClick={() => void del(rowId(row))}
                    >
                      {a.delete}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
