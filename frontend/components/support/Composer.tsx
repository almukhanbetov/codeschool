"use client";

import { useState, type KeyboardEvent } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";

const MAX = 4000;

/** Textarea composer: Enter sends, Shift+Enter newline, 4000-char cap,
 *  disabled while a send is in flight (prevents duplicate sends). */
export function Composer({
  onSend,
  placeholder,
  sending,
}: {
  onSend: (text: string) => Promise<void> | void;
  placeholder: string;
  sending: boolean;
}) {
  const { t } = useLanguage();
  const [value, setValue] = useState("");

  const submit = async () => {
    const text = value.trim();
    if (!text || sending) return;
    await onSend(text.slice(0, MAX));
    setValue("");
  };

  const onKey = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      void submit();
    }
  };

  return (
    <div className="support-composer">
      <textarea
        value={value}
        maxLength={MAX}
        rows={2}
        placeholder={placeholder}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={onKey}
        disabled={sending}
      />
      <Button
        type="button"
        variant="primary"
        size="sm"
        onClick={() => void submit()}
        disabled={sending || !value.trim()}
      >
        {sending ? t.support.sending : t.support.send}
      </Button>
    </div>
  );
}
