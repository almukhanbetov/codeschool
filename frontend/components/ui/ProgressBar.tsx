"use client";

import { useLanguage } from "@/hooks/useLanguage";

/** Thin progress bar reusing the design system's .progress-* tokens. */
export function ProgressBar({
  percent,
  label,
}: {
  percent: number;
  label?: string;
}) {
  const { t } = useLanguage();
  const clamped = Math.max(0, Math.min(100, Math.round(percent)));

  return (
    <div className="lp-progress">
      <div className="lp-progress-head">
        <span>{label ?? t.learn.progress}</span>
        <span className="progress-percent">{clamped}%</span>
      </div>
      <div className="progress-track">
        <div className="progress-fill" style={{ width: `${clamped}%` }} />
      </div>
    </div>
  );
}
