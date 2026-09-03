"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { ApiError, verifyCertificate } from "@/lib/api";
import type { CertificateVerification } from "@/types";

type State =
  | { kind: "loading" }
  | { kind: "notfound" }
  | { kind: "error" }
  | { kind: "ready"; data: CertificateVerification };

/** Public certificate verification page — no authentication required. */
export function CertificateVerify({ code }: { code: string }) {
  const { t } = useLanguage();
  const c = t.certificates;
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    verifyCertificate(code)
      .then((data) => !cancelled && setState({ kind: "ready", data }))
      .catch((err) => {
        if (cancelled) return;
        if (err instanceof ApiError && err.status === 404) {
          setState({ kind: "notfound" });
        } else {
          setState({ kind: "error" });
        }
      });
    return () => {
      cancelled = true;
    };
  }, [code]);

  return (
    <section className="section">
      <div className="container cert-verify-wrap">
        <span className="eyebrow">{c.verifyTitle}</span>
        <p className="admin-muted">{c.verifySubtitle}</p>

        {state.kind === "loading" && <p className="filter-empty">{c.verifyLoading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.learn.loadError}</p>}

        {state.kind === "notfound" && (
          <div className="cert-verify-card cert-verify-invalid">
            <div className="cert-verify-mark">✕</div>
            <h1>{c.verifyInvalid}</h1>
            <p className="admin-muted">{code}</p>
          </div>
        )}

        {state.kind === "ready" && (
          <div
            className={`cert-verify-card ${
              state.data.valid ? "cert-verify-valid" : "cert-verify-revoked"
            }`}
          >
            <div className="cert-verify-mark">{state.data.valid ? "✓" : "!"}</div>
            <h1>{state.data.valid ? c.verifyValid : c.verifyRevoked}</h1>

            <dl className="cert-verify-fields">
              <div>
                <dt>{c.verifyLearner}</dt>
                <dd>{state.data.learnerName}</dd>
              </div>
              <div>
                <dt>{c.verifyCourse}</dt>
                <dd>{state.data.courseTitle}</dd>
              </div>
              <div>
                <dt>{c.verifyNumber}</dt>
                <dd>{state.data.certificateNumber}</dd>
              </div>
              <div>
                <dt>{c.verifyIssued}</dt>
                <dd>{new Date(state.data.issuedAt).toLocaleDateString()}</dd>
              </div>
              <div>
                <dt>{c.verifyCompleted}</dt>
                <dd>{new Date(state.data.completedAt).toLocaleDateString()}</dd>
              </div>
              {!state.data.valid && state.data.revokedAt && (
                <div>
                  <dt>{c.verifyRevokedAt}</dt>
                  <dd>{new Date(state.data.revokedAt).toLocaleDateString()}</dd>
                </div>
              )}
            </dl>
          </div>
        )}

        <Link href="/" className="student-viewall">
          ← CODESCHOOL
        </Link>
      </div>
    </section>
  );
}
