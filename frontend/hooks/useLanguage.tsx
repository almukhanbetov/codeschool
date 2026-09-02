"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { translations } from "@/data/translations";
import type { Language, Translations } from "@/types";

const LANG_KEY = "codeschool-lang";
const DEFAULT_LANG: Language = "ru";

interface LanguageContextValue {
  lang: Language;
  t: Translations;
  setLang: (lang: Language) => void;
}

const LanguageContext = createContext<LanguageContextValue | null>(null);

export function LanguageProvider({ children }: { children: ReactNode }) {
  // Starts at the same default the server rendered, so hydration always
  // matches; the real saved preference (if any) is applied right after
  // mount, in a client-only effect.
  const [lang, setLangState] = useState<Language>(DEFAULT_LANG);

  useEffect(() => {
    const saved = localStorage.getItem(LANG_KEY) as Language | null;
    if (saved && saved in translations && saved !== DEFAULT_LANG) {
      // Deliberate one-time sync from localStorage, not a derived-state bug:
      // per Next.js's "preventing flash before hydration" guide, translating
      // content is explicitly out of scope for the inline-script trick, so
      // the default render must match the server and only correct itself
      // after mount.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setLangState(saved);
    }
  }, []);

  useEffect(() => {
    document.documentElement.lang = lang;
    document.title = translations[lang].meta.title;
  }, [lang]);

  const setLang = useCallback((next: Language) => {
    setLangState(next);
    localStorage.setItem(LANG_KEY, next);
  }, []);

  const value = useMemo<LanguageContextValue>(
    () => ({ lang, t: translations[lang], setLang }),
    [lang, setLang]
  );

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const ctx = useContext(LanguageContext);
  if (!ctx) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return ctx;
}
