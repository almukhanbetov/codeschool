"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/hooks/useAuth";
import { useLanguage } from "@/hooks/useLanguage";
import { InfoPlaceholder } from "@/components/sections/InfoPlaceholder";
import { TeacherDashboard } from "@/components/teacher/TeacherDashboard";
import { ROLE_HOME } from "@/types";

/**
 * /teacher is the public "Teacher Academy" marketing page for anonymous
 * visitors, and the real teacher dashboard for a signed-in teacher.
 *
 * A signed-in user of a DIFFERENT role is redirected to their own dashboard
 * (same ROLE_HOME target RequireAuth uses elsewhere) instead of seeing the
 * marketing placeholder — it used to render for every signed-in non-teacher,
 * which was inconsistent with every other protected route and showed stale
 * "coming soon" copy to someone who already has a real dashboard elsewhere.
 * This is a client-side UX redirect only; server-side role checks on every
 * teacher API call are unchanged and remain the real security boundary.
 */
export function TeacherView() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const { t } = useLanguage();

  const redirecting = !loading && !!user && user.role !== "teacher";

  useEffect(() => {
    if (redirecting) {
      router.replace(ROLE_HOME[user!.role]);
    }
  }, [redirecting, user, router]);

  if (loading || redirecting) {
    return (
      <section className="section placeholder-section">
        <div className="container">
          <div className="placeholder-card">
            <p>{t.auth.checking}</p>
          </div>
        </div>
      </section>
    );
  }

  if (user?.role === "teacher") {
    return <TeacherDashboard />;
  }
  return <InfoPlaceholder variant="teacher" backHref="/for-teachers" />;
}
