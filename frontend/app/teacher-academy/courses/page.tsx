import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AcademyCourses } from "@/components/academy/AcademyCourses";

export const metadata: Metadata = { title: "Academy courses — Teacher Academy" };

export default function Page() {
  return (
    <RequireAuth roles={["teacher"]}>
      <AcademyCourses />
    </RequireAuth>
  );
}
