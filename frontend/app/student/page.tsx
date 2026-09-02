import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { StudentDashboard } from "@/components/student/StudentDashboard";

export const metadata: Metadata = {
  title: "Student — CODESCHOOL",
};

export default function StudentPage() {
  return (
    <RequireAuth roles={["student"]}>
      <StudentDashboard />
    </RequireAuth>
  );
}
