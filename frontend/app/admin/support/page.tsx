import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminSupport } from "@/components/admin/AdminSupport";

export const metadata: Metadata = { title: "Support — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminSupport />
      </AdminShell>
    </RequireAuth>
  );
}
