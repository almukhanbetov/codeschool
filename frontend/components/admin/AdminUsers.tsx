"use client";

import { useMemo, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { adminApi, ApiError } from "@/lib/api";
import { EntityManager, type FieldDef } from "@/components/admin/EntityManager";
import type { AdminUser } from "@/types";

const ROLES = ["student", "teacher", "parent", "admin"] as const;

export function AdminUsers() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const a = t.admin;
  const [role, setRole] = useState("");
  const [active, setActive] = useState("");
  const [search, setSearch] = useState("");
  const [pwFor, setPwFor] = useState<AdminUser | null>(null);

  const query = useMemo(
    () => ({ role, active, search: search.trim(), limit: 200 }),
    [role, active, search]
  );

  const crud = useMemo(
    () => ({
      list: (q?: Record<string, string | number | boolean | undefined>) =>
        adminApi.users.list(q ?? {}).then((r) => r.data),
      create: (body: unknown) => adminApi.users.create(body),
      update: (id: number, body: unknown) => adminApi.users.update(id, body),
      remove: (id: number) => adminApi.users.remove(id),
    }),
    []
  );

  const fields: FieldDef[] = [
    { key: "firstName", label: a.fFirstName, required: true },
    { key: "lastName", label: a.fLastName },
    { key: "email", label: a.fEmail, type: "text" },
    { key: "phone", label: a.fPhone, type: "text" },
    {
      key: "role",
      label: a.fRole,
      type: "select",
      required: true,
      options: ROLES.map((r) => ({ value: r, label: r })),
    },
    { key: "password", label: a.fPassword, type: "password", required: true, createOnly: true },
    { key: "isActive", label: a.fActive, type: "bool" },
  ];

  return (
    <>
      <h1 className="student-dash-title">{a.usersTitle}</h1>

      <div className="admin-filters">
        <label className="admin-field">
          <span>{a.filterRole}</span>
          <select value={role} onChange={(e) => setRole(e.target.value)}>
            <option value="">{a.all}</option>
            {ROLES.map((r) => (
              <option key={r} value={r}>
                {r}
              </option>
            ))}
          </select>
        </label>
        <label className="admin-field">
          <span>{a.filterActive}</span>
          <select value={active} onChange={(e) => setActive(e.target.value)}>
            <option value="">{a.all}</option>
            <option value="true">{a.activate}</option>
            <option value="false">{a.deactivate}</option>
          </select>
        </label>
        <label className="admin-field admin-field-grow">
          <span>{a.search}</span>
          <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder={a.search} />
        </label>
      </div>

      <EntityManager<AdminUser>
        title={a.usersTitle}
        crud={crud}
        query={query}
        fields={fields}
        newLabel={a.newUser}
        rowId={(r) => r.id}
        rowValues={(r) => ({
          firstName: r.firstName,
          lastName: r.lastName,
          email: r.email,
          phone: r.phone,
          role: r.role,
          isActive: r.isActive,
        })}
        columns={[
          { label: "ID", render: (r) => r.id },
          {
            label: a.fFirstName,
            render: (r) => (
              <span className="teacher-cell-title">
                {r.firstName} {r.lastName ?? ""}
              </span>
            ),
          },
          { label: a.fEmail, render: (r) => r.email ?? r.phone ?? "—" },
          { label: a.fRole, render: (r) => <span className={`admin-role-tag admin-role-${r.role}`}>{r.role}</span> },
          {
            label: a.fActive,
            render: (r) => (r.isActive ? a.yes : <span className="admin-muted">{a.no}</span>),
          },
          {
            label: a.resetPassword,
            render: (r) =>
              r.id === user?.id ? (
                "—"
              ) : (
                <button type="button" className="admin-link" onClick={() => setPwFor(r)}>
                  {a.resetPassword}
                </button>
              ),
          },
        ]}
      />

      {pwFor && <PasswordDialog user={pwFor} onClose={() => setPwFor(null)} />}
    </>
  );
}

function PasswordDialog({ user, onClose }: { user: AdminUser; onClose: () => void }) {
  const { t } = useLanguage();
  const a = t.admin;
  const [pw, setPw] = useState("");
  const [pending, setPending] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  async function submit() {
    setPending(true);
    setErr(null);
    try {
      await adminApi.users.setPassword(user.id, pw);
      setDone(true);
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="admin-dialog-backdrop" onClick={onClose}>
      <div className="admin-dialog" onClick={(e) => e.stopPropagation()}>
        <h3>
          {a.resetPassword}: {user.firstName} {user.lastName ?? ""}
        </h3>
        {done ? (
          <>
            <p className="assignment-notice">{a.saved}</p>
            <div className="admin-form-actions">
              <button type="button" className="btn btn-primary btn-sm" onClick={onClose}>
                {a.cancel}
              </button>
            </div>
          </>
        ) : (
          <form
            onSubmit={(e) => {
              e.preventDefault();
              void submit();
            }}
          >
            <label className="admin-field">
              <span>{a.fPassword} *</span>
              <input type="password" value={pw} onChange={(e) => setPw(e.target.value)} autoFocus />
            </label>
            {err && <p className="auth-error">{err}</p>}
            <div className="admin-form-actions">
              <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
                {a.cancel}
              </button>
              <button type="submit" className="btn btn-primary btn-sm" disabled={pending || pw.length < 8}>
                {pending ? a.saving : a.save}
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
