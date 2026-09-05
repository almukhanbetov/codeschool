import type { Metadata } from "next";
import { Suspense } from "react";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { SupportChat } from "@/components/support/SupportChat";

export const metadata: Metadata = { title: "Support — CODESCHOOL" };

export default function SupportPage() {
  return (
    <RequireAuth roles={["student", "parent"]}>
      <Suspense fallback={null}>
        <SupportChat />
      </Suspense>
    </RequireAuth>
  );
}
