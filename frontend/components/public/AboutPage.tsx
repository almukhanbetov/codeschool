"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";
import { PhilosophySection } from "@/components/sections/PhilosophySection";
import { StatsSection } from "@/components/sections/StatsSection";
import { WhyUsSection } from "@/components/sections/WhyUsSection";
import { TeacherAcademySection } from "@/components/sections/TeacherAcademySection";
import { FinalCTASection } from "@/components/sections/FinalCTASection";

export function AboutPage() {
  const { t } = useLanguage();
  const c = t.site.about;

  return (
    <>
      <PageHero eyebrow={c.eyebrow} title={c.title} lead={c.lead} crumbs={[{ label: c.title }]} />
      <PhilosophySection />
      <StatsSection />
      <WhyUsSection />
      <TeacherAcademySection />
      <FinalCTASection />
      <BackLink href="/" />
    </>
  );
}
