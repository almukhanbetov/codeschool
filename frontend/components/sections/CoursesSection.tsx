"use client";

import { useMemo, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { CourseFilter } from "@/components/ui/CourseFilter";
import { CourseCard } from "@/components/ui/CourseCard";
import type { AgeFilter, Course } from "@/types";

// Bucket ranges for the (unchanged) filter tabs. A course matches a bucket
// if its own [ageFrom, ageTo] range overlaps the bucket's — courses come
// from the database now with real numeric ages, which won't always line up
// exactly with these five fixed buckets.
const AGE_BUCKETS: Record<Exclude<AgeFilter, "all">, [number, number]> = {
  "6-8": [6, 8],
  "8-10": [8, 10],
  "10-12": [10, 12],
  "12-14": [12, 14],
  "14-17": [14, 17],
};

function matchesFilter(course: Course, filter: AgeFilter): boolean {
  if (filter === "all") return true;
  const [bucketFrom, bucketTo] = AGE_BUCKETS[filter];
  const courseFrom = course.ageFrom ?? bucketFrom;
  const courseTo = course.ageTo ?? bucketTo;
  return courseFrom <= bucketTo && courseTo >= bucketFrom;
}

interface CoursesSectionProps {
  courses: Course[];
  loadError?: boolean;
}

export function CoursesSection({ courses, loadError = false }: CoursesSectionProps) {
  const { t } = useLanguage();
  const [activeFilter, setActiveFilter] = useState<AgeFilter>("all");

  const visibleCount = useMemo(
    () => courses.filter((c) => matchesFilter(c, activeFilter)).length,
    [courses, activeFilter]
  );

  return (
    <section className="section courses-section" id="courses">
      <div className="container">
        <SectionHeading
          eyebrow={t.courses.eyebrow}
          title={t.courses.title}
          description={t.courses.subtitle}
        />

        {loadError ? (
          <p className="filter-empty" data-testid="courses-error">
            {t.courses.loadError}
          </p>
        ) : (
          <>
            <CourseFilter active={activeFilter} onChange={setActiveFilter} />

            <div className="course-grid">
              {courses.map((course) => (
                <CourseCard
                  key={course.id}
                  course={course}
                  filteredOut={!matchesFilter(course, activeFilter)}
                />
              ))}
            </div>

            <p className="filter-empty" hidden={visibleCount !== 0}>
              {t.filter.empty}
            </p>
          </>
        )}
      </div>
    </section>
  );
}
