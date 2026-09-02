"use client";

import { useLanguage } from "@/hooks/useLanguage";
import type { AgeFilter } from "@/types";

const FILTERS: { value: AgeFilter; labelKey: "all" | "a1" | "a2" | "a3" | "a4" | "a5" }[] = [
  { value: "all", labelKey: "all" },
  { value: "6-8", labelKey: "a1" },
  { value: "8-10", labelKey: "a2" },
  { value: "10-12", labelKey: "a3" },
  { value: "12-14", labelKey: "a4" },
  { value: "14-17", labelKey: "a5" },
];

interface CourseFilterProps {
  active: AgeFilter;
  onChange: (value: AgeFilter) => void;
}

export function CourseFilter({ active, onChange }: CourseFilterProps) {
  const { t } = useLanguage();

  return (
    <div className="filter-tabs" role="tablist" aria-label={t.courses.title}>
      {FILTERS.map((filter) => (
        <button
          key={filter.value}
          type="button"
          role="tab"
          aria-selected={active === filter.value}
          className={`filter-tab${active === filter.value ? " active" : ""}`}
          onClick={() => onChange(filter.value)}
        >
          {t.filter[filter.labelKey]}
        </button>
      ))}
    </div>
  );
}
