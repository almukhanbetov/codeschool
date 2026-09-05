"use client";

import { useCallback, useEffect, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { usePolling } from "@/hooks/usePolling";
import { adminSupportApi, ApiError } from "@/lib/api";
import { Button } from "@/components/ui/Button";
import { MessageList } from "@/components/support/MessageList";
import { Composer } from "@/components/support/Composer";
import { ContextPanel } from "@/components/support/ContextPanel";
import { CATEGORY_ORDER, categoryLabel, statusLabel } from "@/components/support/categories";
import type {
  AdminSupportThread,
  AdminSupportThreadDetail,
  SupportMessage,
  SupportStatus,
} from "@/types";

const PAGE = 20;

export function AdminSupport() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const s = t.support;
  const adm = t.admin;

  const [rows, setRows] = useState<AdminSupportThread[] | null>(null);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filters, setFilters] = useState({ status: "", category: "", kind: "", assigned: "", q: "" });
  const [error, setError] = useState<string | null>(null);

  const [active, setActive] = useState<AdminSupportThreadDetail | null>(null);
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [internal, setInternal] = useState(false);
  const [sending, setSending] = useState(false);

  const load = useCallback(() => {
    adminSupportApi
      .list({
        status: filters.status || undefined,
        category: filters.category || undefined,
        kind: filters.kind || undefined,
        assigned: filters.assigned || undefined,
        q: filters.q.trim() || undefined,
        page,
      })
      .then((res) => {
        setRows(res.data);
        setTotal(res.meta.total);
        setError(null);
      })
      .catch((e) => setError(e instanceof ApiError ? e.message : adm.loadError));
  }, [filters, page, adm.loadError]);

  const open = useCallback(
    (id: number) => {
      Promise.all([adminSupportApi.thread(id), adminSupportApi.messages(id)])
        .then(([th, msgs]) => {
          setActive(th);
          setMessages(msgs);
          return adminSupportApi.markRead(id);
        })
        .then(() => {
          window.dispatchEvent(new Event("support:refresh-unread"));
          load();
        })
        .catch((e) => setError(e instanceof ApiError ? e.message : adm.loadError));
    },
    [load, adm.loadError]
  );

  useEffect(() => {
    void load();
  }, [load]);

  usePolling(() => {
    load();
    if (active) open(active.id);
  }, 12000);

  async function reply(text: string, asInternal: boolean) {
    if (!active) return;
    setSending(true);
    try {
      const m = await adminSupportApi.reply(active.id, text, asInternal);
      setMessages((prev) => [...prev, m]);
      window.dispatchEvent(new Event("support:refresh-unread"));
      adminSupportApi.thread(active.id).then(setActive).catch(() => {});
      load();
    } catch (e) {
      setError(e instanceof ApiError ? e.message : adm.loadError);
    } finally {
      setSending(false);
    }
  }

  async function doAssign(adminId: number | null) {
    if (!active) return;
    try {
      setActive(await adminSupportApi.assign(active.id, adminId));
      open(active.id);
      load();
    } catch (e) {
      setError(e instanceof ApiError ? e.message : adm.loadError);
    }
  }

  async function doStatus(status: SupportStatus) {
    if (!active) return;
    try {
      setActive(await adminSupportApi.setStatus(active.id, status));
      open(active.id);
      load();
    } catch (e) {
      setError(e instanceof ApiError ? e.message : adm.loadError);
    }
  }

  const pages = Math.max(1, Math.ceil(total / PAGE));
  const setF = (k: string, v: string) => {
    setPage(1);
    setFilters((f) => ({ ...f, [k]: v }));
  };

  return (
    <>
      <h1 className="student-dash-title">{s.adminTitle}</h1>
      <p className="admin-muted">{s.adminSubtitle}</p>
      {error && <p className="auth-error">{error}</p>}

      <div className="admin-filters support-admin-filters">
        <label className="admin-field admin-field-grow">
          <span>{adm.search}</span>
          <input
            value={filters.q}
            placeholder={s.adminSearch}
            onChange={(e) => setF("q", e.target.value)}
          />
        </label>
        <label className="admin-field">
          <span>{adm.actions}</span>
          <select value={filters.status} onChange={(e) => setF("status", e.target.value)}>
            <option value="">{s.adminAll}</option>
            {(["open", "waiting_staff", "waiting_user", "closed"] as SupportStatus[]).map((st) => (
              <option key={st} value={st}>
                {statusLabel(s, st)}
              </option>
            ))}
          </select>
        </label>
        <label className="admin-field">
          <span>{s.category}</span>
          <select value={filters.category} onChange={(e) => setF("category", e.target.value)}>
            <option value="">{s.adminAll}</option>
            {CATEGORY_ORDER.map((c) => (
              <option key={c} value={c}>
                {categoryLabel(s, c)}
              </option>
            ))}
          </select>
        </label>
        <label className="admin-field">
          <span>—</span>
          <select value={filters.kind} onChange={(e) => setF("kind", e.target.value)}>
            <option value="">{s.adminAll}</option>
            <option value="student">{s.ctxStudent}</option>
            <option value="parent">{s.ctxParent}</option>
          </select>
        </label>
        <label className="admin-field">
          <span>—</span>
          <select value={filters.assigned} onChange={(e) => setF("assigned", e.target.value)}>
            <option value="">{s.adminAll}</option>
            <option value="unassigned">{s.adminUnassigned}</option>
            <option value="me">{s.adminAssignedToMe}</option>
          </select>
        </label>
      </div>

      <div className="support-admin-layout">
        {/* left: list */}
        <div className="support-admin-list">
          {rows === null ? (
            <p className="filter-empty">{adm.loading}</p>
          ) : rows.length === 0 ? (
            <p className="filter-empty">{adm.nothing}</p>
          ) : (
            <ul>
              {rows.map((r) => (
                <li key={r.id}>
                  <button
                    type="button"
                    className={`support-thread-row${active?.id === r.id ? " active" : ""}`}
                    onClick={() => open(r.id)}
                  >
                    <span className="support-thread-subject">
                      {r.owner.name}
                      {r.kind === "parent" ? ` → ${r.studentName}` : ""}
                    </span>
                    <span className="support-thread-sub">
                      {categoryLabel(s, r.category)}
                      {r.courseTitle ? ` · ${r.courseTitle}` : ""} — {r.lastMessagePreview}
                    </span>
                    <span className="support-thread-foot">
                      <span className={`support-status support-status-${r.status}`}>
                        {statusLabel(s, r.status)}
                      </span>
                      {r.assignedAdmin && (
                        <span className="support-assigned-tag">{r.assignedAdmin.name}</span>
                      )}
                      {r.unreadCount > 0 && (
                        <span className="support-unread-dot">{r.unreadCount}</span>
                      )}
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          )}
          {pages > 1 && (
            <div className="teacher-pager">
              <Button type="button" variant="ghost" size="sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
                ←
              </Button>
              <span className="teacher-pager-info">
                {page} / {pages}
              </span>
              <Button type="button" variant="ghost" size="sm" disabled={page >= pages} onClick={() => setPage((p) => p + 1)}>
                →
              </Button>
            </div>
          )}
        </div>

        {/* center: chat */}
        <div className="support-admin-chat">
          {!active ? (
            <p className="filter-empty">{s.adminPickThread}</p>
          ) : (
            <>
              <div className="support-thread-head">
                <div>
                  <h2>{active.subject}</h2>
                  <p className="admin-muted">
                    {categoryLabel(s, active.category)}
                    {active.courseTitle ? ` · ${active.courseTitle}` : ""}
                    {active.lessonTitle ? ` · ${active.lessonTitle}` : ""}
                  </p>
                </div>
                <span className={`support-status support-status-${active.status}`}>
                  {statusLabel(s, active.status)}
                </span>
              </div>

              <div className="support-admin-actions">
                {active.assignedAdmin?.id === user?.id ? (
                  <button className="admin-link" onClick={() => void doAssign(null)}>
                    {s.adminUnassign}
                  </button>
                ) : (
                  <button className="admin-link" onClick={() => void doAssign(user?.id ?? null)}>
                    {s.adminAssignToMe}
                  </button>
                )}
                {active.status === "closed" ? (
                  <button className="admin-link" onClick={() => void doStatus("waiting_staff")}>
                    {s.adminReopen}
                  </button>
                ) : (
                  <button className="admin-link admin-link-danger" onClick={() => void doStatus("closed")}>
                    {s.adminClose}
                  </button>
                )}
              </div>

              <MessageList messages={messages} />

              <label className="support-internal-toggle">
                <input
                  type="checkbox"
                  checked={internal}
                  onChange={(e) => setInternal(e.target.checked)}
                />
                {s.adminInternalNote}
              </label>
              <Composer
                key={internal ? "int" : "pub"}
                onSend={(text) => reply(text, internal)}
                placeholder={internal ? s.adminInternalNotePlaceholder : s.adminReplyPlaceholder}
                sending={sending}
              />
            </>
          )}
        </div>

        {/* right: learning context */}
        {active && <ContextPanel context={active.context} />}
      </div>
    </>
  );
}
