import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { ParentDashboard } from "@/components/parent/ParentDashboard";

export const metadata: Metadata = {
  title: "Parent — CODESCHOOL",
};

export default function ParentPage() {
  return (
    <RequireAuth roles={["parent"]}>
      <ParentDashboard />
    </RequireAuth>
  );
}
