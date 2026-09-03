import type { Metadata } from "next";
import { AcademyLanding } from "@/components/academy/AcademyLanding";

export const metadata: Metadata = { title: "Teacher Academy — CODESCHOOL" };

export default function TeacherAcademyPage() {
  return <AcademyLanding />;
}
