"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";

/** Consistent "← back" link for the foot of inner pages. */
export function BackLink({ href, label }: { href: string; label?: string }) {
  const { t } = useLanguage();
  return (
    <div className="page-back">
      <div className="container">
        <Link href={href} className="back-link">
          ← {label ?? t.site.back}
        </Link>
      </div>
    </div>
  );
}
