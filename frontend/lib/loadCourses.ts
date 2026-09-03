import { getCourses } from "@/lib/api";
import type { Course } from "@/types";

/**
 * Server-side course load shared by the public pages. The backend already
 * hides `audience = 'teacher'` courses from this endpoint (course-audience
 * hardening), so the public catalog and every direction page inherit that.
 * A backend outage degrades to `loadError` — never fabricated data.
 */
export async function loadCourses(): Promise<{ courses: Course[]; loadError: boolean }> {
  try {
    return { courses: await getCourses(), loadError: false };
  } catch {
    return { courses: [], loadError: true };
  }
}
