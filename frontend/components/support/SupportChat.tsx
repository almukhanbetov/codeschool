"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { usePolling } from "@/hooks/usePolling";
import { ApiError, getParentChildren, supportApi } from "@/lib/api";
import { Button } from "@/components/ui/Button";
import { MessageList } from "@/components/support/MessageList";
import { Composer } from "@/components/support/Composer";
import { CATEGORY_ORDER, categoryLabel, statusLabel } from "@/components/support/categories";
import type {
  ParentChildListItem,
  SupportCategory,
  SupportMessage,
  SupportThread,
} from "@/types";

type View = "list" | "new" | { threadId: number };

function nudgeUnread() {
  window.dispatchEvent(new Event("support:refresh-unread"));
}

export function SupportChat() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const s = t.support;
  const isParent = user?.role === "parent";
  const params = useSearchParams();

  const [threads, setThreads] = useState<SupportThread[] | null>(null);
  const [view, setView] = useState<View>(() =>
    params.get("new") === "1" ? "new" : "list"
  );
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [activeThread, setActiveThread] = useState<SupportThread | null>(null);
  const [children, setChildren] = useState<ParentChildListItem[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [sending, setSending] = useState(false);

  // ---- new-thread form ----
  const prefill = useMemo(
    () => ({
      courseId: params.get("course") ? Number(params.get("course")) : undefined,
      lessonId: params.get("lesson") ? Number(params.get("lesson")) : undefined,
      assignmentId: params.get("assignment") ? Number(params.get("assignment")) : undefined,
      category: (params.get("category") as SupportCategory) || undefined,
      isNew: params.get("new") === "1",
    }),
    [params]
  );
  const [subject, setSubject] = useState("");
  const [category, setCategory] = useState<SupportCategory>(
    prefill.category || (isParent ? "parent_question" : "general")
  );
  const [childId, setChildId] = useState<number | undefined>(undefined);
  const [firstMessage, setFirstMessage] = useState("");

  const loadThreads = useCallback(() => {
    supportApi
      .threads()
      .then((list) => {
        setThreads(list);
        setError(null);
      })
      .catch(() => setError(s.loadError));
  }, [s.loadError]);

  const openThread = useCallback((id: number) => {
    setView({ threadId: id });
    Promise.all([supportApi.thread(id), supportApi.messages(id)])
      .then(([th, msgs]) => {
        setActiveThread(th);
        setMessages(msgs);
        return supportApi.markRead(id);
      })
      .then(() => nudgeUnread())
      .catch(() => setError(s.loadError));
  }, [s.loadError]);

  // initial load
  useEffect(() => {
    loadThreads();
    if (isParent) getParentChildren().then(setChildren).catch(() => {});
  }, [loadThreads, isParent]);

  // poll the open thread + the list
  usePolling(() => {
    if (typeof view === "object") openThread(view.threadId);
    else loadThreads();
  }, 12000);

  const backToList = () => {
    setView("list");
    setActiveThread(null);
    setMessages([]);
    loadThreads();
  };

  async function createThread() {
    const subj = subject.trim() || firstMessage.trim().slice(0, 80);
    if (!subj || !firstMessage.trim() || sending) return;
    if (isParent && !childId) {
      setError(s.chooseChild);
      return;
    }
    setSending(true);
    setError(null);
    try {
      const th = await supportApi.createThread({
        subject: subj,
        category,
        message: firstMessage.trim(),
        courseId: prefill.courseId,
        lessonId: prefill.lessonId,
        assignmentId: prefill.assignmentId,
        studentId: isParent ? childId : undefined,
      });
      setSubject("");
      setFirstMessage("");
      nudgeUnread();
      openThread(th.id);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : s.loadError);
    } finally {
      setSending(false);
    }
  }

  async function sendMessage(text: string) {
    if (typeof view !== "object") return;
    setSending(true);
    try {
      const m = await supportApi.postMessage(view.threadId, text);
      setMessages((prev) => [...prev, m]);
      nudgeUnread();
      supportApi.thread(view.threadId).then(setActiveThread).catch(() => {});
    } catch (err) {
      setError(err instanceof ApiError ? err.message : s.loadError);
    } finally {
      setSending(false);
    }
  }

  const quickQuestions = isParent
    ? [
        { q: s.qParent1, c: "progress" as const },
        { q: s.qParent2, c: "course" as const },
        { q: s.qParent3, c: "parent_question" as const },
        { q: s.qParent4, c: "general" as const },
      ]
    : [
        { q: s.qStudent1, c: "lesson" as const },
        { q: s.qStudent2, c: "code_runner" as const },
        { q: s.qStudent3, c: "quiz" as const },
        { q: s.qStudent4, c: "assignment" as const },
        { q: s.qStudent5, c: "certificate" as const },
      ];

  return (
    <section className="section">
      <div className="container">
        <span className="eyebrow">{isParent ? s.parentTitle : s.title}</span>
        <h1 className="student-dash-title">{isParent ? s.parentTitle : s.title}</h1>
        <p className="admin-muted">{s.subtitle}</p>

        {error && <p className="auth-error">{error}</p>}

        <div className="support-layout">
          {/* -------- left: thread list -------- */}
          <aside className="support-threadlist">
            <Button
              type="button"
              variant="primary"
              size="sm"
              onClick={() => setView("new")}
              className="support-new-btn"
            >
              + {s.newThread}
            </Button>
            {threads === null ? (
              <p className="filter-empty">{s.loading}</p>
            ) : threads.length === 0 ? (
              <p className="filter-empty">{s.threadsEmpty}</p>
            ) : (
              <ul>
                {threads.map((th) => (
                  <li key={th.id}>
                    <button
                      type="button"
                      className={`support-thread-row${
                        typeof view === "object" && view.threadId === th.id ? " active" : ""
                      }`}
                      onClick={() => openThread(th.id)}
                    >
                      <span className="support-thread-subject">{th.subject}</span>
                      <span className="support-thread-sub">
                        {categoryLabel(s, th.category)}
                        {th.about.courseTitle ? ` · ${th.about.courseTitle}` : ""}
                      </span>
                      <span className="support-thread-foot">
                        <span className={`support-status support-status-${th.status}`}>
                          {statusLabel(s, th.status)}
                        </span>
                        {th.unreadCount > 0 && (
                          <span className="support-unread-dot">{th.unreadCount}</span>
                        )}
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </aside>

          {/* -------- right: new form / active thread -------- */}
          <div className="support-main">
            {view === "list" && (
              <div className="support-empty-state">
                <h2>{s.howCanWeHelp}</h2>
                <p className="admin-muted">{s.chooseTopic}</p>
                <div className="support-quick">
                  {quickQuestions.map((qq) => (
                    <button
                      key={qq.q}
                      type="button"
                      className="support-quick-chip"
                      onClick={() => {
                        setCategory(qq.c);
                        setSubject(qq.q);
                        setFirstMessage(qq.q + ": ");
                        setView("new");
                      }}
                    >
                      {qq.q}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {view === "new" && (
              <div className="support-newform">
                <h2>{s.newThread}</h2>
                {(prefill.courseId || prefill.lessonId || prefill.assignmentId) && (
                  <p className="support-ctx-hint">{s.attachedContext} ✓</p>
                )}
                {isParent && (
                  <label className="admin-field">
                    <span>{s.aboutStudent}</span>
                    <select
                      value={childId ?? ""}
                      onChange={(e) => setChildId(Number(e.target.value) || undefined)}
                    >
                      <option value="">{s.chooseChild}</option>
                      {children.map((c) => (
                        <option key={c.child.id} value={c.child.id}>
                          {c.child.firstName} {c.child.lastName ?? ""}
                        </option>
                      ))}
                    </select>
                  </label>
                )}
                <label className="admin-field">
                  <span>{s.category}</span>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value as SupportCategory)}
                  >
                    {CATEGORY_ORDER.map((c) => (
                      <option key={c} value={c}>
                        {categoryLabel(s, c)}
                      </option>
                    ))}
                  </select>
                </label>
                <label className="admin-field">
                  <span>{s.subject}</span>
                  <input
                    value={subject}
                    placeholder={s.subjectPlaceholder}
                    onChange={(e) => setSubject(e.target.value)}
                  />
                </label>
                <label className="admin-field">
                  <span> </span>
                  <textarea
                    rows={4}
                    value={firstMessage}
                    maxLength={4000}
                    placeholder={s.composerPlaceholder}
                    onChange={(e) => setFirstMessage(e.target.value)}
                  />
                </label>
                <div className="admin-form-actions">
                  <Button type="button" variant="ghost" size="sm" onClick={backToList}>
                    {t.site.back}
                  </Button>
                  <Button
                    type="button"
                    variant="primary"
                    size="sm"
                    onClick={() => void createThread()}
                    disabled={sending || !firstMessage.trim()}
                  >
                    {sending ? s.starting : s.start}
                  </Button>
                </div>
              </div>
            )}

            {typeof view === "object" && activeThread && (
              <div className="support-thread">
                <div className="support-thread-head">
                  <div>
                    <h2>{activeThread.subject}</h2>
                    <p className="admin-muted">
                      {categoryLabel(s, activeThread.category)}
                      {activeThread.about.courseTitle ? ` · ${activeThread.about.courseTitle}` : ""}
                      {activeThread.about.lessonTitle ? ` · ${activeThread.about.lessonTitle}` : ""}
                    </p>
                  </div>
                  <span className={`support-status support-status-${activeThread.status}`}>
                    {statusLabel(s, activeThread.status)}
                  </span>
                </div>
                <MessageList messages={messages} />
                {activeThread.status === "closed" && (
                  <p className="support-reopen-hint">{s.reopenHint}</p>
                )}
                <Composer
                  onSend={sendMessage}
                  placeholder={s.composerPlaceholder}
                  sending={sending}
                />
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
