import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { MyCertificates } from "@/components/certificates/MyCertificates";

export const metadata: Metadata = {
  title: "My certificates — CODESCHOOL",
};

export default function StudentCertificatesPage() {
  return (
    <RequireAuth roles={["student"]}>
      <MyCertificates />
    </RequireAuth>
  );
}
