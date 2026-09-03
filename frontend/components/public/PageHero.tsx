"use client";

import type { ReactNode } from "react";
import { Breadcrumbs, type Crumb } from "./Breadcrumbs";

interface PageHeroProps {
  eyebrow: string;
  title: string;
  lead?: ReactNode;
  crumbs?: Crumb[];
  children?: ReactNode;
}

/** Standard inner-page header: breadcrumbs + eyebrow + H1 + lead. Reuses the
 *  landing design tokens (.eyebrow, section spacing) — no new visual identity. */
export function PageHero({ eyebrow, title, lead, crumbs, children }: PageHeroProps) {
  return (
    <section className="section page-hero">
      <div className="container">
        {crumbs && <Breadcrumbs items={crumbs} />}
        <span className="eyebrow">{eyebrow}</span>
        <h1 className="page-hero-title">{title}</h1>
        {lead && <p className="page-hero-lead">{lead}</p>}
        {children}
      </div>
    </section>
  );
}
