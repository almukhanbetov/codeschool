"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Icon } from "@/lib/icons";
import { LanguageSwitcher } from "@/components/ui/LanguageSwitcher";

export function Footer() {
  const { t } = useLanguage();
  const year = new Date().getFullYear();

  return (
    <footer className="site-footer">
      <div className="container footer-inner">
        <div className="footer-col footer-brand">
          <Link href="/" className="logo" aria-label="CODESCHOOL — home">
            <span className="logo-mark" aria-hidden="true">
              <Icon name="code-xml" />
            </span>
            <span className="logo-text">CODESCHOOL</span>
          </Link>
          <p>{t.footer.tagline}</p>
          {/* Social accounts are not live yet — rendered as inert buttons so
              they never put a fragment in the URL or trigger a scroll.
              Swap each for <a href="https://…" target="_blank" rel="noreferrer">
              once the real profiles exist. */}
          <div className="footer-socials">
            <button type="button" aria-label="Instagram" aria-disabled="true">
              <Icon name="instagram" />
            </button>
            <button type="button" aria-label="YouTube" aria-disabled="true">
              <Icon name="youtube" />
            </button>
            <button type="button" aria-label="Telegram" aria-disabled="true">
              <Icon name="send" />
            </button>
            <button type="button" aria-label="LinkedIn" aria-disabled="true">
              <Icon name="linkedin" />
            </button>
          </div>
        </div>

        <div className="footer-col">
          <h4>{t.footer.platform}</h4>
          <Link href="/courses">{t.site.nav.courses}</Link>
          <Link href="/programming">{t.footer.programming}</Link>
          <Link href="/robotics">{t.footer.robotics}</Link>
          <Link href="/ai">{t.footer.ai}</Link>
          <Link href="/certificates">{t.site.nav.certificates}</Link>
        </div>

        <div className="footer-col">
          <h4>{t.footer.people}</h4>
          <Link href="/for-students">{t.site.nav.forStudents}</Link>
          <Link href="/for-parents">{t.site.nav.forParents}</Link>
          <Link href="/for-teachers">{t.site.nav.forTeachers}</Link>
          <Link href="/teacher-academy">{t.footer.teacherAcademy}</Link>
        </div>

        <div className="footer-col">
          <h4>{t.footer.about}</h4>
          <Link href="/how-it-works">{t.site.nav.howItWorks}</Link>
          <Link href="/about">{t.footer.about}</Link>
          <div className="footer-lang">
            <LanguageSwitcher variant="footer" ariaLabel={t.footer.language} />
          </div>
        </div>
      </div>

      <div className="container footer-bottom">
        <p>
          &copy; {year} CODESCHOOL. {t.footer.rights}
        </p>
        <p className="footer-note">{t.footer.note}</p>
      </div>
    </footer>
  );
}
