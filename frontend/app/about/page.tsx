import type { Metadata } from "next";
import { AboutPage } from "@/components/public/AboutPage";

export const metadata: Metadata = { title: "About — CODESCHOOL" };

export default function Page() {
  return <AboutPage />;
}
