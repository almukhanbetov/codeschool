"use client";

import { useTheme } from "@/hooks/useTheme";
import { Icon } from "@/lib/icons";

export function ThemeToggle({ ariaLabel }: { ariaLabel: string }) {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      type="button"
      className="theme-toggle"
      aria-label={ariaLabel}
      aria-pressed={theme === "light"}
      onClick={toggleTheme}
    >
      <Icon name="sun" className="icon-sun" aria-hidden="true" />
      <Icon name="moon" className="icon-moon" aria-hidden="true" />
    </button>
  );
}
