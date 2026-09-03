import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { AdminShell } from "@/components/admin/AdminShell";
import { AdminCertificates } from "@/components/admin/AdminCertificates";

export const metadata: Metadata = { title: "Certificates — CODESCHOOL" };

export default function Page() {
  return (
    <RequireAuth roles={["admin"]}>
      <AdminShell>
        <AdminCertificates />
      </AdminShell>
    </RequireAuth>
  );
}
