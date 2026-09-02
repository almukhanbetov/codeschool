"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Button } from "@/components/ui/Button";

export function FinalCTASection() {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLDivElement>();

  return (
    <section className="section final-cta-section">
      <div className="container">
        <div ref={ref} className={`final-cta-inner ${className}`}>
          <h2>{t.finalcta.title}</h2>
          <div className="final-cta-row">
            <Button href="#courses" variant="primary" size="lg">
              {t.finalcta.cta1}
            </Button>
            <Button href="/teacher" variant="secondary" size="lg">
              {t.finalcta.cta2}
            </Button>
            <Button href="#directions" variant="ghost" size="lg">
              {t.finalcta.cta3}
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
