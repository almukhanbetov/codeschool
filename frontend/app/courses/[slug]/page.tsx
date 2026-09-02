import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CourseDetail } from "@/components/sections/CourseDetail";
import { ApiError, getCourseBySlug, getCourseContent } from "@/lib/api";

export async function generateMetadata(props: PageProps<"/courses/[slug]">): Promise<Metadata> {
  const { slug } = await props.params;
  try {
    const course = await getCourseBySlug(slug);
    return { title: `${course.title} — CODESCHOOL` };
  } catch {
    return { title: "Course — CODESCHOOL" };
  }
}

export default async function CourseDetailPage(props: PageProps<"/courses/[slug]">) {
  const { slug } = await props.params;

  let course;
  try {
    course = await getCourseBySlug(slug);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) {
      notFound();
    }
    throw err;
  }

  const content = await getCourseContent(course.id);

  return <CourseDetail course={course} modules={content.modules} />;
}
