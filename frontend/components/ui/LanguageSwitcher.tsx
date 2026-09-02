"use client";

import { useLanguage } from "@/hooks/useLanguage";
import type { Language } from "@/types";

const LANG_LABELS: Record<Language, { header: string; footer: string }> = {
  kz: { header: "KZ", footer: "ҚАЗ" },
  ru: { header: "RU", footer: "РУС" },
  en: { header: "EN", footer: "ENG" },
};

const LANG_ORDER: Language[] = ["kz", "ru", "en"];

interface LanguageSwitcherProps {
  variant?: "header" | "footer";
  ariaLabel: string;
}

export function LanguageSwitcher({ variant = "header", ariaLabel }: LanguageSwitcherProps) {
  const { lang, setLang } = useLanguage();

  return (
    <div
      className={variant === "footer" ? "footer-lang-switch" : "lang-switch"}
      role="group"
      aria-label={ariaLabel}
    >
      {LANG_ORDER.map((code) => (
        <button
          key={code}
          type="button"
          className={`lang-btn${lang === code ? " active" : ""}`}
          aria-pressed={lang === code}
          onClick={() => setLang(code)}
        >
          {LANG_LABELS[code][variant]}
        </button>
      ))}
    </div>
  );
}
