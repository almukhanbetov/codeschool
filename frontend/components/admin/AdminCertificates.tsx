"use client";

import { useCallback, useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { adminCertificatesApi, ApiError } from "@/lib/api";
import type { AdminCertificateRow } from "@/types";

const PAGE_SIZE = 20;

export function AdminCertificates() {
  const { t, lang } = useLanguage();
  const c = t.certificates;
  const adm = t.admin;

  const [rows, setRows] = useState<AdminCertificateRow[] | null>(null);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState("");
  const [q, setQ] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [revoking, setRevoking] = useState<AdminCertificateRow | null>(null);

  const load = useCallback(async () => {
    try {
      const res = await adminCertificatesApi.list({
        status: status || undefined,
        q: q.trim() || undefined,
        page,
        limit: PAGE_SIZE,
      });
      setRows(res.items);
      setTotal(res.total);
      setError(null);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : adm.loadError);
    }
  }, [status, q, page, adm.loadError]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  async function downloadPdf(row: AdminCertificateRow) {
    try {
      await adminCertificatesApi.downloadPdf(row.id, lang, `certificate-${row.certificateNumber}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : adm.loadError);
    }
  }

  const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <>
      <h1 className="student-dash-title">{c.adminTitle}</h1>
      <p className="admin-muted">{c.adminSubtitle}</p>
      {error && <p className="auth-error">{error}</p>}

      <div className="admin-section">
        <div className="admin-filters">
          <label className="admin-field admin-field-grow">
            <span>{adm.search}</span>
            <input
              value={q}
              placeholder={adm.search}
              onChange={(e) => {
                setPage(1);
                setQ(e.target.value);
              }}
            />
          </label>
          <label className="admin-field">
            <span>{c.colStatus}</span>
            <select
              value={status}
              onChange={(e) => {
                setPage(1);
                setStatus(e.target.value);
              }}
            >
              <option value="">{c.adminFilterAll}</option>
              <option value="active">{c.statusActive}</option>
              <option value="revoked">{c.statusRevoked}</option>
            </select>
          </label>
        </div>

        {rows === null ? (
          <p className="filter-empty">{adm.loading}</p>
        ) : rows.length === 0 ? (
          <p className="filter-empty">{adm.nothing}</p>
        ) : (
          <div className="teacher-table-wrap">
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>{c.colNumber}</th>
                  <th>{c.adminColLearner}</th>
                  <th>{c.adminColRole}</th>
                  <th>{c.colCourse}</th>
                  <th>{c.colIssued}</th>
                  <th>{c.colStatus}</th>
                  <th>{adm.actions}</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id}>
                    <td>
                      <span className="teacher-cell-title">{row.certificateNumber}</span>
                    </td>
                    <td>{row.learnerName}</td>
                    <td>{row.learnerRole}</td>
                    <td>{row.courseTitle}</td>
                    <td>{new Date(row.issuedAt).toLocaleDateString()}</td>
                    <td>
                      {row.status === "revoked" ? (
                        <span className="quiz-badge cert-badge-revoked">{c.statusRevoked}</span>
                      ) : (
                        <span className="quiz-badge quiz-badge-pass">{c.statusActive}</span>
                      )}
                    </td>
                    <td className="admin-row-actions">
                      <button className="admin-link" onClick={() => downloadPdf(row)}>
                        {c.adminDownloadPdf}
                      </button>
                      {row.status === "active" && (
                        <button
                          className="admin-link admin-link-danger"
                          onClick={() => setRevoking(row)}
                        >
                          {c.adminRevoke}
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {pages > 1 && (
          <div className="teacher-pager">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              disabled={page <= 1}
              onClick={() => setPage((p) => p - 1)}
            >
              ←
            </Button>
            <span className="teacher-pager-info">
              {page} / {pages}
            </span>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              disabled={page >= pages}
              onClick={() => setPage((p) => p + 1)}
            >
              →
            </Button>
          </div>
        )}
      </div>

      {revoking && (
        <RevokeDialog
          row={revoking}
          onClose={() => setRevoking(null)}
          onDone={() => {
            setRevoking(null);
            void load();
          }}
        />
      )}
    </>
  );
}

function RevokeDialog({
  row,
  onClose,
  onDone,
}: {
  row: AdminCertificateRow;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useLanguage();
  const c = t.certificates;
  const [reason, setReason] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit() {
    if (!reason.trim()) {
      setErr(c.adminRevokeReasonRequired);
      return;
    }
    setBusy(true);
    setErr(null);
    try {
      await adminCertificatesApi.revoke(row.id, reason.trim());
      onDone();
    } catch (e) {
      setErr(e instanceof ApiError ? e.message : c.adminRevokeReasonRequired);
      setBusy(false);
    }
  }

  return (
    <div className="admin-dialog-backdrop" onClick={onClose}>
      <div className="admin-dialog" onClick={(e) => e.stopPropagation()}>
        <h2>{c.adminRevokeTitle}</h2>
        <p className="admin-muted">
          {row.certificateNumber} · {row.learnerName} · {row.courseTitle}
        </p>
        <p className="assignment-notice">{c.adminRevokeConfirm}</p>
        <label className="admin-field">
          {c.adminRevokeReason}
          <textarea
            rows={3}
            value={reason}
            placeholder={c.adminRevokeReasonPlaceholder}
            onChange={(e) => setReason(e.target.value)}
          />
        </label>
        {err && <p className="auth-error">{err}</p>}
        <div className="admin-form-actions">
          <Button variant="ghost" size="sm" onClick={onClose} disabled={busy}>
            {t.admin.cancel}
          </Button>
          <Button variant="primary" size="sm" onClick={submit} disabled={busy}>
            {c.adminRevokeSubmit}
          </Button>
        </div>
      </div>
    </div>
  );
}
