"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { PageHero } from "@/components/public/PageHero";
import { BackLink } from "@/components/public/BackLink";
import { ChildrenSection } from "@/components/sections/ChildrenSection";
import { LearningPathSection } from "@/components/sections/LearningPathSection";
import { ProjectsSection } from "@/components/sections/ProjectsSection";
import { AITutorSection } from "@/components/sections/AITutorSection";
import { DashboardPreviewSection } from "@/components/sections/DashboardPreviewSection";

export function ForStudentsPage() {
  const { t } = useLanguage();
  const c = t.site.forStudents;

  return (
    <>
      <PageHero eyebrow={c.eyebrow} title={c.title} lead={c.lead} crumbs={[{ label: c.title }]} />
      <ChildrenSection />
      <LearningPathSection />
      <AITutorSection />
      <ProjectsSection />
      <DashboardPreviewSection />
      <BackLink href="/" />
    </>
  );
}
