"use client";

import Link from "next/link";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import type { UserRole } from "@/types";

export function RoleDashboard({ role }: { role: UserRole }) {
  const { t } = useLanguage();
  const { user } = useAuth();
  const a = t.auth;

  const roleLabel =
    role === "student"
      ? a.roleStudent
      : role === "teacher"
        ? a.roleTeacher
        : role === "parent"
          ? a.roleParent
          : "Admin";

  return (
    <section className="section placeholder-section">
      <div className="container">
        <div className="placeholder-card">
          <span className="eyebrow">
            {a.dashRole}: {roleLabel}
          </span>
          <h1>{user ? a.welcome.replace("{name}", user.firstName) : a.dashTitle}</h1>
          <p>{a.dashSubtitle}</p>

          <div className="placeholder-links">
            <Link href="/">{a.backHome}</Link>
          </div>
        </div>
      </div>
    </section>
  );
}
