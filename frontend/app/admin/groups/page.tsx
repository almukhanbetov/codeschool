import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminGroups } from "@/components/admin/AdminGroups";

export const metadata: Metadata = { title: "Groups — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminGroups />
      </AdminShell>
    </RequireAuth>
  );
}
