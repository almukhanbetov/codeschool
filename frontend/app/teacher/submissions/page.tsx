import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { TeacherSubmissions } from "@/components/teacher/TeacherSubmissions";
import type { SubmissionStatus } from "@/types";

export const metadata: Metadata = {
  title: "Review submissions — CODESCHOOL",
};

const VALID: SubmissionStatus[] = ["draft", "submitted", "checking", "passed", "failed"];

export default async function TeacherSubmissionsPage(
  props: PageProps<"/teacher/submissions">
) {
  const sp = await props.searchParams;
  const raw = Array.isArray(sp.status) ? sp.status[0] : sp.status;
  const initialStatus = VALID.includes(raw as SubmissionStatus)
    ? (raw as SubmissionStatus)
    : undefined;

  return (
    <RequireAuth roles={["teacher"]}>
      <TeacherSubmissions initialStatus={initialStatus} />
    </RequireAuth>
  );
}
