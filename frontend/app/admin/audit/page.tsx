import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminAudit } from "@/components/admin/AdminAudit";

export const metadata: Metadata = { title: "Audit — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminAudit />
      </AdminShell>
    </RequireAuth>
  );
}
