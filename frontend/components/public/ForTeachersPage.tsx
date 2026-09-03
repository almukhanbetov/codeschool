"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { Button } from "@/components/ui/Button";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";
import { TeacherAcademySection } from "@/components/sections/TeacherAcademySection";
import { WhyUsSection } from "@/components/sections/WhyUsSection";

export function ForTeachersPage() {
  const { t } = useLanguage();
  const c = t.site.forTeachers;
  const a = t.academy;

  return (
    <>
      <PageHero eyebrow={c.eyebrow} title={c.title} lead={c.lead} crumbs={[{ label: c.title }]}>
        <div className="page-hero-actions">
          <Button href="/teacher-academy" variant="primary">
            {a.navTitle}
          </Button>
          <Link href="/login" className="back-link">
            {t.header.login} →
          </Link>
        </div>
      </PageHero>
      <TeacherAcademySection />
      <WhyUsSection />
      <BackLink href="/" />
    </>
  );
}
