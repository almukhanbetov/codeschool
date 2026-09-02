import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { TeacherGroups } from "@/components/teacher/TeacherGroups";

export const metadata: Metadata = {
  title: "My groups — CODESCHOOL",
};

export default function TeacherGroupsPage() {
  return (
    <RequireAuth roles={["teacher"]}>
      <TeacherGroups />
    </RequireAuth>
  );
}
