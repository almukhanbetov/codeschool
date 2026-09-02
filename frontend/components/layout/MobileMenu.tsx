"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { Icon } from "@/lib/icons";
import { navItems } from "@/data/nav";
import { Button } from "@/components/ui/Button";
import { ROLE_HOME } from "@/types";

export function MobileMenu() {
  const { t } = useLanguage();
  const { user, logout } = useAuth();
  const [open, setOpen] = useState(false);

  const close = () => setOpen(false);

  useEffect(() => {
    if (!open) return;

    document.body.style.overflow = "hidden";
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") close();
    };
    document.addEventListener("keydown", onKeyDown);

    return () => {
      document.body.style.overflow = "";
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  return (
    <>
      <button
        type="button"
        className="mobile-menu-btn"
        aria-label={t.nav.home}
        aria-expanded={open}
        onClick={() => setOpen(true)}
      >
        <Icon name="menu" aria-hidden="true" />
      </button>

      <div className={`mobile-drawer${open ? " open" : ""}`}>
        <div className="mobile-drawer-header">
          <span className="logo-text">CODESCHOOL</span>
          <button
            type="button"
            className="mobile-drawer-close"
            aria-label="Close menu"
            onClick={close}
          >
            <Icon name="x" aria-hidden="true" />
          </button>
        </div>

        <nav className="mobile-nav" aria-label="Mobile navigation">
          {navItems.map((item) => (
            <a key={item.href} href={item.href} className="mobile-nav-link" onClick={close}>
              {t.nav[item.key]}
            </a>
          ))}
        </nav>

        <div className="mobile-drawer-actions">
          {user ? (
            <>
              <Link href={ROLE_HOME[user.role]} className="mobile-nav-link" onClick={close}>
                {user.firstName}
              </Link>
              <Button
                type="button"
                variant="ghost"
                onClick={() => {
                  close();
                  void logout();
                }}
              >
                {t.header.logout}
              </Button>
            </>
          ) : (
            <Button href="/login" variant="ghost" onClick={close}>
              {t.header.login}
            </Button>
          )}
          <Button href="#courses" variant="primary" onClick={close}>
            {t.header.cta}
          </Button>
        </div>
      </div>

      <div
        className={`mobile-drawer-backdrop${open ? " open" : ""}`}
        onClick={close}
        aria-hidden="true"
      />
    </>
  );
}
