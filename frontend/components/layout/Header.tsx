"use client";

import { useMemo } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { useHeaderScroll } from "@/hooks/useHeaderScroll";
import { useScrollSpy } from "@/hooks/useScrollSpy";
import { Icon } from "@/lib/icons";
import { navItems } from "@/data/nav";
import { ROLE_HOME } from "@/types";
import { LanguageSwitcher } from "@/components/ui/LanguageSwitcher";
import { ThemeToggle } from "@/components/ui/ThemeToggle";
import { Button } from "@/components/ui/Button";
import { MobileMenu } from "@/components/layout/MobileMenu";

export function Header() {
  const { t } = useLanguage();
  const { user, logout } = useAuth();
  const scrolled = useHeaderScroll();
  const sectionIds = useMemo(() => navItems.map((item) => item.href.slice(1)), []);
  const activeId = useScrollSpy(sectionIds);

  return (
    <header className={`site-header${scrolled ? " scrolled" : ""}`}>
      <div className="container header-inner">
        <a href="#hero" className="logo" aria-label="CODESCHOOL — home">
          <span className="logo-mark" aria-hidden="true">
            <Icon name="code-xml" />
          </span>
          <span className="logo-text">CODESCHOOL</span>
        </a>

        <nav className="main-nav" aria-label="Main navigation">
          {navItems.map((item) => (
            <a
              key={item.href}
              href={item.href}
              className={`nav-link${activeId === item.href.slice(1) ? " active" : ""}`}
            >
              {t.nav[item.key]}
            </a>
          ))}
        </nav>

        <div className="header-actions">
          <LanguageSwitcher ariaLabel="Language selector" />
          <ThemeToggle ariaLabel="Toggle theme" />
          {user ? (
            <>
              <Link href={ROLE_HOME[user.role]} className="header-user-name">
                {user.firstName}
              </Link>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                className="header-login"
                onClick={() => {
                  void logout();
                }}
              >
                {t.header.logout}
              </Button>
            </>
          ) : (
            <Button href="/login" variant="ghost" size="sm" className="header-login">
              {t.header.login}
            </Button>
          )}
          <Button href="#courses" variant="primary" size="sm" className="header-cta">
            {t.header.cta}
          </Button>
          <MobileMenu />
        </div>
      </div>
    </header>
  );
}
