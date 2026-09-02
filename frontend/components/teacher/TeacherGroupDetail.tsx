"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { ApiError, getTeacherGroup, getTeacherGroupStudents } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Button } from "@/components/ui/Button";
import type { TeacherGroupDetail as Detail, TeacherGroupStudent } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notFound" }
  | { kind: "error" }
  | { kind: "ready"; group: Detail; students: TeacherGroupStudent[] };

export function TeacherGroupDetail({ groupId }: { groupId: number }) {
  const { t } = useLanguage();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [group, students] = await Promise.all([
          getTeacherGroup(groupId),
          getTeacherGroupStudents(groupId),
        ]);
        if (!cancelled) setState({ kind: "ready", group, students });
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
  }, [groupId]);

  if (state.kind === "loading") return <Centered>{t.teach.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.teach.loadError}</Centered>;
  if (state.kind === "notFound") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.teach.loadError}</p>
          <Button href="/teacher/groups" variant="primary">
            {t.teach.backToGroups}
          </Button>
        </div>
      </section>
    );
  }

  const { group, students } = state;

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{group.course.title}</span>
            <h1 className="student-dash-title">{group.title}</h1>
            <p className="teacher-meta">
              {group.studentCount} {t.teach.studentsCount}
              {" · "}
              <span className={`group-status group-status-${group.status}`}>{group.status}</span>
            </p>
          </div>
          <Link href="/teacher/groups" className="student-viewall">
            {t.teach.backToGroups}
          </Link>
        </div>

        {students.length === 0 ? (
          <p className="filter-empty">—</p>
        ) : (
          <div className="teacher-table-wrap">
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>{t.teach.student}</th>
                  <th>{t.teach.progress}</th>
                  <th>{t.teach.pending}</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {students.map((s) => (
                  <tr key={s.student.id}>
                    <td data-label={t.teach.student}>
                      <span className="teacher-cell-title">
                        {s.student.firstName} {s.student.lastName ?? ""}
                      </span>
                    </td>
                    <td data-label={t.teach.progress} className="teacher-cell-progress">
                      <ProgressBar
                        percent={s.progress.progressPercent}
                        label={`${s.progress.completedLessons}/${s.progress.totalLessons}`}
                      />
                    </td>
                    <td data-label={t.teach.pending}>
                      {s.pendingSubmissions > 0 ? (
                        <span className="teacher-pending-badge">{s.pendingSubmissions}</span>
                      ) : (
                        "—"
                      )}
                    </td>
                    <td>
                      <Link
                        href={`/teacher/groups/${groupId}/students/${s.student.id}`}
                        className="teacher-row-link"
                      >
                        {t.teach.viewStudent}
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
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
