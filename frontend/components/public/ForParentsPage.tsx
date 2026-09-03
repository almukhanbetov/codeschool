"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";
import { ParentsSection } from "@/components/sections/ParentsSection";
import { WhyUsSection } from "@/components/sections/WhyUsSection";
import { FinalCTASection } from "@/components/sections/FinalCTASection";

export function ForParentsPage() {
  const { t } = useLanguage();
  const c = t.site.forParents;

  return (
    <>
      <PageHero eyebrow={c.eyebrow} title={c.title} lead={c.lead} crumbs={[{ label: c.title }]} />
      <ParentsSection />
      <WhyUsSection />
      <FinalCTASection />
      <BackLink href="/" />
    </>
  );
}
