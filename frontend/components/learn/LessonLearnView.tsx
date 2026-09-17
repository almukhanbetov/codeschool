"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Icon } from "@/lib/icons";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { AssignmentPanel } from "@/components/learn/AssignmentPanel";
import { LessonVideo } from "@/components/learn/LessonVideo";
import { LessonContent } from "@/components/learn/LessonContent";
import { AskCuratorButton } from "@/components/support/AskCuratorButton";
import {
  ApiError,
  completeLesson,
  getAcademyCourseContent,
  getCourseContent,
  getCourseProgress,
  getLessonAssignments,
  getMySubmission,
  startLesson,
} from "@/lib/api";
import type {
  Assignment,
  CourseContent,
  CourseProgressDetail,
  Lesson,
  LessonProgressStatus,
  Submission,
} from "@/types";

interface Loaded {
  content: CourseContent;
  progress: CourseProgressDetail;
  lesson: Lesson;
  assignments: Assignment[];
  submissions: Map<number, Submission | null>;
}

type State =
  | { kind: "loading" }
  | { kind: "notEnrolled" }
  | { kind: "notFound" }
  | { kind: "error" }
  | { kind: "ready"; data: Loaded };

export function LessonLearnView({
  courseId,
  lessonId,
  apiPrefix = "",
  basePath = "/learn",
  notEnrolledHref = "/courses",
}: {
  courseId: number;
  lessonId: number;
  /** "" for the student flow, "/teacher-academy" for the academy */
  apiPrefix?: string;
  /** URL base for lesson links, e.g. "/learn" or "/teacher-academy/learn" */
  basePath?: string;
  notEnrolledHref?: string;
}) {
  const { t } = useLanguage();
  const isAcademy = apiPrefix === "/teacher-academy";
  const [state, setState] = useState<State>({ kind: "loading" });
  const [lessonStatus, setLessonStatus] = useState<LessonProgressStatus>("not_started");
  const [submittedIds, setSubmittedIds] = useState<Set<number>>(new Set());
  const [completing, setCompleting] = useState(false);
  const [completeError, setCompleteError] = useState<string | null>(null);
  const [courseDone, setCourseDone] = useState(false);
  const startedFor = useRef<number | null>(null);

  const load = useCallback(async () => {
    try {
      const [content, progress, assignments] = await Promise.all([
        isAcademy ? getAcademyCourseContent(courseId) : getCourseContent(courseId),
        getCourseProgress(courseId, apiPrefix),
        getLessonAssignments(lessonId, apiPrefix),
      ]);
      const lesson = content.modules.flatMap((m) => m.lessons).find((l) => l.id === lessonId);
      if (!lesson) {
        setState({ kind: "notFound" });
        return;
      }
      // Quiz assignments have no submissions row (their state lives in
      // quiz_attempts) — the AssignmentPanel loads that itself.
      const submissionEntries = await Promise.all(
        assignments.map(async (a) =>
          [a.id, a.assignmentType === "quiz" ? null : await getMySubmission(a.id, apiPrefix)] as const
        )
      );
      const submissions = new Map(submissionEntries);

      setState({ kind: "ready", data: { content, progress, lesson, assignments, submissions } });
      setLessonStatus(progress.lessons.find((l) => l.lessonId === lessonId)?.status ?? "not_started");
      setSubmittedIds(
        new Set(
          submissionEntries
            .filter(([, s]) => s != null && s.status !== "draft")
            .map(([id]) => id)
        )
      );
    } catch (err) {
      if (err instanceof ApiError && err.status === 403) setState({ kind: "notEnrolled" });
      else if (err instanceof ApiError && err.status === 404) setState({ kind: "notFound" });
      else setState({ kind: "error" });
    }
  }, [courseId, lessonId, apiPrefix, isAcademy]);

  useEffect(() => {
    // Data fetch on mount / when the lesson changes — the setState calls it
    // makes are all inside async continuations, not the effect body.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  // One controlled "start" call per lesson (spec §41) — never on every render.
  useEffect(() => {
    if (state.kind !== "ready") return;
    if (startedFor.current === lessonId) return;
    startedFor.current = lessonId;
    if (lessonStatus === "not_started") {
      startLesson(lessonId, apiPrefix)
        .then(() => setLessonStatus("in_progress"))
        .catch(() => {
          /* non-fatal: the page still works */
        });
    }
  }, [state.kind, lessonId, lessonStatus, apiPrefix]);

  const markSubmitted = useCallback((assignmentId: number, submitted: boolean) => {
    setSubmittedIds((prev) => {
      if (submitted === prev.has(assignmentId)) return prev; // no-op keeps the ref stable
      const next = new Set(prev);
      if (submitted) next.add(assignmentId);
      else next.delete(assignmentId);
      return next;
    });
  }, []);

  async function complete() {
    setCompleting(true);
    setCompleteError(null);
    try {
      const res = await completeLesson(lessonId, apiPrefix);
      setLessonStatus("completed");
      setCourseDone(res.enrollmentCompleted);
      await load(); // refresh sidebar + progress
    } catch (err) {
      setCompleteError(
        err instanceof ApiError ? err.message : t.learn.loadError
      );
    } finally {
      setCompleting(false);
    }
  }

  if (state.kind === "loading") return <Centered>{t.learn.loading}</Centered>;
  if (state.kind === "error") return <Centered error>{t.learn.loadError}</Centered>;
  if (state.kind === "notFound") return <Centered error>{t.learn.loadError}</Centered>;
  if (state.kind === "notEnrolled") {
    return (
      <section className="section">
        <div className="container student-empty">
          <p className="filter-empty">{t.learn.notEnrolled}</p>
          <Button href={notEnrolledHref} variant="primary">
            {isAcademy ? t.academy.browseCourses : t.student.browseCourses}
          </Button>
        </div>
      </section>
    );
  }

  const { content, progress, lesson, assignments, submissions } = state.data;
  const statusByLesson = new Map<number, LessonProgressStatus>(
    progress.lessons.map((l) => [l.lessonId, l.status])
  );
  // keep the just-updated current lesson status in sync visually
  statusByLesson.set(lessonId, lessonStatus);

  const allAssignmentsSubmitted = assignments.every((a) => submittedIds.has(a.id));
  const isCompleted = lessonStatus === "completed";

  return (
    <section className="section learn-section">
      <div className="container">
        <div className="learn-topbar">
          <Link href={`${basePath}/${courseId}`} className="student-viewall">
            {t.learn.backToCourse}
          </Link>
          <div className="learn-topbar-progress">
            <ProgressBar
              percent={progress.progressPercent}
              label={`${progress.completedLessons}/${progress.totalLessons}`}
            />
          </div>
        </div>

        <div className="learn-grid">
          <aside className="learn-sidebar">
            <h2>{t.learn.lessonsNav}</h2>
            <details className="learn-sidebar-details" open>
              <summary>{content.course.title}</summary>
              {content.modules.map((m) => (
                <div key={m.id} className="learn-sidebar-module">
                  <span className="learn-sidebar-mtitle">{m.title}</span>
                  <ul>
                    {m.lessons.map((l) => {
                      const s = statusByLesson.get(l.id) ?? "not_started";
                      const active = l.id === lessonId;
                      return (
                        <li key={l.id}>
                          <Link
                            href={`${basePath}/${courseId}/lesson/${l.id}`}
                            className={`learn-lesson-row learn-lesson-${s}${active ? " active" : ""}`}
                          >
                            <span className="learn-lesson-icon" aria-hidden="true">
                              <Icon
                                name={
                                  s === "completed"
                                    ? "trending-up"
                                    : active || s === "in_progress"
                                      ? "book-open"
                                      : "chevron-right"
                                }
                              />
                            </span>
                            <span className="learn-lesson-title">{l.title}</span>
                          </Link>
                        </li>
                      );
                    })}
                  </ul>
                </div>
              ))}
            </details>
          </aside>

          <div className="learn-main">
            <div className="learn-lesson-topline">
              <h1 className="learn-lesson-heading">{lesson.title}</h1>
              {!isAcademy && (
                <AskCuratorButton
                  label={t.support.needHelp}
                  context={{
                    courseId,
                    lessonId,
                    assignmentId: assignments[0]?.id,
                    category:
                      assignments[0]?.assignmentType === "quiz"
                        ? "quiz"
                        : assignments[0]?.assignmentType === "code"
                          ? "code_runner"
                          : assignments.length > 0
                            ? "assignment"
                            : "lesson",
                  }}
                />
              )}
            </div>
            {lesson.description && <p className="learn-lesson-lead">{lesson.description}</p>}

            <div className="learn-content">
              <h3>{t.learn.content}</h3>
              {lesson.content ? (
                <LessonContent text={lesson.content} />
              ) : (
                <p className="filter-empty">—</p>
              )}
              {lesson.videoUrl && <LessonVideo url={lesson.videoUrl} />}
            </div>

            <div className="learn-assignments">
              <h3>{t.learn.assignment}</h3>
              {assignments.length === 0 ? (
                <p className="filter-empty">{t.learn.noAssignment}</p>
              ) : (
                assignments.map((a) => (
                  <AssignmentPanel
                    key={a.id}
                    assignment={a}
                    courseId={courseId}
                    apiPrefix={apiPrefix}
                    basePath={basePath}
                    initialSubmission={submissions.get(a.id) ?? null}
                    onSubmittedChange={(sub) => markSubmitted(a.id, sub)}
                  />
                ))
              )}
            </div>

            <div className="learn-complete">
              {isCompleted ? (
                <p className="assignment-notice">
                  <Icon name="trending-up" aria-hidden="true" /> {t.learn.lessonCompleted}
                  {courseDone ? ` — ${t.learn.courseCompleted}` : ""}
                </p>
              ) : (
                <>
                  <Button
                    type="button"
                    variant="primary"
                    onClick={complete}
                    disabled={completing || (assignments.length > 0 && !allAssignmentsSubmitted)}
                  >
                    {completing ? t.learn.completing : t.learn.completeLesson}
                  </Button>
                  {assignments.length > 0 && !allAssignmentsSubmitted && (
                    <p className="assignment-hint">{t.learn.completeHint}</p>
                  )}
                </>
              )}
              {completeError && (
                <p className="auth-error" role="alert">
                  {completeError}
                </p>
              )}
            </div>

            <div className="learn-nav-bottom">
              <Button href={`${basePath}/${courseId}`} variant="ghost" size="sm">
                {t.learn.backToCourse}
              </Button>
            </div>
          </div>
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
