"use client";

import { useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { downloadCertificatePdf } from "@/lib/api";
import type { Certificate } from "@/types";

/** One issued certificate, with PDF download + public-verification link. */
export function CertificateCard({ cert }: { cert: Certificate }) {
  const { t, lang } = useLanguage();
  const c = t.certificates;
  const [downloading, setDownloading] = useState(false);

  const issued = new Date(cert.issuedAt).toLocaleDateString();
  const revoked = cert.status === "revoked";

  async function download() {
    setDownloading(true);
    try {
      await downloadCertificatePdf(cert.id, lang, `certificate-${cert.certificateNumber}`);
    } finally {
      setDownloading(false);
    }
  }

  return (
    <article className="course-card">
      <div className={`course-tag ${revoked ? "course-tag-neutral" : "course-tag-neutral"}`}>
        {revoked ? c.statusRevoked : c.statusActive}
      </div>
      <h3>{cert.course.title}</h3>
      <dl className="cert-meta">
        <div>
          <dt>{c.colNumber}</dt>
          <dd>{cert.certificateNumber}</dd>
        </div>
        <div>
          <dt>{c.colIssued}</dt>
          <dd>{issued}</dd>
        </div>
      </dl>
      <div className="assignment-actions">
        <Button variant="primary" size="sm" onClick={download} disabled={downloading}>
          {downloading ? c.downloading : c.downloadPdf}
        </Button>
        <Link
          href={`/certificates/verify/${cert.verificationCode}`}
          className="admin-link admin-link-strong"
        >
          {c.verify}
        </Link>
      </div>
    </article>
  );
}
