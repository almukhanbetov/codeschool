"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";
import { LearningPathSection } from "@/components/sections/LearningPathSection";
import { DirectionsSection } from "@/components/sections/DirectionsSection";
import { DashboardPreviewSection } from "@/components/sections/DashboardPreviewSection";
import { WhyUsSection } from "@/components/sections/WhyUsSection";
import { FinalCTASection } from "@/components/sections/FinalCTASection";

export function HowItWorksPage() {
  const { t } = useLanguage();
  const c = t.site.howItWorks;

  return (
    <>
      <PageHero eyebrow={c.eyebrow} title={c.title} lead={c.lead} crumbs={[{ label: c.title }]} />
      <LearningPathSection />
      <DirectionsSection />
      <DashboardPreviewSection />
      <WhyUsSection />
      <FinalCTASection />
      <BackLink href="/" />
    </>
  );
}
