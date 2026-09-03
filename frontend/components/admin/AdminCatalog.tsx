"use client";

import { useMemo, useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";
import { adminApi } from "@/lib/api";
import { EntityManager, type ColumnDef, type FieldDef } from "@/components/admin/EntityManager";
import { AdminQuizEditor } from "@/components/admin/AdminQuizEditor";
import type {
  AdminAssignment,
  AdminCourse,
  AdminLesson,
  AdminModule,
  AdminProgram,
  AdminLevel,
} from "@/types";

type Crumb = { program?: AdminProgram; level?: AdminLevel; course?: AdminCourse; module?: AdminModule; lesson?: AdminLesson };

export function AdminCatalog() {
  const { t } = useLanguage();
  const a = t.admin;
  const [crumb, setCrumb] = useState<Crumb>({});
  const [quizFor, setQuizFor] = useState<AdminAssignment | null>(null);

  const boolCol = (get: (r: { isPublished: boolean }) => boolean): ColumnDef<{ isPublished: boolean }> => ({
    label: a.fPublished,
    render: (r) => (get(r) ? a.yes : <span className="admin-muted">{a.no}</span>),
  });

  const titleCol = <R extends { title: string; position?: number }>(): ColumnDef<R> => ({
    label: a.fTitle,
    render: (r) => (
      <span className="teacher-cell-title">
        {typeof r.position === "number" ? `${r.position}. ` : ""}
        {r.title}
      </span>
    ),
  });

  const level = crumb.level;
  const course = crumb.course;
  const module_ = crumb.module;
  const lesson = crumb.lesson;

  const crumbs = useMemo(() => {
    const items: { label: string; onClick: () => void }[] = [
      { label: a.programs, onClick: () => setCrumb({}) },
    ];
    if (crumb.program) items.push({ label: crumb.program.title, onClick: () => setCrumb({ program: crumb.program }) });
    if (crumb.level)
      items.push({ label: crumb.level.title, onClick: () => setCrumb({ program: crumb.program, level: crumb.level }) });
    if (crumb.course)
      items.push({
        label: crumb.course.title,
        onClick: () => setCrumb({ program: crumb.program, level: crumb.level, course: crumb.course }),
      });
    if (crumb.module)
      items.push({
        label: crumb.module.title,
        onClick: () =>
          setCrumb({ program: crumb.program, level: crumb.level, course: crumb.course, module: crumb.module }),
      });
    if (crumb.lesson) items.push({ label: crumb.lesson.title, onClick: () => {} });
    return items;
  }, [crumb, a.programs]);

  const numberField = (key: string, label: string): FieldDef => ({ key, label, type: "number" });

  return (
    <>
      <h1 className="student-dash-title">{a.navCatalog}</h1>

      <nav className="admin-breadcrumb" aria-label="catalog path">
        {crumbs.map((c, i) => (
          <span key={i}>
            {i > 0 && <span className="admin-breadcrumb-sep">/</span>}
            <button type="button" className="admin-link" onClick={c.onClick} disabled={i === crumbs.length - 1}>
              {c.label}
            </button>
          </span>
        ))}
      </nav>

      {/* level 1: programs */}
      {!crumb.program && (
        <EntityManager<AdminProgram>
          title={a.programs}
          crud={adminApi.programs}
          newLabel={a.newProgram}
          rowId={(r) => r.id}
          rowValues={(r) => ({
            title: r.title,
            slug: r.slug,
            description: r.description,
            ageFrom: r.ageFrom,
            ageTo: r.ageTo,
            isActive: r.isActive,
          })}
          fields={[
            { key: "title", label: a.fTitle, required: true },
            { key: "slug", label: a.fSlug, required: true },
            { key: "description", label: a.fDescription, type: "textarea" },
            numberField("ageFrom", a.fAgeFrom),
            numberField("ageTo", a.fAgeTo),
            { key: "isActive", label: a.fActive, type: "bool" },
          ]}
          columns={[
            { label: "ID", render: (r) => r.id },
            titleCol<AdminProgram>(),
            { label: a.fSlug, render: (r) => <code>{r.slug}</code> },
            { label: a.fActive, render: (r) => (r.isActive ? a.yes : <span className="admin-muted">{a.no}</span>) },
          ]}
          extraAction={{ label: a.openCurriculum, onClick: (r) => setCrumb({ program: r }) }}
        />
      )}

      {/* level 2: levels of a program */}
      {crumb.program && !crumb.level && (
        <EntityManager<AdminLevel>
          title={`${a.levels} — ${crumb.program.title}`}
          crud={adminApi.levels}
          query={{ programId: crumb.program.id }}
          fixed={{ programId: crumb.program.id }}
          newLabel={a.newLevel}
          rowId={(r) => r.id}
          rowValues={(r) => ({
            title: r.title,
            description: r.description,
            ageFrom: r.ageFrom,
            ageTo: r.ageTo,
            position: r.position,
          })}
          fields={[
            { key: "title", label: a.fTitle, required: true },
            { key: "description", label: a.fDescription, type: "textarea" },
            numberField("ageFrom", a.fAgeFrom),
            numberField("ageTo", a.fAgeTo),
            numberField("position", a.fPosition),
          ]}
          columns={[{ label: "ID", render: (r) => r.id }, titleCol<AdminLevel>()]}
          extraAction={{ label: a.openCurriculum, onClick: (r) => setCrumb({ program: crumb.program, level: r }) }}
        />
      )}

      {/* level 3: courses of a level */}
      {level && !course && (
        <EntityManager<AdminCourse>
          title={`${a.courses} — ${level.title}`}
          crud={adminApi.courses}
          query={{ levelId: level.id }}
          fixed={{ levelId: level.id }}
          newLabel={a.newCourse}
          rowId={(r) => r.id}
          rowValues={(r) => ({
            title: r.title,
            slug: r.slug,
            shortDescription: r.shortDescription,
            description: r.description,
            imageUrl: r.imageUrl,
            difficulty: r.difficulty,
            ageFrom: r.ageFrom,
            ageTo: r.ageTo,
            durationLessons: r.durationLessons,
            projectsCount: r.projectsCount,
            position: r.position,
            isPublished: r.isPublished,
          })}
          fields={[
            { key: "title", label: a.fTitle, required: true },
            { key: "slug", label: a.fSlug, required: true },
            { key: "shortDescription", label: a.fShortDescription },
            { key: "description", label: a.fDescription, type: "textarea" },
            { key: "imageUrl", label: a.fImageUrl },
            {
              key: "difficulty",
              label: a.fDifficulty,
              type: "select",
              options: ["beginner", "intermediate", "advanced"].map((d) => ({ value: d, label: d })),
            },
            numberField("ageFrom", a.fAgeFrom),
            numberField("ageTo", a.fAgeTo),
            numberField("durationLessons", a.fDuration),
            numberField("projectsCount", a.fProjects),
            numberField("position", a.fPosition),
            { key: "isPublished", label: a.fPublished, type: "bool" },
          ]}
          columns={[
            { label: "ID", render: (r) => r.id },
            titleCol<AdminCourse>(),
            { label: a.fSlug, render: (r) => <code>{r.slug}</code> },
            boolCol((r) => (r as AdminCourse).isPublished) as ColumnDef<AdminCourse>,
          ]}
          extraAction={{
            label: a.openCurriculum,
            onClick: (r) => setCrumb({ program: crumb.program, level, course: r }),
          }}
        />
      )}

      {/* level 4: modules of a course */}
      {course && !module_ && (
        <EntityManager<AdminModule>
          title={`${a.modules} — ${course.title}`}
          crud={adminApi.modules}
          query={{ courseId: course.id }}
          fixed={{ courseId: course.id }}
          newLabel={a.newModule}
          rowId={(r) => r.id}
          rowValues={(r) => ({ title: r.title, description: r.description, position: r.position })}
          fields={[
            { key: "title", label: a.fTitle, required: true },
            { key: "description", label: a.fDescription, type: "textarea" },
            numberField("position", a.fPosition),
          ]}
          columns={[{ label: "ID", render: (r) => r.id }, titleCol<AdminModule>()]}
          extraAction={{
            label: a.openCurriculum,
            onClick: (r) => setCrumb({ program: crumb.program, level, course, module: r }),
          }}
        />
      )}

      {/* level 5: lessons of a module */}
      {module_ && !lesson && (
        <EntityManager<AdminLesson>
          title={`${a.lessons} — ${module_.title}`}
          crud={adminApi.lessons}
          query={{ moduleId: module_.id }}
          fixed={{ moduleId: module_.id }}
          newLabel={a.newLesson}
          rowId={(r) => r.id}
          rowValues={(r) => ({
            title: r.title,
            slug: r.slug,
            description: r.description,
            content: r.content,
            videoUrl: r.videoUrl,
            lessonType: r.lessonType,
            position: r.position,
            isPublished: r.isPublished,
          })}
          fields={[
            { key: "title", label: a.fTitle, required: true },
            { key: "slug", label: a.fSlug },
            { key: "description", label: a.fDescription, type: "textarea" },
            { key: "content", label: a.fContent, type: "textarea" },
            { key: "videoUrl", label: a.fVideoUrl },
            {
              key: "lessonType",
              label: a.fLessonType,
              type: "select",
              options: ["text", "video", "code", "quiz", "project"].map((v) => ({ value: v, label: v })),
            },
            numberField("position", a.fPosition),
            { key: "isPublished", label: a.fPublished, type: "bool" },
          ]}
          columns={[
            { label: "ID", render: (r) => r.id },
            titleCol<AdminLesson>(),
            { label: a.fLessonType, render: (r) => r.lessonType },
            boolCol((r) => (r as AdminLesson).isPublished) as ColumnDef<AdminLesson>,
          ]}
          extraAction={{
            label: a.assignments,
            onClick: (r) => setCrumb({ program: crumb.program, level, course, module: module_, lesson: r }),
          }}
        />
      )}

      {/* level 6: assignments of a lesson */}
      {lesson && (
        <EntityManager<AdminAssignment>
          title={`${a.assignments} — ${lesson.title}`}
          crud={adminApi.assignments}
          query={{ lessonId: lesson.id }}
          fixed={{ lessonId: lesson.id }}
          newLabel={a.newAssignment}
          rowId={(r) => r.id}
          rowValues={(r) => ({
            title: r.title,
            description: r.description,
            assignmentType: r.assignmentType,
            starterCode: r.starterCode,
            expectedOutput: r.expectedOutput,
            points: r.points,
            position: r.position,
            isPublished: r.isPublished,
          })}
          fields={[
            { key: "title", label: a.fTitle, required: true },
            { key: "description", label: a.fDescription, type: "textarea" },
            {
              key: "assignmentType",
              label: a.fAssignmentType,
              type: "select",
              required: true,
              options: ["text", "code", "quiz", "project"].map((v) => ({ value: v, label: v })),
            },
            { key: "starterCode", label: a.fStarterCode, type: "textarea" },
            { key: "expectedOutput", label: a.fExpectedOutput, type: "textarea" },
            numberField("points", a.fPoints),
            numberField("position", a.fPosition),
            { key: "isPublished", label: a.fPublished, type: "bool" },
          ]}
          columns={[
            { label: "ID", render: (r) => r.id },
            titleCol<AdminAssignment>(),
            { label: a.fAssignmentType, render: (r) => r.assignmentType },
            { label: a.fPoints, render: (r) => r.points },
            boolCol((r) => (r as AdminAssignment).isPublished) as ColumnDef<AdminAssignment>,
          ]}
          rowExtra={(r) =>
            r.assignmentType === "quiz" ? (
              <button
                type="button"
                className="admin-link admin-link-strong"
                onClick={() => setQuizFor(r)}
              >
                {a.quizConfigure}
              </button>
            ) : null
          }
        />
      )}

      {quizFor && <AdminQuizEditor assignment={quizFor} onClose={() => setQuizFor(null)} />}
    </>
  );
}
