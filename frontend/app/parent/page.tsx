import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { RoleDashboard } from "@/components/sections/RoleDashboard";

export const metadata: Metadata = {
  title: "Parent — CODESCHOOL",
};

export default function ParentPage() {
  return (
    <RequireAuth roles={["parent"]}>
      <RoleDashboard role="parent" />
    </RequireAuth>
  );
}
