import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { QuizRunner } from "@/components/learn/QuizRunner";

export const metadata: Metadata = { title: "Academy quiz — Teacher Academy" };

export default async function Page(
  props: PageProps<"/teacher-academy/learn/[courseId]/lesson/[lessonId]/quiz/[assignmentId]">
) {
  const { courseId, lessonId, assignmentId } = await props.params;
  return (
    <RequireAuth roles={["teacher"]}>
      <QuizRunner
        courseId={Number(courseId)}
        lessonId={Number(lessonId)}
        assignmentId={Number(assignmentId)}
        apiPrefix="/teacher-academy"
        basePath="/teacher-academy/learn"
      />
    </RequireAuth>
  );
}
