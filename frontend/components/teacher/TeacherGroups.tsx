"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { getTeacherGroups } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import type { TeacherGroup } from "@/types";

type State = { kind: "loading" } | { kind: "error" } | { kind: "ready"; groups: TeacherGroup[] };

export function TeacherGroups() {
  const { t } = useLanguage();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    getTeacherGroups()
      .then((groups) => !cancelled && setState({ kind: "ready", groups }))
      .catch(() => !cancelled && setState({ kind: "error" }));
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{t.teach.dashTitle}</span>
            <h1 className="student-dash-title">{t.teach.myGroups}</h1>
          </div>
          <Link href="/teacher" className="student-viewall">
            {t.teach.backToDashboard}
          </Link>
        </div>

        {state.kind === "loading" && <p className="filter-empty">{t.teach.loading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.teach.loadError}</p>}
        {state.kind === "ready" && state.groups.length === 0 && (
          <p className="filter-empty">{t.teach.groupsEmpty}</p>
        )}

        {state.kind === "ready" && state.groups.length > 0 && (
          <div className="teacher-table-wrap">
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>{t.teach.myGroups}</th>
                  <th>{t.teach.course}</th>
                  <th>{t.teach.students}</th>
                  <th>{t.teach.progress}</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {state.groups.map((g) => (
                  <tr key={g.id}>
                    <td data-label={t.teach.myGroups}>
                      <span className="teacher-cell-title">{g.title}</span>
                      <span className={`group-status group-status-${g.status}`}>{g.status}</span>
                    </td>
                    <td data-label={t.teach.course}>{g.course.title}</td>
                    <td data-label={t.teach.students}>{g.studentCount}</td>
                    <td data-label={t.teach.progress} className="teacher-cell-progress">
                      <ProgressBar percent={g.avgProgressPercent} label="" />
                    </td>
                    <td>
                      <Link href={`/teacher/groups/${g.id}`} className="teacher-row-link">
                        {t.teach.openGroup}
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
