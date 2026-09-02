import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { MyCourses } from "@/components/student/MyCourses";

export const metadata: Metadata = {
  title: "My courses — CODESCHOOL",
};

export default function StudentCoursesPage() {
  return (
    <RequireAuth roles={["student"]}>
      <MyCourses />
    </RequireAuth>
  );
}
