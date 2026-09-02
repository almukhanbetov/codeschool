"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { AnimatedCounter } from "@/components/ui/AnimatedCounter";
import type { StatItem } from "@/types";

export function StatCard({ item }: { item: StatItem }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLDivElement>();

  return (
    <div ref={ref} className={`stat-item ${className}`}>
      {item.staticValue !== undefined ? (
        <span className="stat-number">{item.staticValue}</span>
      ) : (
        <AnimatedCounter target={item.count ?? 0} suffix={item.suffix} />
      )}
      <span className="stat-label">{t.stats[item.key]}</span>
    </div>
  );
}
