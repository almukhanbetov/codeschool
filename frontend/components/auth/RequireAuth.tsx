"use client";

import { useEffect, type ReactNode } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/hooks/useAuth";
import { useLanguage } from "@/hooks/useLanguage";
import { ROLE_HOME, type UserRole } from "@/types";

/**
 * Client-side route guard. Redirects unauthenticated visitors to /login and
 * users whose role is not allowed to their own dashboard. This is a UX
 * boundary only — the backend authorization on every protected API call is
 * the real security boundary.
 */
export function RequireAuth({ roles, children }: { roles?: UserRole[]; children: ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const { t } = useLanguage();

  const allowed = !loading && user && (!roles || roles.includes(user.role));

  useEffect(() => {
    if (loading) return;
    if (!user) {
      router.replace("/login");
      return;
    }
    if (roles && !roles.includes(user.role)) {
      router.replace(ROLE_HOME[user.role]);
    }
  }, [loading, user, roles, router]);

  if (allowed) return <>{children}</>;

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
