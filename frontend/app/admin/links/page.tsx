import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminLinks } from "@/components/admin/AdminLinks";

export const metadata: Metadata = { title: "Links — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminLinks />
      </AdminShell>
    </RequireAuth>
  );
}
