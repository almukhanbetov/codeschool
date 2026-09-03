"use client";

import type { ReactNode } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useLanguage } from "@/hooks/useLanguage";

const SECTIONS = [
  { href: "/admin", key: "navOverview" as const },
  { href: "/admin/users", key: "navUsers" as const },
  { href: "/admin/catalog", key: "navCatalog" as const },
  { href: "/admin/groups", key: "navGroups" as const },
  { href: "/admin/links", key: "navLinks" as const },
  { href: "/admin/academy", key: "navAcademy" as const },
  { href: "/admin/audit", key: "navAudit" as const },
];

export function AdminShell({ children }: { children: ReactNode }) {
  const { t } = useLanguage();
  const pathname = usePathname();

  return (
    <section className="section">
      <div className="container">
        <span className="eyebrow">{t.admin.title}</span>
        <nav className="admin-nav" aria-label={t.admin.title}>
          {SECTIONS.map((s) => {
            const active = s.href === "/admin" ? pathname === "/admin" : pathname.startsWith(s.href);
            return (
              <Link key={s.href} href={s.href} className={`admin-nav-tab${active ? " active" : ""}`}>
                {t.admin[s.key]}
              </Link>
            );
          })}
        </nav>
        {children}
      </div>
    </section>
  );
}
