"use client";

import { useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { getParentChildren } from "@/lib/api";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Button } from "@/components/ui/Button";
import type { ParentChildListItem } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; children: ParentChildListItem[] };

export function ParentDashboard() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    getParentChildren()
      .then((children) => !cancelled && setState({ kind: "ready", children }))
      .catch(() => !cancelled && setState({ kind: "error" }));
    return () => {
      cancelled = true;
    };
  }, []);

  const greeting = user ? t.auth.welcome.replace("{name}", user.firstName) : t.family.dashTitle;

  return (
    <section className="section">
      <div className="container">
        <span className="eyebrow">{t.family.dashTitle}</span>
        <h1 className="student-dash-title">{greeting}</h1>
        <p className="teacher-meta">{t.family.readOnlyNote}</p>

        {state.kind === "loading" && <p className="filter-empty">{t.family.loading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.family.loadError}</p>}

        {state.kind === "ready" && state.children.length === 0 && (
          <p className="filter-empty">{t.family.noChildren}</p>
        )}

        {state.kind === "ready" && state.children.length > 0 && (
          <>
            <h2 className="teacher-section-title">{t.family.myChildren}</h2>
            <div className="course-grid">
              {state.children.map((c) => (
                <article className="course-card" key={c.child.id}>
                  <h3>
                    {c.child.firstName} {c.child.lastName ?? ""}
                  </h3>
                  <p className="student-card-desc">
                    {c.coursesCount} {t.family.courses}
                  </p>
                  <ProgressBar
                    percent={c.overallProgressPercent}
                    label={t.family.overallProgress}
                  />
                  <p className="family-badges">
                    {c.pendingReview > 0 && (
                      <span className="teacher-pending-badge">
                        {c.pendingReview} {t.family.pendingReview}
                      </span>
                    )}
                    {c.needsWork > 0 && (
                      <span className="submission-badge sb-failed">
                        {c.needsWork} {t.family.needsWork}
                      </span>
                    )}
                  </p>
                  <Button
                    href={`/parent/children/${c.child.id}`}
                    variant="primary"
                    size="sm"
                    className="course-btn"
                  >
                    {t.family.openChild}
                  </Button>
                </article>
              ))}
            </div>
          </>
        )}
      </div>
    </section>
  );
}
