"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { getTeacherSubmissions } from "@/lib/api";
import { SubmissionBadge } from "@/components/ui/SubmissionBadge";
import { Button } from "@/components/ui/Button";
import type { ListMeta, SubmissionStatus, TeacherSubmissionListItem } from "@/types";

type Tab = "submitted" | "checking" | "passed" | "failed" | "all";

const TABS: Tab[] = ["submitted", "checking", "passed", "failed", "all"];
const LIMIT = 20;

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; items: TeacherSubmissionListItem[]; meta: ListMeta };

export function TeacherSubmissions({ initialStatus }: { initialStatus?: SubmissionStatus }) {
  const { t } = useLanguage();
  const [tab, setTab] = useState<Tab>(
    initialStatus && initialStatus !== "draft" ? initialStatus : "submitted"
  );
  const [page, setPage] = useState(1);
  const [state, setState] = useState<State>({ kind: "loading" });

  const tabLabel: Record<Tab, string> = {
    submitted: t.teach.tabPending,
    checking: t.teach.tabChecking,
    passed: t.teach.tabPassed,
    failed: t.teach.tabFailed,
    all: t.teach.tabAll,
  };

  const load = useCallback(async () => {
    setState({ kind: "loading" });
    try {
      const res = await getTeacherSubmissions({
        status: tab === "all" ? undefined : tab,
        page,
        limit: LIMIT,
      });
      setState({ kind: "ready", items: res.data, meta: res.meta });
    } catch {
      setState({ kind: "error" });
    }
  }, [tab, page]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  function selectTab(next: Tab) {
    setTab(next);
    setPage(1);
  }

  const totalPages =
    state.kind === "ready" ? Math.max(1, Math.ceil(state.meta.total / state.meta.limit)) : 1;

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{t.teach.dashTitle}</span>
            <h1 className="student-dash-title">{t.teach.queueTitle}</h1>
          </div>
          <Link href="/teacher" className="student-viewall">
            {t.teach.backToDashboard}
          </Link>
        </div>

        <div className="teacher-tabs" role="tablist">
          {TABS.map((tb) => (
            <button
              key={tb}
              type="button"
              role="tab"
              aria-selected={tab === tb}
              className={`teacher-tab${tab === tb ? " active" : ""}`}
              onClick={() => selectTab(tb)}
            >
              {tabLabel[tb]}
            </button>
          ))}
        </div>

        {state.kind === "loading" && <p className="filter-empty">{t.teach.loading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.teach.loadError}</p>}

        {state.kind === "ready" && state.items.length === 0 && (
          <p className="filter-empty">{t.teach.allReviewed}</p>
        )}

        {state.kind === "ready" && state.items.length > 0 && (
          <>
            <div className="teacher-table-wrap">
              <table className="teacher-table">
                <thead>
                  <tr>
                    <th>{t.teach.student}</th>
                    <th>{t.teach.course}</th>
                    <th>{t.teach.lesson}</th>
                    <th>{t.teach.assignment}</th>
                    <th>{t.teach.submittedAt}</th>
                    <th>{t.learn.statusDraft}</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  {state.items.map((s) => (
                    <tr key={s.id}>
                      <td data-label={t.teach.student}>
                        <span className="teacher-cell-title">
                          {s.student.firstName} {s.student.lastName ?? ""}
                        </span>
                      </td>
                      <td data-label={t.teach.course}>{s.course.title}</td>
                      <td data-label={t.teach.lesson}>{s.lesson.title}</td>
                      <td data-label={t.teach.assignment}>{s.assignment.title}</td>
                      <td data-label={t.teach.submittedAt}>{formatDate(s.submittedAt)}</td>
                      <td data-label={t.learn.statusDraft}>
                        <SubmissionBadge status={s.status} />
                      </td>
                      <td>
                        <Link href={`/teacher/submissions/${s.id}`} className="teacher-row-link">
                          {t.teach.review}
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {totalPages > 1 && (
              <div className="teacher-pager">
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  disabled={page <= 1}
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                >
                  {t.teach.prevPage}
                </Button>
                <span className="teacher-pager-info">
                  {page} / {totalPages}
                </span>
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  disabled={page >= totalPages}
                  onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                >
                  {t.teach.nextPage}
                </Button>
              </div>
            )}
          </>
        )}
      </div>
    </section>
  );
}

function formatDate(iso: string | null): string {
  if (!iso) return "—";
  const d = new Date(iso);
  return d.toLocaleDateString(undefined, { day: "2-digit", month: "short" }) +
    " " +
    d.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" });
}
