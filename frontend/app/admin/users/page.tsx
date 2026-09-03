import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminUsers } from "@/components/admin/AdminUsers";

export const metadata: Metadata = { title: "Users — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminUsers />
      </AdminShell>
    </RequireAuth>
  );
}
