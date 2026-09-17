"use client";

import { useId, useState, type ComponentProps } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { Icon } from "@/lib/icons";

/**
 * A password <input> with a show/hide toggle button inside it. Drop-in
 * replacement for `<input type="password">` — everything except `type`
 * passes straight through. The eye button never submits the surrounding
 * form (type="button") and never touches auth/API logic — it only flips a
 * local `visible` boolean that controls the input's `type` attribute.
 */
export function PasswordInput({ className, id, ...props }: Omit<ComponentProps<"input">, "type">) {
  const [visible, setVisible] = useState(false);
  const { t } = useLanguage();
  const autoId = useId();
  const inputId = id ?? autoId;

  return (
    <span className="password-input-wrap">
      <input
        {...props}
        id={inputId}
        type={visible ? "text" : "password"}
        className={className}
      />
      <button
        type="button"
        className="password-toggle-btn"
        aria-label={visible ? t.auth.hidePassword : t.auth.showPassword}
        aria-pressed={visible}
        aria-controls={inputId}
        onClick={() => setVisible((v) => !v)}
      >
        <Icon name={visible ? "eye-off" : "eye"} size={18} aria-hidden="true" />
      </button>
    </span>
  );
}
