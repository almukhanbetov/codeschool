import type { LearningPathStage } from "@/types";

export const learningPath: LearningPathStage[] = [
  { id: "stage-1", age: "6–8", icon: "puzzle", titleKey: "stage1" },
  { id: "stage-2", age: "8–10", icon: "shapes", titleKey: "stage2" },
  { id: "stage-3", age: "10–12", icon: "file-code-2", titleKey: "stage3" },
  { id: "stage-4", age: "12–14", icon: "globe", titleKey: "stage4" },
  { id: "stage-5", age: "14–16", icon: "server", titleKey: "stage5" },
  { id: "stage-6", age: "16–18", icon: "rocket", titleKey: "stage6", final: true },
];
