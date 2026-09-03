"use client";

import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { Icon, type IconName } from "@/lib/icons";

export function AcademyLanding() {
  const { t } = useLanguage();
  const a = t.academy;
  const { user } = useAuth();

  const ctaHref =
    user?.role === "teacher" ? "/teacher-academy/dashboard" : user ? "/teacher-academy" : "/login";

  const benefits: { icon: IconName; label: string }[] = [
    { icon: "book-open", label: a.benefitMethodology },
    { icon: "folder-kanban", label: a.benefitPractice },
    { icon: "terminal-square", label: a.benefitAutoTests },
    { icon: "code-xml", label: a.benefitCode },
    { icon: "trending-up", label: a.benefitProgress },
    { icon: "graduation-cap", label: a.benefitCertificate },
  ];

  return (
    <>
      <section className="section academy-hero">
        <div className="container">
          <span className="eyebrow">{a.navTitle}</span>
          <h1 className="academy-hero-title">{a.heroTitle}</h1>
          <p className="academy-hero-lead">{a.heroLead}</p>
          <div className="academy-hero-actions">
            <Button href={ctaHref} variant="primary">
              {a.heroCta}
            </Button>
            {user?.role === "teacher" && (
              <Button href="/teacher-academy/courses" variant="ghost">
                {a.browseCourses}
              </Button>
            )}
          </div>
          {!user && <p className="academy-note">{a.loginAsTeacher}</p>}
        </div>
      </section>

      <section className="section">
        <div className="container">
          <h2 className="student-dash-title">{a.tracksTitle}</h2>
          <div className="academy-tracks">
            {a.tracks.map((track, i) => (
              <div className="academy-track-card" key={i}>
                <span className="academy-track-num">{i + 1}</span>
                <h3>{track.title}</h3>
                <p>{track.text}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section academy-benefits">
        <div className="container">
          <h2 className="student-dash-title">{a.benefitsTitle}</h2>
          <ul className="academy-benefit-list">
            {benefits.map((b, i) => (
              <li key={i}>
                <span className="academy-benefit-icon" aria-hidden="true">
                  <Icon name={b.icon} />
                </span>
                {b.label}
              </li>
            ))}
          </ul>
          <div className="academy-hero-actions">
            <Button href={ctaHref} variant="primary">
              {a.heroCta}
            </Button>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container">
          <Link href="/" className="student-viewall">
            ← CODESCHOOL
          </Link>
        </div>
      </section>
    </>
  );
}
