import type { Metadata } from "next";
import { CoursesCatalogPage } from "@/components/public/CoursesCatalogPage";
import { loadCourses } from "@/lib/loadCourses";

export const metadata: Metadata = {
  title: "Courses — CODESCHOOL",
};

export default async function CoursesPage() {
  const { courses, loadError } = await loadCourses();
  return <CoursesCatalogPage courses={courses} loadError={loadError} />;
}
