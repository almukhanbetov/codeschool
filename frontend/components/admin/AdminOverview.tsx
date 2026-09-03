"use client";

import { useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { adminApi } from "@/lib/api";
import type { AdminOverview as Overview } from "@/types";

export function AdminOverview() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [state, setState] = useState<{ kind: "loading" } | { kind: "error" } | { kind: "ready"; o: Overview }>({
    kind: "loading",
  });

  useEffect(() => {
    let cancelled = false;
    adminApi
      .overview()
      .then((o) => !cancelled && setState({ kind: "ready", o }))
      .catch(() => !cancelled && setState({ kind: "error" }));
    return () => {
      cancelled = true;
    };
  }, []);

  const a = t.admin;
  const greeting = user ? t.auth.welcome.replace("{name}", user.firstName) : a.title;

  if (state.kind === "loading") return <p className="filter-empty">{a.loading}</p>;
  if (state.kind === "error") return <p className="auth-error">{a.loadError}</p>;

  const { o } = state;
  const roleTotal = Object.values(o.users).reduce((s, n) => s + n, 0);

  const cards: { label: string; value: number }[] = [
    { label: a.ovUsers, value: roleTotal },
    { label: a.ovActive, value: o.activeUsers },
    { label: a.ovPrograms, value: o.programs },
    { label: a.ovCourses, value: o.courses },
    { label: a.ovPublished, value: o.publishedCourses },
    { label: a.ovGroups, value: o.groups },
    { label: a.ovPending, value: o.pendingSubmissions },
    { label: a.ovLinks, value: o.parentLinks },
  ];

  return (
    <>
      <h1 className="student-dash-title">{greeting}</h1>
      <div className="teacher-cards admin-cards">
        {cards.map((c) => (
          <div className="teacher-stat" key={c.label}>
            <span className="teacher-stat-value">{c.value}</span>
            <span className="teacher-stat-label">{c.label}</span>
          </div>
        ))}
      </div>
      <div className="admin-role-breakdown">
        {(["student", "teacher", "parent", "admin"] as const).map((r) => (
          <span key={r} className="admin-role-pill">
            {r}: <strong>{o.users[r] ?? 0}</strong>
          </span>
        ))}
      </div>
    </>
  );
}
