"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";

export function NotFoundView() {
  const { t } = useLanguage();

  return (
    <section className="section placeholder-section">
      <div className="container">
        <div className="placeholder-card">
          <span className="eyebrow">404</span>
          <h1>{t.site.notFoundTitle}</h1>
          <p>{t.site.notFoundLead}</p>
          <div className="placeholder-links">
            <Button href="/" variant="primary">
              {t.site.home}
            </Button>
            <Link href="/courses">{t.site.nav.courses} →</Link>
          </div>
        </div>
      </div>
    </section>
  );
}
