import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { LessonLearnView } from "@/components/learn/LessonLearnView";

export const metadata: Metadata = {
  title: "Lesson — CODESCHOOL",
};

export default async function LearnLessonPage(
  props: PageProps<"/learn/[courseId]/lesson/[lessonId]">
) {
  const { courseId, lessonId } = await props.params;
  return (
    <RequireAuth roles={["student"]}>
      <LessonLearnView courseId={Number(courseId)} lessonId={Number(lessonId)} />
    </RequireAuth>
  );
}
