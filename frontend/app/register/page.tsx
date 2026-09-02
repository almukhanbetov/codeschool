import type { Metadata } from "next";
import { AuthPlaceholder } from "@/components/sections/AuthPlaceholder";

export const metadata: Metadata = {
  title: "Sign up — CODESCHOOL",
};

export default function RegisterPage() {
  return <AuthPlaceholder variant="register" />;
}
