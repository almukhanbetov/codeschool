"use client";

import { useMemo } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Icon, type IconName } from "@/lib/icons";
import { CourseCard } from "@/components/ui/CourseCard";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";
import { getCourseDirection } from "@/lib/courseVisuals";
import type { Course } from "@/types";

export type DirectionKey = "programming" | "robotics" | "ai";

// Categorisation keywords only — no course titles / descriptions are copied
// here. A course belongs to a direction when its slug/title/short description
// mentions any keyword (case-insensitive).
const KEYWORDS: Record<DirectionKey, string[]> = {
  programming: [
    "python", "algorithm", "algo", "алгорит", "scratch", "web", "веб", "code", "код",
    "program", "программ", "javascript", "backend", "frontend",
  ],
  robotics: ["robot", "робот", "arduino", "ардуино", "sensor", "датчик", "electron", "электрон", "motor", "мотор"],
  ai: ["ai", "artific", "intellig", "искусств", "жасанды", "нейрон", "neural", "machine learning", "машинн", "ml", "ии"],
};

const ICON: Record<DirectionKey, IconName> = {
  programming: "terminal-square",
  robotics: "bot",
  ai: "brain-circuit",
};

// Which existing DirectionCard translation carries the tech-tag list.
const TECH_KEY: Record<DirectionKey, "card1" | "card3" | "card4"> = {
  programming: "card1",
  robotics: "card3",
  ai: "card4",
};

// A course belongs to a direction when the explicit slug map says so;
// unmapped (e.g. newly authored) courses fall back to a keyword match.
function inDirection(course: Course, direction: DirectionKey): boolean {
  const mapped = getCourseDirection(course.slug);
  if (mapped) return mapped === direction;
  const hay = `${course.slug} ${course.title} ${course.shortDescription ?? ""}`.toLowerCase();
  return KEYWORDS[direction].some((k) => hay.includes(k));
}

interface Props {
  direction: DirectionKey;
  courses: Course[];
  loadError?: boolean;
}

export function DirectionPage({ direction, courses, loadError = false }: Props) {
  const { t } = useLanguage();
  const copy = t.site[direction];
  const techCard = t.directions[TECH_KEY[direction]];

  const tech = useMemo(() => {
    const tags = [techCard.title];
    (["tag2", "tag3", "tag4"] as const).forEach((k) => {
      const v = techCard[k];
      if (v) tags.push(v);
    });
    return tags;
  }, [techCard]);

  const directionCourses = useMemo(
    () => courses.filter((c) => inDirection(c, direction)),
    [courses, direction]
  );

  return (
    <>
      <PageHero
        eyebrow={copy.eyebrow}
        title={copy.title}
        lead={copy.lead}
        crumbs={[
          { label: t.site.nav.courses, href: "/courses" },
          { label: copy.title },
        ]}
      >
        <div className="direction-hero-icon" aria-hidden="true">
          <Icon name={ICON[direction]} />
        </div>
        <ul className="tag-list direction-hero-tags" aria-label={t.site.directionTech}>
          {tech.map((label) => (
            <li key={label}>{label}</li>
          ))}
        </ul>
      </PageHero>

      <section className="section">
        <div className="container">
          <h2 className="section-subtitle">{t.site.coursesInDirection}</h2>

          {loadError ? (
            <p className="filter-empty">{t.courses.loadError}</p>
          ) : directionCourses.length === 0 ? (
            <div className="direction-empty">
              <p className="filter-empty">{t.site.noCoursesInDirection}</p>
              <Link href="/courses" className="back-link">
                {t.site.viewAllCourses} →
              </Link>
            </div>
          ) : (
            <>
              <div className="course-grid">
                {directionCourses.map((course) => (
                  <CourseCard key={course.id} course={course} filteredOut={false} />
                ))}
              </div>
              <div className="direction-all">
                <Link href="/courses" className="back-link">
                  {t.site.viewAllCourses} →
                </Link>
              </div>
            </>
          )}
        </div>
      </section>

      <BackLink href="/courses" label={t.site.nav.courses} />
    </>
  );
}
