"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon, type IconName } from "@/lib/icons";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { learningPath } from "@/data/learningPath";

function PathStage({ stage, isLast }: { stage: (typeof learningPath)[number]; isLast: boolean }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLDivElement>();

  return (
    <>
      <div ref={ref} className={`path-stage ${className}`}>
        <div className="path-stage-age">{stage.age}</div>
        <div className={`path-stage-card${stage.final ? " path-stage-final" : ""}`}>
          <Icon name={stage.icon as IconName} aria-hidden="true" />
          <h3>{t.path[stage.titleKey]}</h3>
        </div>
      </div>
      {!isLast && (
        <div className="path-arrow" aria-hidden="true">
          <Icon name="chevron-right" />
        </div>
      )}
    </>
  );
}

export function LearningPathSection() {
  const { t } = useLanguage();

  return (
    <section className="section path-section">
      <div className="container">
        <SectionHeading eyebrow={t.path.eyebrow} title={t.path.title} description={t.path.subtitle} />

        <div className="path-track">
          {learningPath.map((stage, i) => (
            <PathStage key={stage.id} stage={stage} isLast={i === learningPath.length - 1} />
          ))}
        </div>
      </div>
    </section>
  );
}
