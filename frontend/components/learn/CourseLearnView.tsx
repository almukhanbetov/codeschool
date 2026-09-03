"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Icon } from "@/lib/icons";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { ApiError, getAcademyCourseContent, getCourseContent, getCourseProgress } from "@/lib/api";
import type { CourseContent, CourseProgressDetail, LessonProgressStatus } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notEnrolled" }
  | { kind: "error" }
  | { kind: "ready"; content: CourseContent; progress: CourseProgressDetail };

export function CourseLearnView({
  courseId,
  apiPrefix = "",
  basePath = "/learn",
  backHref = "/student",
}: {
  courseId: number;
  apiPrefix?: string;
  basePath?: string;
  backHref?: string;
}) {
  const { t } = useLanguage();
  const isAcademy = apiPrefix === "/teacher-academy";
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [content, progress] = await Promise.all([
          isAcademy ? getAcademyCourseContent(courseId) : getCourseContent(courseId),
          getCourseProgress(courseId, apiPrefix),
        ]);
        if (!cancelled) setState({ kind: "ready", content, progress });
      } catch (err) {
        if (cancelled) return;
        if (err instanceof ApiError && err.status === 403) {
          setState({ kind: "notEnrolled" });
        } else {
          setState({ kind: "error" });
        }
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [courseId, apiPrefix, isAcademy]);

  if (state.kind === "loading") {
    return <Centered>{t.learn.loading}</Centered>;
  }
  if (state.kind === "error") {
    return <Centered error>{t.learn.loadError}</Centered>;
  }
  if (state.kind === "notEnrolled") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.learn.notEnrolled}</p>
          <Button href={isAcademy ? "/teacher-academy/courses" : "/courses"} variant="primary">
            {isAcademy ? t.academy.browseCourses : t.student.browseCourses}
          </Button>
        </div>
      </section>
    );
  }

  const { content, progress } = state;
  const statusByLesson = new Map<number, LessonProgressStatus>(
    progress.lessons.map((l) => [l.lessonId, l.status])
  );
  const nextLesson =
    progress.lessons.find((l) => l.status !== "completed")?.lessonId ??
    content.modules[0]?.lessons[0]?.id;

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{content.course.title}</span>
            <h1 className="student-dash-title">{t.student.myCourses}</h1>
          </div>
          <Link href={backHref} className="student-viewall">
            {t.learn.backToDashboard}
          </Link>
        </div>

        <div className="student-overall">
          <ProgressBar
            percent={progress.progressPercent}
            label={`${progress.completedLessons}/${progress.totalLessons} ${t.student.lessonsDone}`}
          />
          {nextLesson && (
            <Button href={`${basePath}/${courseId}/lesson/${nextLesson}`} variant="primary" size="sm">
              {t.student.continueLearning}
            </Button>
          )}
        </div>

        <div className="learn-modules">
          {content.modules.map((m) => (
            <div className="learn-module" key={m.id}>
              <h3>{m.title}</h3>
              <ul className="learn-lesson-list">
                {m.lessons.map((lesson) => {
                  const status = statusByLesson.get(lesson.id) ?? "not_started";
                  return (
                    <li key={lesson.id}>
                      <Link
                        href={`${basePath}/${courseId}/lesson/${lesson.id}`}
                        className={`learn-lesson-row learn-lesson-${status}`}
                      >
                        <span className="learn-lesson-icon" aria-hidden="true">
                          <Icon
                            name={
                              status === "completed"
                                ? "trending-up"
                                : status === "in_progress"
                                  ? "book-open"
                                  : "chevron-right"
                            }
                          />
                        </span>
                        <span className="learn-lesson-title">{lesson.title}</span>
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Centered({ children, error }: { children: React.ReactNode; error?: boolean }) {
  return (
    <section className="section">
      <div className="container">
        <p className={error ? "auth-error" : "filter-empty"}>{children}</p>
      </div>
    </section>
  );
}
