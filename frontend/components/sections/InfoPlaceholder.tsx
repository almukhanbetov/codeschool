"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";

export function InfoPlaceholder({
  variant,
  backHref,
}: {
  variant: "teacher";
  backHref: string;
}) {
  const { t } = useLanguage();
  const copy = t.placeholder[variant];

  return (
    <section className="section placeholder-section">
      <div className="container">
        <div className="placeholder-card">
          <span className="eyebrow">{copy.eyebrow}</span>
          <h1>{copy.title}</h1>
          <p>{copy.subtitle}</p>

          <div className="placeholder-links">
            <Button href={backHref} variant="primary">
              {copy.backCta}
            </Button>
            <Link href="/">← {t.site.home}</Link>
          </div>
        </div>
      </div>
    </section>
  );
}
