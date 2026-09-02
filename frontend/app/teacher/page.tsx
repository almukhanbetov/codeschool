import type { Metadata } from "next";
import { TeacherView } from "@/components/sections/TeacherView";

export const metadata: Metadata = {
  title: "Teacher Academy — CODESCHOOL",
};

export default function TeacherPage() {
  return <TeacherView />;
}
