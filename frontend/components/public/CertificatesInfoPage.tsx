"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useLanguage } from "@/hooks/useLanguage";
import { Icon, type IconName } from "@/lib/icons";
import { Button } from "@/components/ui/Button";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";

export function CertificatesInfoPage() {
  const { t } = useLanguage();
  const s = t.site.certificates;
  const c = t.certificates;
  const router = useRouter();
  const [code, setCode] = useState("");

  function submit(e: FormEvent) {
    e.preventDefault();
    const clean = code.trim();
    if (clean) router.push(`/certificates/verify/${encodeURIComponent(clean)}`);
  }

  const points: { icon: IconName; label: string }[] = [
    { icon: "graduation-cap", label: c.mySubtitle },
    { icon: "shield-check", label: s.lead },
    { icon: "qr-code", label: c.verifySubtitle },
  ];

  return (
    <>
      <PageHero
        eyebrow={s.eyebrow}
        title={s.title}
        lead={s.lead}
        crumbs={[{ label: s.eyebrow }]}
      >
        <form className="cert-verify-form" onSubmit={submit}>
          <input
            aria-label={s.verifyTitle}
            placeholder={s.verifyPlaceholder}
            value={code}
            onChange={(e) => setCode(e.target.value)}
          />
          <Button type="submit" variant="primary">
            {s.verifyButton}
          </Button>
        </form>
      </PageHero>

      <section className="section">
        <div className="container">
          <ul className="academy-benefit-list">
            {points.map((p, i) => (
              <li key={i}>
                <span className="academy-benefit-icon" aria-hidden="true">
                  <Icon name={p.icon} />
                </span>
                {p.label}
              </li>
            ))}
          </ul>
        </div>
      </section>

      <BackLink href="/" />
    </>
  );
}
