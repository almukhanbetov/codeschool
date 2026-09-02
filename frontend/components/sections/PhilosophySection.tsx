"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";

export function PhilosophySection() {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLParagraphElement>();

  return (
    <section className="section philosophy-section" id="about">
      <div className="container">
        <p ref={ref} className={`philosophy-text ${className}`}>
          <span>{t.philosophy.line1}</span>
          <br />
          <span className="gradient-text">{t.philosophy.line2}</span>
        </p>
      </div>
    </section>
  );
}
