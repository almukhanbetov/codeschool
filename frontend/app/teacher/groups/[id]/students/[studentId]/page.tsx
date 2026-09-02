import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { TeacherStudentDetail } from "@/components/teacher/TeacherStudentDetail";

export const metadata: Metadata = {
  title: "Student — CODESCHOOL",
};

export default async function TeacherStudentPage(
  props: PageProps<"/teacher/groups/[id]/students/[studentId]">
) {
  const { id, studentId } = await props.params;
  return (
    <RequireAuth roles={["teacher"]}>
      <TeacherStudentDetail groupId={Number(id)} studentId={Number(studentId)} />
    </RequireAuth>
  );
}
