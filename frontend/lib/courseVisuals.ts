// The database stores course content (title, description, ages, ...) but
// deliberately no CSS/branding — the per-course badge color and label are
// presentation, so they stay here, keyed by the stable `slug`.

import type { CourseDifficulty } from "@/types";

interface CourseTag {
  label: string;
  className: string;
}

const TAG_BY_SLUG: Record<string, CourseTag> = {
  "algorithms-basics": { label: "Algo", className: "ct-algo" },
  "scratch-junior": { label: "Scratch", className: "ct-scratch" },
  "python-start": { label: "Python", className: "ct-python" },
  "robotics-arduino": { label: "Arduino", className: "ct-robotics" },
  "web-development": { label: "Web", className: "ct-web" },
  "ai-junior": { label: "AI", className: "ct-ai" },
};

const DEFAULT_TAG: CourseTag = { label: "Course", className: "ct-python" };

export function getCourseTag(slug: string): CourseTag {
  return TAG_BY_SLUG[slug] ?? DEFAULT_TAG;
}

type LevelKey = "levelBeginner" | "levelMiddle" | "levelAdvanced";

const DIFFICULTY_TO_LEVEL_KEY: Record<CourseDifficulty, LevelKey> = {
  beginner: "levelBeginner",
  intermediate: "levelMiddle",
  advanced: "levelAdvanced",
};

export function getLevelKey(difficulty: CourseDifficulty | null): LevelKey {
  return difficulty ? DIFFICULTY_TO_LEVEL_KEY[difficulty] : "levelBeginner";
}
