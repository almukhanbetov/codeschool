import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { TeacherReview } from "@/components/teacher/TeacherReview";

export const metadata: Metadata = {
  title: "Review — CODESCHOOL",
};

export default async function TeacherReviewPage(props: PageProps<"/teacher/submissions/[id]">) {
  const { id } = await props.params;
  return (
    <RequireAuth roles={["teacher"]}>
      <TeacherReview submissionId={Number(id)} />
    </RequireAuth>
  );
}
