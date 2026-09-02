"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon, type IconName } from "@/lib/icons";
import { childrenExamples } from "@/data/childrenExamples";

function ExampleChip({ item }: { item: (typeof childrenExamples)[number] }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLDivElement>();

  return (
    <div ref={ref} className={`example-chip ${className}`}>
      <Icon name={item.icon as IconName} aria-hidden="true" />
      <span>{t.children[item.key]}</span>
    </div>
  );
}

export function ChildrenSection() {
  const { t } = useLanguage();
  const { ref: textRef, className: textClassName } = useReveal<HTMLDivElement>();

  return (
    <section className="section children-section" id="children">
      <div className="container children-inner">
        <div ref={textRef} className={`children-text ${textClassName}`}>
          <span className="eyebrow">{t.children.eyebrow}</span>
          <h2>{t.children.title}</h2>
          <p className="children-lead">{t.children.lead1}</p>
          <p className="children-lead-strong">{t.children.lead2}</p>
        </div>

        <div className="children-gallery">
          {childrenExamples.map((item) => (
            <ExampleChip key={item.id} item={item} />
          ))}
        </div>
      </div>
    </section>
  );
}
