export type TeacherStepKey = "step1" | "step2" | "step3" | "step4" | "step5";

export interface TeacherStep {
  num: number;
  key: TeacherStepKey;
}

export const teacherSteps: TeacherStep[] = [
  { num: 1, key: "step1" },
  { num: 2, key: "step2" },
  { num: 3, key: "step3" },
  { num: 4, key: "step4" },
  { num: 5, key: "step5" },
];
