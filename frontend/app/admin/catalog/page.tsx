import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminCatalog } from "@/components/admin/AdminCatalog";

export const metadata: Metadata = { title: "Catalog — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminCatalog />
      </AdminShell>
    </RequireAuth>
  );
}
