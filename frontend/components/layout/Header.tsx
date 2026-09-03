"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { useHeaderScroll } from "@/hooks/useHeaderScroll";
import { Icon } from "@/lib/icons";
import { headerNavItems } from "@/data/nav";
import { ROLE_HOME } from "@/types";
import { LanguageSwitcher } from "@/components/ui/LanguageSwitcher";
import { ThemeToggle } from "@/components/ui/ThemeToggle";
import { Button } from "@/components/ui/Button";
import { MobileMenu } from "@/components/layout/MobileMenu";

function isActive(pathname: string, href: string): boolean {
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function Header() {
  const { t } = useLanguage();
  const { user, logout } = useAuth();
  const scrolled = useHeaderScroll();
  const pathname = usePathname();

  return (
    <header className={`site-header${scrolled ? " scrolled" : ""}`}>
      <div className="container header-inner">
        <Link href="/" className="logo" aria-label="CODESCHOOL — home">
          <span className="logo-mark" aria-hidden="true">
            <Icon name="code-xml" />
          </span>
          <span className="logo-text">CODESCHOOL</span>
        </Link>

        <nav className="main-nav" aria-label="Main navigation">
          {headerNavItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`nav-link${isActive(pathname, item.href) ? " active" : ""}`}
              aria-current={isActive(pathname, item.href) ? "page" : undefined}
            >
              {t.site.nav[item.key]}
            </Link>
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
          <Button href="/courses" variant="primary" size="sm" className="header-cta">
            {t.header.cta}
          </Button>
          <MobileMenu />
        </div>
      </div>
    </header>
  );
}
