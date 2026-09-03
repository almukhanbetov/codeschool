import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { QuizRunner } from "@/components/learn/QuizRunner";

export const metadata: Metadata = {
  title: "Quiz — CODESCHOOL",
};

export default async function LearnQuizPage(
  props: PageProps<"/learn/[courseId]/lesson/[lessonId]/quiz/[assignmentId]">
) {
  const { courseId, lessonId, assignmentId } = await props.params;
  return (
    <RequireAuth roles={["student"]}>
      <QuizRunner
        courseId={Number(courseId)}
        lessonId={Number(lessonId)}
        assignmentId={Number(assignmentId)}
      />
    </RequireAuth>
  );
}
