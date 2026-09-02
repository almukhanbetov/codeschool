import type { Metadata } from "next";
import { AuthPlaceholder } from "@/components/sections/AuthPlaceholder";

export const metadata: Metadata = {
  title: "Log in — CODESCHOOL",
};

export default function LoginPage() {
  return <AuthPlaceholder variant="login" />;
}
