"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { Icon } from "@/lib/icons";
import type { SupportContextInput } from "@/types";

/**
 * Contextual "ask a curator" link. Opens the one support system with the
 * course / lesson / assignment already attached — the student never has to
 * explain which page they're on. Renders nothing for non-student/parent.
 */
export function AskCuratorButton({
  context,
  label,
  className = "",
}: {
  context?: SupportContextInput;
  label?: string;
  className?: string;
}) {
  const { t } = useLanguage();
  const { user } = useAuth();
  if (user?.role !== "student" && user?.role !== "parent") return null;

  const qs = new URLSearchParams({ new: "1" });
  if (context?.courseId) qs.set("course", String(context.courseId));
  if (context?.lessonId) qs.set("lesson", String(context.lessonId));
  if (context?.assignmentId) qs.set("assignment", String(context.assignmentId));
  if (context?.category) qs.set("category", context.category);

  return (
    <Link href={`/support?${qs.toString()}`} className={`ask-curator-btn ${className}`}>
      <Icon name="message-square-code" aria-hidden="true" />
      {label ?? t.support.askCurator}
    </Link>
  );
}
