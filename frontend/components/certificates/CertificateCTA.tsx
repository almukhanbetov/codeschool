"use client";

import { useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { downloadCertificatePdf, issueCertificate } from "@/lib/api";
import type { Certificate } from "@/types";

interface Props {
  courseId: number;
  eligible: boolean;
  /** "" for students, "/teacher-academy" for academy learners. */
  prefix?: string;
  /** A certificate already issued for this course, if the caller knows of one. */
  existing?: Certificate;
}

/**
 * Course-completion certificate call to action. Before the course is
 * complete it shows a muted "not available yet" hint; once eligible (or a
 * certificate already exists) it shows the issue / download actions.
 * Eligibility is re-checked authoritatively by the backend on issue — this
 * flag only drives the UI.
 */
export function CertificateCTA({ courseId, eligible, prefix = "", existing }: Props) {
  const { t, lang } = useLanguage();
  const c = t.certificates;
  const [cert, setCert] = useState<Certificate | null>(existing ?? null);
  const [busy, setBusy] = useState<"issue" | "download" | null>(null);
  const [error, setError] = useState(false);

  if (!eligible && !cert) {
    return <p className="cert-cta-hint">{c.notEligibleYet}</p>;
  }

  async function issue() {
    setBusy("issue");
    setError(false);
    try {
      setCert(await issueCertificate(courseId, prefix));
    } catch {
      setError(true);
    } finally {
      setBusy(null);
    }
  }

  async function download() {
    if (!cert) return;
    setBusy("download");
    try {
      await downloadCertificatePdf(cert.id, lang, `certificate-${cert.certificateNumber}`);
    } finally {
      setBusy(null);
    }
  }

  return (
    <div className="cert-cta">
      {cert ? (
        <>
          <Button variant="secondary" size="sm" onClick={download} disabled={busy !== null}>
            {busy === "download" ? c.downloading : c.downloadPdf}
          </Button>
          <Link
            href={`/certificates/verify/${cert.verificationCode}`}
            className="admin-link admin-link-strong"
          >
            {c.verify}
          </Link>
        </>
      ) : (
        <Button variant="secondary" size="sm" onClick={issue} disabled={busy !== null}>
          {busy === "issue" ? c.issuing : c.getCertificate}
        </Button>
      )}
      {error && <span className="auth-error">{c.issueError}</span>}
    </div>
  );
}
