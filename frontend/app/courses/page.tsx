import type { Metadata } from "next";
import { CoursesSection } from "@/components/sections/CoursesSection";
import { getCourses } from "@/lib/api";
import type { Course } from "@/types";

export const metadata: Metadata = {
  title: "Courses — CODESCHOOL",
};

async function loadCourses(): Promise<{ courses: Course[]; loadError: boolean }> {
  try {
    const courses = await getCourses();
    return { courses, loadError: false };
  } catch {
    return { courses: [], loadError: true };
  }
}

export default async function CoursesPage() {
  const { courses, loadError } = await loadCourses();
  return <CoursesSection courses={courses} loadError={loadError} />;
}
