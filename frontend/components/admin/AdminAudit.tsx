"use client";

import { useCallback, useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { adminApi } from "@/lib/api";
import type { AdminAuditRow } from "@/types";

const LIMIT = 30;

export function AdminAudit() {
  const { t } = useLanguage();
  const a = t.admin;
  const [page, setPage] = useState(1);
  const [state, setState] = useState<
    { kind: "loading" } | { kind: "error" } | { kind: "ready"; rows: AdminAuditRow[]; total: number }
  >({ kind: "loading" });

  const load = useCallback(async () => {
    try {
      const res = await adminApi.audit(page, LIMIT);
      setState({ kind: "ready", rows: res.data, total: res.meta.total });
    } catch {
      setState({ kind: "error" });
    }
  }, [page]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  const totalPages = state.kind === "ready" ? Math.max(1, Math.ceil(state.total / LIMIT)) : 1;

  return (
    <>
      <h1 className="student-dash-title">{a.auditTitle}</h1>

      {state.kind === "loading" && <p className="filter-empty">{a.loading}</p>}
      {state.kind === "error" && <p className="auth-error">{a.loadError}</p>}

      {state.kind === "ready" && (
        <>
          <div className="teacher-table-wrap">
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>{a.auditWhen}</th>
                  <th>{a.auditWho}</th>
                  <th>{a.auditAction}</th>
                  <th>{a.auditEntity}</th>
                  <th>{a.auditSummary}</th>
                </tr>
              </thead>
              <tbody>
                {state.rows.map((r) => (
                  <tr key={r.id}>
                    <td data-label={a.auditWhen}>{new Date(r.createdAt).toLocaleString()}</td>
                    <td data-label={a.auditWho}>
                      #{r.adminId} {r.adminName}
                    </td>
                    <td data-label={a.auditAction}>
                      <span className={`admin-action-tag admin-action-${r.action}`}>{r.action}</span>
                    </td>
                    <td data-label={a.auditEntity}>
                      {r.entity}
                      {r.entityId ? ` #${r.entityId}` : ""}
                    </td>
                    <td data-label={a.auditSummary}>{r.summary || "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {totalPages > 1 && (
            <div className="teacher-pager">
              <Button type="button" variant="ghost" size="sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
                ←
              </Button>
              <span className="teacher-pager-info">
                {page} / {totalPages}
              </span>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                disabled={page >= totalPages}
                onClick={() => setPage((p) => p + 1)}
              >
                →
              </Button>
            </div>
          )}
        </>
      )}
    </>
  );
}
