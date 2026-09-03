import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AcademyDashboard } from "@/components/academy/AcademyDashboard";

export const metadata: Metadata = { title: "My learning — Teacher Academy" };

export default function Page() {
  return (
    <RequireAuth roles={["teacher"]}>
      <AcademyDashboard />
    </RequireAuth>
  );
}
