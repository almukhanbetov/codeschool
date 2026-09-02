"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon } from "@/lib/icons";
import { Button } from "@/components/ui/Button";
import { getCourseTag, getLevelKey } from "@/lib/courseVisuals";
import type { Course } from "@/types";

export function CourseCard({ course, filteredOut }: { course: Course; filteredOut: boolean }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLElement>();
  const tag = getCourseTag(course.slug);

  return (
    <article ref={ref} className={`course-card ${className}${filteredOut ? " filtered-out" : ""}`}>
      <div className={`course-tag ${tag.className}`}>{tag.label}</div>
      <h3>{course.title}</h3>
      <div className="course-meta">
        <span>
          <Icon name="cake" aria-hidden="true" />
          <span>{t.course.age}</span> {course.ageFrom ?? "—"}–{course.ageTo ?? "—"} <span>{t.course.years}</span>
        </span>
        <span>
          <Icon name="book-open" aria-hidden="true" />
          {course.durationLessons ?? 0} <span>{t.course.lessons}</span>
        </span>
        <span>
          <Icon name="folder-kanban" aria-hidden="true" />
          {course.projectsCount ?? 0} <span>{t.course.projects}</span>
        </span>
      </div>
      <div className="course-level">{t.course[getLevelKey(course.difficulty)]}</div>
      <Button href={`/courses/${course.slug}`} variant="ghost" size="sm" className="course-btn">
        {t.course.more}
      </Button>
    </article>
  );
}
