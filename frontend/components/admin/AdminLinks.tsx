"use client";

import { useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { adminApi, ApiError } from "@/lib/api";
import type { AdminParentLink, AdminUser } from "@/types";

export function AdminLinks() {
  const { t } = useLanguage();
  const a = t.admin;
  const [rows, setRows] = useState<AdminParentLink[] | null>(null);
  const [parents, setParents] = useState<AdminUser[]>([]);
  const [students, setStudents] = useState<AdminUser[]>([]);
  const [parentId, setParentId] = useState("");
  const [childId, setChildId] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  async function load() {
    try {
      setRows(await adminApi.parentLinks.list());
    } catch {
      setErr(a.loadError);
    }
  }

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect, react-hooks/exhaustive-deps
    void load();
    Promise.all([
      adminApi.users.list({ role: "parent", limit: 200 }),
      adminApi.users.list({ role: "student", limit: 200 }),
    ])
      .then(([p, s]) => {
        setParents(p.data);
        setStudents(s.data);
      })
      .catch(() => {});
  }, []);

  async function add() {
    if (!parentId || !childId) return;
    setPending(true);
    setErr(null);
    try {
      await adminApi.parentLinks.create(Number(parentId), Number(childId));
      setParentId("");
      setChildId("");
      await load();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  async function remove(l: AdminParentLink) {
    setErr(null);
    try {
      await adminApi.parentLinks.remove(l.parentId, l.childId);
      await load();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    }
  }

  return (
    <>
      <h1 className="student-dash-title">{a.linksTitle}</h1>

      <form
        className="admin-form"
        onSubmit={(e) => {
          e.preventDefault();
          void add();
        }}
      >
        <label className="admin-field">
          <span>{a.parent} *</span>
          <select value={parentId} onChange={(e) => setParentId(e.target.value)}>
            <option value="">{a.none}</option>
            {parents.map((p) => (
              <option key={p.id} value={p.id}>
                #{p.id} {p.firstName} {p.lastName ?? ""}
              </option>
            ))}
          </select>
        </label>
        <label className="admin-field">
          <span>{a.child} *</span>
          <select value={childId} onChange={(e) => setChildId(e.target.value)}>
            <option value="">{a.none}</option>
            {students.map((s) => (
              <option key={s.id} value={s.id}>
                #{s.id} {s.firstName} {s.lastName ?? ""}
              </option>
            ))}
          </select>
        </label>
        {err && <p className="auth-error">{err}</p>}
        <div className="admin-form-actions">
          <button type="submit" className="btn btn-primary btn-sm" disabled={pending || !parentId || !childId}>
            {pending ? a.saving : a.newLink}
          </button>
        </div>
      </form>

      {rows === null ? (
        <p className="filter-empty">{a.loading}</p>
      ) : rows.length === 0 ? (
        <p className="filter-empty">{a.nothing}</p>
      ) : (
        <div className="teacher-table-wrap">
          <table className="teacher-table">
            <thead>
              <tr>
                <th>{a.parent}</th>
                <th>{a.child}</th>
                <th>{a.actions}</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((l) => (
                <tr key={`${l.parentId}-${l.childId}`}>
                  <td data-label={a.parent}>
                    #{l.parentId} {l.parentName}
                  </td>
                  <td data-label={a.child}>
                    #{l.childId} {l.childName}
                  </td>
                  <td data-label={a.actions}>
                    <button type="button" className="admin-link admin-link-danger" onClick={() => void remove(l)}>
                      {a.delete}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}
