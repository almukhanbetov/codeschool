"use client";

import { StatCard } from "@/components/ui/StatCard";
import { statItems } from "@/data/stats";

export function StatsSection() {
  return (
    <section className="section stats-section">
      <div className="container stats-grid">
        {statItems.map((item) => (
          <StatCard key={item.id} item={item} />
        ))}
      </div>
    </section>
  );
}
