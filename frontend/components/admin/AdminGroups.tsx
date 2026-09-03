"use client";

import { useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { adminApi, ApiError } from "@/lib/api";
import { EntityManager, type FieldDef } from "@/components/admin/EntityManager";
import type { AdminCourse, AdminGroup, AdminGroupStudent, AdminUser } from "@/types";

const STATUSES = ["draft", "active", "completed", "cancelled"];

export function AdminGroups() {
  const { t } = useLanguage();
  const a = t.admin;
  const [courses, setCourses] = useState<AdminCourse[]>([]);
  const [teachers, setTeachers] = useState<AdminUser[]>([]);
  const [manage, setManage] = useState<AdminGroup | null>(null);

  useEffect(() => {
    let cancelled = false;
    Promise.all([adminApi.courses.list(), adminApi.users.list({ role: "teacher", limit: 200 })])
      .then(([c, u]) => {
        if (cancelled) return;
        setCourses(c);
        setTeachers(u.data);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, []);

  const fields: FieldDef[] = [
    { key: "title", label: a.fTitle, required: true },
    {
      key: "courseId",
      label: a.fCourse,
      type: "select",
      numeric: true,
      required: true,
      options: courses.map((c) => ({ value: String(c.id), label: `${c.title} (#${c.id})` })),
    },
    {
      key: "teacherId",
      label: a.fTeacher,
      type: "select",
      numeric: true,
      required: true,
      options: teachers.map((u) => ({
        value: String(u.id),
        label: `${u.firstName} ${u.lastName ?? ""} (#${u.id})`,
      })),
    },
    {
      key: "status",
      label: a.fStatus,
      type: "select",
      options: STATUSES.map((s) => ({ value: s, label: s })),
    },
    { key: "description", label: a.fDescription, type: "textarea" },
    { key: "maxStudents", label: a.fMaxStudents, type: "number" },
    { key: "startDate", label: a.fStartDate, placeholder: "YYYY-MM-DD" },
    { key: "endDate", label: a.fEndDate, placeholder: "YYYY-MM-DD" },
  ];

  return (
    <>
      <h1 className="student-dash-title">{a.groupsTitle}</h1>

      <EntityManager<AdminGroup>
        title={a.groupsTitle}
        crud={adminApi.groups}
        fields={fields}
        newLabel={a.newGroup}
        rowId={(r) => r.id}
        rowValues={(r) => ({
          title: r.title,
          courseId: r.courseId,
          teacherId: r.teacherId,
          status: r.status,
          description: r.description,
          maxStudents: r.maxStudents,
          startDate: r.startDate ? r.startDate.slice(0, 10) : "",
          endDate: r.endDate ? r.endDate.slice(0, 10) : "",
        })}
        columns={[
          { label: "ID", render: (r) => r.id },
          { label: a.fTitle, render: (r) => <span className="teacher-cell-title">{r.title}</span> },
          { label: a.fCourse, render: (r) => r.courseTitle },
          { label: a.fTeacher, render: (r) => r.teacherName },
          { label: a.fStatus, render: (r) => <span className={`group-status group-status-${r.status}`}>{r.status}</span> },
          { label: a.students, render: (r) => r.studentCount },
          {
            label: a.manageStudents,
            render: (r) => (
              <button type="button" className="admin-link admin-link-strong" onClick={() => setManage(r)}>
                {a.manageStudents}
              </button>
            ),
          },
        ]}
      />

      {manage && <StudentManager group={manage} onClose={() => setManage(null)} />}
    </>
  );
}

function StudentManager({ group, onClose }: { group: AdminGroup; onClose: () => void }) {
  const { t } = useLanguage();
  const a = t.admin;
  const [rows, setRows] = useState<AdminGroupStudent[] | null>(null);
  const [sid, setSid] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  async function load() {
    try {
      setRows(await adminApi.groupStudents.list(group.id));
    } catch {
      setErr(a.loadError);
    }
  }

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect, react-hooks/exhaustive-deps
    void load();
  }, [group.id]);

  async function add() {
    const n = Number(sid);
    if (!n) return;
    setPending(true);
    setErr(null);
    try {
      await adminApi.groupStudents.add(group.id, n);
      setSid("");
      await load();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    } finally {
      setPending(false);
    }
  }

  async function remove(studentId: number) {
    setErr(null);
    try {
      await adminApi.groupStudents.remove(group.id, studentId);
      await load();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : a.loadError);
    }
  }

  return (
    <div className="admin-dialog-backdrop" onClick={onClose}>
      <div className="admin-dialog admin-dialog-wide" onClick={(e) => e.stopPropagation()}>
        <h3>
          {a.manageStudents}: {group.title}
        </h3>

        <form
          className="admin-inline-form"
          onSubmit={(e) => {
            e.preventDefault();
            void add();
          }}
        >
          <input
            type="number"
            placeholder={a.studentId}
            value={sid}
            onChange={(e) => setSid(e.target.value)}
          />
          <button type="submit" className="btn btn-primary btn-sm" disabled={pending || !sid}>
            {a.add}
          </button>
        </form>
        {err && <p className="auth-error">{err}</p>}

        {rows === null ? (
          <p className="filter-empty">{a.loading}</p>
        ) : rows.length === 0 ? (
          <p className="filter-empty">{a.nothing}</p>
        ) : (
          <ul className="admin-simple-list">
            {rows.map((s) => (
              <li key={s.studentId}>
                <span>
                  #{s.studentId} {s.firstName} {s.lastName ?? ""}
                  {s.email ? ` · ${s.email}` : ""}
                </span>
                <button type="button" className="admin-link admin-link-danger" onClick={() => void remove(s.studentId)}>
                  {a.remove}
                </button>
              </li>
            ))}
          </ul>
        )}

        <div className="admin-form-actions">
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            {a.cancel}
          </button>
        </div>
      </div>
    </div>
  );
}
