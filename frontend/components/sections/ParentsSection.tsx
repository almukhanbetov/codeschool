"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { SectionHeading } from "@/components/ui/SectionHeading";

const PROGRESS_PERCENT = 82;

export function ParentsSection() {
  const { t } = useLanguage();
  const { ref: cardRef, className: cardClassName } = useReveal<HTMLDivElement>();

  return (
    <section className="section parents-section" id="parents">
      <div className="container parents-inner">
        <SectionHeading eyebrow={t.parents.eyebrow} title={t.parents.title} description={t.parents.desc} align="left" />

        <div ref={cardRef} className={`parent-dashboard-card ${cardClassName}`}>
          <div className="parent-progress-ring">
            <svg viewBox="0 0 120 120" className="ring-svg" aria-hidden="true">
              <circle cx="60" cy="60" r="52" className="ring-track" />
              <circle
                cx="60"
                cy="60"
                r="52"
                className="ring-fill"
                style={{ "--ring-progress": PROGRESS_PERCENT } as React.CSSProperties}
              />
            </svg>
            <div className="ring-label">
              <strong>{PROGRESS_PERCENT}%</strong>
              <span>{t.parents.progress}</span>
            </div>
          </div>

          <div className="parent-stats">
            <div className="parent-stat">
              <span className="parent-stat-label">{t.parents.lessons}</span>
              <span className="parent-stat-value">18 / 24</span>
            </div>
            <div className="parent-stat">
              <span className="parent-stat-label">{t.parents.projects}</span>
              <span className="parent-stat-value">6</span>
            </div>
            <div className="parent-stat">
              <span className="parent-stat-label">{t.parents.strength}</span>
              <span className="parent-stat-value">{t.parents.strengthValue}</span>
            </div>
            <div className="parent-stat">
              <span className="parent-stat-label">{t.parents.nextgoal}</span>
              <span className="parent-stat-value">{t.parents.nextgoalValue}</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
