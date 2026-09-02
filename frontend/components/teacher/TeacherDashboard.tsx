"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { getTeacherDashboard, getTeacherGroups } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Button } from "@/components/ui/Button";
import type { TeacherDashboard as Dash, TeacherGroup } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; dash: Dash; groups: TeacherGroup[] };

export function TeacherDashboard() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [dash, groups] = await Promise.all([getTeacherDashboard(), getTeacherGroups()]);
        if (!cancelled) setState({ kind: "ready", dash, groups });
      } catch {
        if (!cancelled) setState({ kind: "error" });
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const greeting = user ? t.auth.welcome.replace("{name}", user.firstName) : t.teach.dashTitle;

  return (
    <section className="section">
      <div className="container">
        <span className="eyebrow">{t.teach.dashTitle}</span>
        <h1 className="student-dash-title">{greeting}</h1>

        {state.kind === "loading" && <p className="filter-empty">{t.teach.loading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.teach.loadError}</p>}

        {state.kind === "ready" && (
          <>
            <div className="teacher-cards">
              <StatCard label={t.teach.cardGroups} value={state.dash.groupsCount} />
              <StatCard label={t.teach.cardStudents} value={state.dash.studentsCount} />
              <Link href="/teacher/submissions?status=submitted" className="teacher-card-link">
                <StatCard label={t.teach.cardPending} value={state.dash.pendingSubmissions} accent />
              </Link>
              <StatCard label={t.teach.cardReviewed} value={state.dash.reviewedSubmissions} />
            </div>

            <div className="student-dash-head">
              <h2>{t.teach.myGroups}</h2>
              <Link href="/teacher/submissions" className="student-viewall">
                {t.teach.queueTitle}
              </Link>
            </div>

            {state.groups.length === 0 ? (
              <p className="filter-empty">{t.teach.groupsEmpty}</p>
            ) : (
              <div className="course-grid">
                {state.groups.map((g) => (
                  <article className="course-card" key={g.id}>
                    <div className="course-tag course-tag-neutral">{g.status}</div>
                    <h3>{g.title}</h3>
                    <p className="student-card-desc">{g.course.title}</p>
                    <p className="teacher-meta">
                      {g.studentCount} {t.teach.studentsCount}
                    </p>
                    <ProgressBar percent={g.avgProgressPercent} label={t.teach.avgProgress} />
                    <Button
                      href={`/teacher/groups/${g.id}`}
                      variant="primary"
                      size="sm"
                      className="course-btn"
                    >
                      {t.teach.openGroup}
                    </Button>
                  </article>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </section>
  );
}

function StatCard({ label, value, accent }: { label: string; value: number; accent?: boolean }) {
  return (
    <div className={`teacher-stat${accent ? " teacher-stat-accent" : ""}`}>
      <span className="teacher-stat-value">{value}</span>
      <span className="teacher-stat-label">{label}</span>
    </div>
  );
}
