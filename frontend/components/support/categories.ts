import type { SupportCategory, SupportStatus, SupportTranslations } from "@/types";

export const CATEGORY_ORDER: SupportCategory[] = [
  "general", "course", "lesson", "assignment", "quiz", "code_runner",
  "progress", "certificate", "account", "parent_question", "technical",
];

export function categoryLabel(t: SupportTranslations, c: SupportCategory): string {
  const map: Record<SupportCategory, string> = {
    general: t.catGeneral,
    course: t.catCourse,
    lesson: t.catLesson,
    assignment: t.catAssignment,
    quiz: t.catQuiz,
    code_runner: t.catCodeRunner,
    progress: t.catProgress,
    certificate: t.catCertificate,
    account: t.catAccount,
    parent_question: t.catParentQuestion,
    technical: t.catTechnical,
  };
  return map[c];
}

export function statusLabel(t: SupportTranslations, s: SupportStatus): string {
  const map: Record<SupportStatus, string> = {
    open: t.stOpen,
    waiting_staff: t.stWaitingStaff,
    waiting_user: t.stWaitingUser,
    closed: t.stClosed,
  };
  return map[s];
}
