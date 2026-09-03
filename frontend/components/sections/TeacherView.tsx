"use client";

import { useAuth } from "@/hooks/useAuth";
import { InfoPlaceholder } from "@/components/sections/InfoPlaceholder";
import { TeacherDashboard } from "@/components/teacher/TeacherDashboard";

/**
 * /teacher is the public "Teacher Academy" marketing page for visitors, and
 * the real teacher dashboard for a signed-in teacher.
 */
export function TeacherView() {
  const { user, loading } = useAuth();

  if (!loading && user?.role === "teacher") {
    return <TeacherDashboard />;
  }
  return <InfoPlaceholder variant="teacher" backHref="/for-teachers" />;
}
