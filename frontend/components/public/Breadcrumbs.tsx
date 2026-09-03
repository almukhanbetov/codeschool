"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";

export interface Crumb {
  label: string;
  href?: string;
}

/** Breadcrumb trail for inner public pages. "Home" is prepended automatically. */
export function Breadcrumbs({ items }: { items: Crumb[] }) {
  const { t } = useLanguage();
  const trail: Crumb[] = [{ label: t.site.home, href: "/" }, ...items];

  return (
    <nav className="breadcrumbs" aria-label="Breadcrumb">
      <ol>
        {trail.map((crumb, i) => {
          const isLast = i === trail.length - 1;
          return (
            <li key={i}>
              {crumb.href && !isLast ? (
                <Link href={crumb.href}>{crumb.label}</Link>
              ) : (
                <span aria-current={isLast ? "page" : undefined}>{crumb.label}</span>
              )}
              {!isLast && (
                <span className="breadcrumbs-sep" aria-hidden="true">
                  /
                </span>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
