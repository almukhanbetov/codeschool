"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { Breadcrumbs } from "@/components/public/Breadcrumbs";
import { BackLink } from "@/components/public/BackLink";
import { CoursesSection } from "@/components/sections/CoursesSection";
import type { Course } from "@/types";

export function CoursesCatalogPage({
  courses,
  loadError,
}: {
  courses: Course[];
  loadError: boolean;
}) {
  const { t } = useLanguage();

  return (
    <>
      <div className="container breadcrumbs-bar">
        <Breadcrumbs items={[{ label: t.site.nav.courses }]} />
      </div>
      <CoursesSection courses={courses} loadError={loadError} />
      <BackLink href="/" />
    </>
  );
}
