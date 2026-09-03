import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminAcademy } from "@/components/admin/AdminAcademy";

export const metadata: Metadata = { title: "Academy — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminAcademy />
      </AdminShell>
    </RequireAuth>
  );
}
