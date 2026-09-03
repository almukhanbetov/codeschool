"use client";

import { useEffect, useState } from "react";
import Editor, { loader } from "@monaco-editor/react";
import { useLanguage } from "@/hooks/useLanguage";
import { useTheme } from "@/hooks/useTheme";
import type { CodeLanguage } from "@/types";

// Monaco's built-in language ids happen to match ours 1:1 for this stage.
const MONACO_LANG: Record<CodeLanguage, string> = {
  python: "python",
  javascript: "javascript",
  go: "go",
  plaintext: "plaintext",
};

type Mode = "probing" | "monaco" | "fallback";

/**
 * A Monaco-backed code editor with two graceful degradations (spec: mobile
 * fallback, no code execution):
 *  - on a coarse pointer / narrow viewport it renders a plain <textarea>;
 *  - if Monaco fails to load (offline, CDN blocked) it falls back to the same.
 * The value is always a controlled string — the parent owns draft/submit.
 */
export function CodeEditor({
  value,
  onChange,
  language,
  readOnly = false,
  ariaLabel,
}: {
  value: string;
  onChange: (next: string) => void;
  language: CodeLanguage;
  readOnly?: boolean;
  ariaLabel?: string;
}) {
  const { t } = useLanguage();
  const { theme } = useTheme();
  const [mode, setMode] = useState<Mode>("probing");

  useEffect(() => {
    const coarse =
      typeof window !== "undefined" &&
      (window.matchMedia?.("(pointer: coarse)").matches || window.innerWidth < 720);
    if (coarse) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setMode("fallback");
      return;
    }
    let alive = true;
    loader
      .init()
      .then(() => {
        if (alive) setMode("monaco");
      })
      .catch(() => {
        if (alive) setMode("fallback");
      });
    return () => {
      alive = false;
    };
  }, []);

  if (mode === "probing") {
    return <div className="code-editor-shell code-editor-loading">{t.learn.editorLoading}</div>;
  }

  if (mode === "fallback") {
    return (
      <div className="code-editor-shell">
        <textarea
          className="assignment-input assignment-code"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          readOnly={readOnly}
          spellCheck={false}
          rows={12}
          aria-label={ariaLabel}
          data-language={language}
        />
        <p className="code-editor-note">{t.learn.editorMobileNote}</p>
      </div>
    );
  }

  return (
    <div className="code-editor-shell" data-readonly={readOnly ? "true" : undefined}>
      <Editor
        height="320px"
        language={MONACO_LANG[language] ?? "plaintext"}
        value={value}
        theme={theme === "light" ? "light" : "vs-dark"}
        onChange={(next) => onChange(next ?? "")}
        loading={<div className="code-editor-loading">{t.learn.editorLoading}</div>}
        options={{
          readOnly,
          domReadOnly: readOnly,
          minimap: { enabled: false },
          fontSize: 13,
          lineNumbers: "on",
          scrollBeyondLastLine: false,
          automaticLayout: true,
          wordWrap: "on",
          tabSize: 4,
          renderWhitespace: "selection",
          padding: { top: 10, bottom: 10 },
          ariaLabel,
        }}
      />
      {readOnly && <p className="code-editor-note">{t.learn.editorReadOnly}</p>}
    </div>
  );
}
