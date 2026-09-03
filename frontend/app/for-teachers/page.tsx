import type { Metadata } from "next";
import { ForTeachersPage } from "@/components/public/ForTeachersPage";

export const metadata: Metadata = { title: "For teachers — CODESCHOOL" };

export default function Page() {
  return <ForTeachersPage />;
}
