import type { Metadata } from "next";
import { HowItWorksPage } from "@/components/public/HowItWorksPage";

export const metadata: Metadata = { title: "How it works — CODESCHOOL" };

export default function Page() {
  return <HowItWorksPage />;
}
