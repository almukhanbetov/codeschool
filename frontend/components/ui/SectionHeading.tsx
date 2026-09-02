"use client";

import type { ReactNode } from "react";
import { useReveal } from "@/hooks/useReveal";

interface SectionHeadingProps {
  eyebrow: string;
  title: string;
  description?: ReactNode;
  align?: "center" | "left";
  lightOnDark?: boolean;
}

export function SectionHeading({
  eyebrow,
  title,
  description,
  align = "center",
  lightOnDark = false,
}: SectionHeadingProps) {
  const { ref, className } = useReveal<HTMLDivElement>();

  const classes = [
    "section-header",
    align === "left" ? "align-left" : "",
    lightOnDark ? "light-on-dark" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <div ref={ref} className={classes}>
      <span className="eyebrow">{eyebrow}</span>
      <h2>{title}</h2>
      {description ? <p>{description}</p> : null}
    </div>
  );
}
