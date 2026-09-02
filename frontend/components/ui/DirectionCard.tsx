"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon, type IconName } from "@/lib/icons";
import type { DirectionItem } from "@/types";

export function DirectionCard({ item }: { item: DirectionItem }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLElement>();
  const card = t.directions[item.cardKey];

  return (
    <article ref={ref} className={`direction-card ${item.accentClass} ${className}`}>
      <Icon name={item.icon as IconName} className="direction-icon" aria-hidden="true" />
      <h3>{card.title}</h3>
      <ul className="tag-list">
        {item.tags.map((tag, i) => (
          <li key={i}>{"literal" in tag ? tag.literal : card[tag.key]}</li>
        ))}
      </ul>
    </article>
  );
}
