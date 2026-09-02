import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { TeacherGroupDetail } from "@/components/teacher/TeacherGroupDetail";

export const metadata: Metadata = {
  title: "Group — CODESCHOOL",
};

export default async function TeacherGroupPage(props: PageProps<"/teacher/groups/[id]">) {
  const { id } = await props.params;
  return (
    <RequireAuth roles={["teacher"]}>
      <TeacherGroupDetail groupId={Number(id)} />
    </RequireAuth>
  );
}
