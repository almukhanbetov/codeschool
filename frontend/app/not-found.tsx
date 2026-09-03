import type { Metadata } from "next";
import { NotFoundView } from "@/components/public/NotFoundView";

export const metadata: Metadata = { title: "Not found — CODESCHOOL" };

export default function NotFound() {
  return <NotFoundView />;
}
