"use client";

import {
  createContext,
  useCallback,
  useContext,
  useLayoutEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import type { Theme } from "@/types";

const THEME_KEY = "codeschool-theme";
const DEFAULT_THEME: Theme = "dark";

interface ThemeContextValue {
  theme: Theme;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

/** Inline, render-blocking script (see app/layout.tsx) that applies the
 * saved theme to <html> before first paint, so there is no flash of the
 * wrong theme. It runs outside React, so it never causes a hydration
 * mismatch — the attribute it sets isn't part of any server-rendered JSX
 * value React compares against (the <html> tag renders with the same
 * `data-theme="dark"` default on both server and client). */
export const themeInitScript = `(function(){try{var t=localStorage.getItem('${THEME_KEY}');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();`;

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>(DEFAULT_THEME);

  // useLayoutEffect (not useEffect): in dev, React Strict Mode's remount
  // clears the data-theme attribute the inline script set (it only keeps
  // attributes React itself rendered), so it must be re-applied before
  // paint. This is a no-op in production. See Next.js's
  // "preventing flash before hydration" guide.
  useLayoutEffect(() => {
    const saved = localStorage.getItem(THEME_KEY) as Theme | null;
    const resolved = saved === "light" ? "light" : "dark";
    // Deliberate one-time sync from localStorage (mirrors the DOM attribute
    // the blocking inline script already applied), not a derived-state bug —
    // this is React state catching up to what's already painted, purely for
    // the toggle button's aria-pressed correctness.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setThemeState(resolved);
    document.documentElement.setAttribute("data-theme", resolved);
  }, []);

  useLayoutEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
  }, [theme]);

  const toggleTheme = useCallback(() => {
    setThemeState((prev) => {
      const next: Theme = prev === "dark" ? "light" : "dark";
      localStorage.setItem(THEME_KEY, next);
      return next;
    });
  }, []);

  const value = useMemo<ThemeContextValue>(() => ({ theme, toggleTheme }), [theme, toggleTheme]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return ctx;
}
