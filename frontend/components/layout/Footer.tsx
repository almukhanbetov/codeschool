"use client";

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
          <a href="#hero" className="logo" aria-label="CODESCHOOL — home">
            <span className="logo-mark" aria-hidden="true">
              <Icon name="code-xml" />
            </span>
            <span className="logo-text">CODESCHOOL</span>
          </a>
          <p>{t.footer.tagline}</p>
          <div className="footer-socials">
            <a href="#" aria-label="Instagram">
              <Icon name="instagram" />
            </a>
            <a href="#" aria-label="YouTube">
              <Icon name="youtube" />
            </a>
            <a href="#" aria-label="Telegram">
              <Icon name="send" />
            </a>
            <a href="#" aria-label="LinkedIn">
              <Icon name="linkedin" />
            </a>
          </div>
        </div>

        <div className="footer-col">
          <h4>{t.footer.platform}</h4>
          <a href="#courses">{t.nav.courses}</a>
          <a href="#directions">{t.footer.programming}</a>
          <a href="#directions">{t.footer.robotics}</a>
          <a href="#directions">{t.footer.ai}</a>
        </div>

        <div className="footer-col">
          <h4>{t.footer.people}</h4>
          <a href="/teacher-academy">{t.footer.teacherAcademy}</a>
          <a href="#parents">{t.nav.parents}</a>
          <a href="#about">{t.footer.about}</a>
          <a href="#">{t.footer.contacts}</a>
        </div>

        <div className="footer-col">
          <h4>{t.footer.language}</h4>
          <LanguageSwitcher variant="footer" ariaLabel={t.footer.language} />
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
