"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { Icon } from "@/lib/icons";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { Button } from "@/components/ui/Button";
import { getCourseTag, getLevelKey } from "@/lib/courseVisuals";
import { ApiError, enrollCourse, getCourseProgress } from "@/lib/api";
import type { Course, ModuleWithLessons } from "@/types";

interface CourseDetailProps {
  course: Course;
  modules: ModuleWithLessons[];
}

export function CourseDetail({ course, modules }: CourseDetailProps) {
  const { t } = useLanguage();
  const { user, loading } = useAuth();
  const router = useRouter();
  const tag = getCourseTag(course.slug);

  // null = unknown / not applicable, true/false = enrollment known
  const [enrolled, setEnrolled] = useState<boolean | null>(null);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const isStudent = user?.role === "student";

  // Check enrollment for a signed-in student (async only — no synchronous
  // setState in the effect body).
  useEffect(() => {
    if (!isStudent) return;
    let cancelled = false;
    getCourseProgress(course.id)
      .then(() => {
        if (!cancelled) setEnrolled(true);
      })
      .catch((err) => {
        if (!cancelled) {
          setEnrolled(err instanceof ApiError && err.status === 403 ? false : null);
        }
      });
    return () => {
      cancelled = true;
    };
  }, [isStudent, course.id]);

  async function enroll() {
    setPending(true);
    setError(null);
    try {
      await enrollCourse(course.id);
      router.push(`/learn/${course.id}`);
    } catch (err) {
      if (err instanceof ApiError && err.status === 409) {
        router.push(`/learn/${course.id}`);
        return;
      }
      setError(err instanceof ApiError ? err.message : t.learn.loadError);
      setPending(false);
    }
  }

  return (
    <section className="section">
      <div className="container">
        <SectionHeading
          eyebrow={tag.label}
          title={course.title}
          description={course.description ?? course.shortDescription ?? undefined}
          align="left"
        />

        <div className="course-meta course-detail-meta">
          <span>
            <Icon name="cake" aria-hidden="true" />
            <span>{t.course.age}</span> {course.ageFrom ?? "—"}–{course.ageTo ?? "—"}{" "}
            <span>{t.course.years}</span>
          </span>
          <span>
            <Icon name="book-open" aria-hidden="true" />
            {course.durationLessons ?? 0} <span>{t.course.lessons}</span>
          </span>
          <span>
            <Icon name="folder-kanban" aria-hidden="true" />
            {course.projectsCount ?? 0} <span>{t.course.projects}</span>
          </span>
          <span className="course-level">{t.course[getLevelKey(course.difficulty)]}</span>
        </div>

        {!loading && (
          <div className="course-detail-cta">
            {!user && (
              <Button href="/login" variant="primary">
                {t.learn.loginToStart}
              </Button>
            )}
            {isStudent && enrolled === false && (
              <Button type="button" variant="primary" onClick={enroll} disabled={pending}>
                {pending ? t.auth.submitting : t.learn.startLearning}
              </Button>
            )}
            {isStudent && enrolled === true && (
              <Button href={`/learn/${course.id}`} variant="primary">
                {t.learn.openCourse}
              </Button>
            )}
            {error && (
              <p className="auth-error" role="alert">
                {error}
              </p>
            )}
          </div>
        )}

        <h3 className="course-detail-heading">{t.courseDetail.modulesHeading}</h3>

        {modules.length > 0 ? (
          <div className="whyus-grid">
            {modules.map((m) => (
              <div className="why-card" key={m.id}>
                <Icon name="book-open" aria-hidden="true" />
                <span>{m.title}</span>
              </div>
            ))}
          </div>
        ) : (
          <p className="filter-empty">{t.courseDetail.noModules}</p>
        )}

        <div className="course-detail-back">
          <Button href="/courses" variant="ghost">
            {t.courseDetail.backToCourses}
          </Button>
        </div>
      </div>
    </section>
  );
}
