import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { RoleDashboard } from "@/components/sections/RoleDashboard";

export const metadata: Metadata = {
  title: "Admin — CODESCHOOL",
};

export default function AdminPage() {
  return (
    <RequireAuth roles={["admin"]}>
      <RoleDashboard role="admin" />
    </RequireAuth>
  );
}
