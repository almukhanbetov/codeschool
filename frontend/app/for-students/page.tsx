import type { Metadata } from "next";
import { ForStudentsPage } from "@/components/public/ForStudentsPage";

export const metadata: Metadata = { title: "For students — CODESCHOOL" };

export default function Page() {
  return <ForStudentsPage />;
}
