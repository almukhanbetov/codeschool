"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon, type IconName } from "@/lib/icons";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { whyUsItems } from "@/data/whyUs";

function WhyCard({ item }: { item: (typeof whyUsItems)[number] }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLDivElement>();

  return (
    <div ref={ref} className={`why-card ${className}`}>
      <Icon name={item.icon as IconName} aria-hidden="true" />
      <span>{t.whyus[item.key]}</span>
    </div>
  );
}

export function WhyUsSection() {
  const { t } = useLanguage();

  return (
    <section className="section whyus-section" id="whyus">
      <div className="container">
        <SectionHeading eyebrow={t.whyus.eyebrow} title={t.whyus.title} />

        <div className="whyus-grid">
          {whyUsItems.map((item) => (
            <WhyCard key={item.id} item={item} />
          ))}
        </div>
      </div>
    </section>
  );
}
