import { HeroSection } from "@/components/sections/HeroSection";
import { LearningPathSection } from "@/components/sections/LearningPathSection";
import { DirectionsSection } from "@/components/sections/DirectionsSection";
import { CoursesSection } from "@/components/sections/CoursesSection";
import { ChildrenSection } from "@/components/sections/ChildrenSection";
import { ProjectsSection } from "@/components/sections/ProjectsSection";
import { TeacherAcademySection } from "@/components/sections/TeacherAcademySection";
import { AITutorSection } from "@/components/sections/AITutorSection";
import { ParentsSection } from "@/components/sections/ParentsSection";
import { DashboardPreviewSection } from "@/components/sections/DashboardPreviewSection";
import { StatsSection } from "@/components/sections/StatsSection";
import { WhyUsSection } from "@/components/sections/WhyUsSection";
import { PhilosophySection } from "@/components/sections/PhilosophySection";
import { FinalCTASection } from "@/components/sections/FinalCTASection";
import { getCourses } from "@/lib/api";
import type { Course } from "@/types";

// Fetched server-side (this stays a Server Component) so CoursesSection
// itself only needs "use client" for the filter's interactive state, not
// for data loading. A backend outage degrades to an inline error message
// inside the section — never silently substituted demo data, and never a
// broken page (see CoursesSection's loadError prop).
async function loadCourses(): Promise<{ courses: Course[]; loadError: boolean }> {
  try {
    const courses = await getCourses();
    return { courses, loadError: false };
  } catch {
    return { courses: [], loadError: true };
  }
}

export default async function HomePage() {
  const { courses, loadError } = await loadCourses();

  return (
    <>
      <HeroSection />
      <LearningPathSection />
      <DirectionsSection />
      <CoursesSection courses={courses} loadError={loadError} />
      <ChildrenSection />
      <ProjectsSection />
      <TeacherAcademySection />
      <AITutorSection />
      <ParentsSection />
      <DashboardPreviewSection />
      <StatsSection />
      <WhyUsSection />
      <PhilosophySection />
      <FinalCTASection />
    </>
  );
}
