import type { Metadata } from "next";
import { CertificateVerify } from "@/components/certificates/CertificateVerify";

export const metadata: Metadata = {
  title: "Verify certificate — CODESCHOOL",
  robots: { index: false },
};

export default async function CertificateVerifyPage(props: {
  params: Promise<{ code: string }>;
}) {
  const { code } = await props.params;
  return <CertificateVerify code={decodeURIComponent(code)} />;
}
