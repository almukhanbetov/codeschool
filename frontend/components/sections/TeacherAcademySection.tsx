"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { Button } from "@/components/ui/Button";
import { teacherSteps } from "@/data/teacherSteps";

function Step({ step, isLast }: { step: (typeof teacherSteps)[number]; isLast: boolean }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLDivElement>();

  return (
    <>
      <div ref={ref} className={`teacher-step ${className}`}>
        <div className="teacher-step-num">{step.num}</div>
        <p>{t.teacher[step.key]}</p>
      </div>
      {!isLast && <div className="teacher-step-line" aria-hidden="true" />}
    </>
  );
}

export function TeacherAcademySection() {
  const { t } = useLanguage();
  const { ref: ctaRef, className: ctaClassName } = useReveal<HTMLDivElement>();

  return (
    <section className="section teacher-section">
      <div className="container">
        <div className="teacher-panel">
          <SectionHeading
            eyebrow={t.teacher.eyebrow}
            title={t.teacher.title}
            description={t.teacher.subtitle}
            lightOnDark
          />

          <div className="teacher-steps">
            {teacherSteps.map((step, i) => (
              <Step key={step.key} step={step} isLast={i === teacherSteps.length - 1} />
            ))}
          </div>

          <div ref={ctaRef} className={`teacher-cta-row ${ctaClassName}`}>
            <Button href="/for-teachers" variant="primary" size="lg">
              {t.teacher.cta}
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
