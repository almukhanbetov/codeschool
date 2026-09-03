import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { LessonLearnView } from "@/components/learn/LessonLearnView";

export const metadata: Metadata = { title: "Academy lesson — Teacher Academy" };

export default async function Page(
  props: PageProps<"/teacher-academy/learn/[courseId]/lesson/[lessonId]">
) {
  const { courseId, lessonId } = await props.params;
  return (
    <RequireAuth roles={["teacher"]}>
      <LessonLearnView
        courseId={Number(courseId)}
        lessonId={Number(lessonId)}
        apiPrefix="/teacher-academy"
        basePath="/teacher-academy/learn"
        notEnrolledHref="/teacher-academy/courses"
      />
    </RequireAuth>
  );
}
