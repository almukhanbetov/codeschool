import type { Metadata } from "next";
import { CertificatesInfoPage } from "@/components/public/CertificatesInfoPage";

export const metadata: Metadata = { title: "Certificates — CODESCHOOL" };

export default function Page() {
  return <CertificatesInfoPage />;
}
