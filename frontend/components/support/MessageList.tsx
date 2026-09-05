"use client";

import { useEffect, useRef } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import type { SupportMessage } from "@/types";

/** Shared message transcript. Student → right, staff → left, system → centered. */
export function MessageList({ messages }: { messages: SupportMessage[] }) {
  const { t } = useLanguage();
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ block: "end" });
  }, [messages.length]);

  return (
    <div className="support-messages">
      {messages.map((m) => {
        if (m.messageType === "system") {
          return (
            <div key={m.id} className="support-msg-system">
              {m.body}
            </div>
          );
        }
        const side = m.mine ? "mine" : "theirs";
        return (
          <div
            key={m.id}
            className={`support-msg support-msg-${side}${m.isInternal ? " support-msg-internal" : ""}`}
          >
            <div className="support-msg-meta">
              {m.isInternal && <span className="support-msg-internal-tag">{t.support.internalNote}</span>}
              <span className="support-msg-sender">
                {m.mine ? t.support.you : m.senderRole === "admin" ? t.support.staff : m.senderName}
              </span>
              <time>{new Date(m.createdAt).toLocaleString()}</time>
            </div>
            <p>{m.body}</p>
          </div>
        );
      })}
      <div ref={endRef} />
    </div>
  );
}
