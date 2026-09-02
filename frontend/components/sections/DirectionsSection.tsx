"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { DirectionCard } from "@/components/ui/DirectionCard";
import { directions } from "@/data/directions";

export function DirectionsSection() {
  const { t } = useLanguage();

  return (
    <section className="section directions-section" id="directions">
      <div className="container">
        <SectionHeading
          eyebrow={t.directions.eyebrow}
          title={t.directions.title}
          description={t.directions.subtitle}
        />

        <div className="directions-grid">
          {directions.map((item) => (
            <DirectionCard key={item.id} item={item} />
          ))}
        </div>
      </div>
    </section>
  );
}
