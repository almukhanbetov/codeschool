"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { getMyCertificates } from "@/lib/api";
import type { Certificate } from "@/types";
import { CertificateCard } from "./CertificateCard";

type State =
  | { kind: "loading" }
  | { kind: "error" }
  | { kind: "ready"; certs: Certificate[] };

/** /student/certificates — the learner's own issued certificates. */
export function MyCertificates() {
  const { t } = useLanguage();
  const c = t.certificates;
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    getMyCertificates()
      .then((certs) => !cancelled && setState({ kind: "ready", certs }))
      .catch(() => !cancelled && setState({ kind: "error" }));
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="section">
      <div className="container">
        <div className="student-dash-head">
          <div>
            <span className="eyebrow">{c.navTitle}</span>
            <h1 className="student-dash-title">{c.myTitle}</h1>
            <p className="admin-muted">{c.mySubtitle}</p>
          </div>
          <Link href="/student" className="student-viewall">
            {t.learn.backToDashboard}
          </Link>
        </div>

        {state.kind === "loading" && <p className="filter-empty">{t.learn.loading}</p>}
        {state.kind === "error" && <p className="auth-error">{t.learn.loadError}</p>}

        {state.kind === "ready" && state.certs.length === 0 && (
          <div className="student-empty">
            <p className="filter-empty">{c.empty}</p>
          </div>
        )}

        {state.kind === "ready" && state.certs.length > 0 && (
          <div className="course-grid">
            {state.certs.map((cert) => (
              <CertificateCard key={cert.id} cert={cert} />
            ))}
          </div>
        )}
      </div>
    </section>
  );
}
