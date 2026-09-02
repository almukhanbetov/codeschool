"use client";

import { useLanguage } from "@/hooks/useLanguage";
import type { SubmissionStatus } from "@/types";

const CLASS: Record<SubmissionStatus, string> = {
  draft: "sb-draft",
  submitted: "sb-submitted",
  checking: "sb-checking",
  passed: "sb-passed",
  failed: "sb-failed",
};

export function SubmissionBadge({ status }: { status: SubmissionStatus }) {
  const { t } = useLanguage();
  const label = {
    draft: t.learn.statusDraft,
    submitted: t.learn.statusSubmitted,
    checking: t.learn.statusChecking,
    passed: t.learn.statusPassed,
    failed: t.learn.statusFailed,
  }[status];

  return <span className={`submission-badge ${CLASS[status]}`}>{label}</span>;
}
