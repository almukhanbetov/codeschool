import type { Metadata } from "next";
import { DirectionPage } from "@/components/public/DirectionPage";
import { loadCourses } from "@/lib/loadCourses";

export const metadata: Metadata = { title: "Programming — CODESCHOOL" };

export default async function Page() {
  const { courses, loadError } = await loadCourses();
  return <DirectionPage direction="programming" courses={courses} loadError={loadError} />;
}
