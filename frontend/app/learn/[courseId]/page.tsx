import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { CourseLearnView } from "@/components/learn/CourseLearnView";

export const metadata: Metadata = {
  title: "Learning — CODESCHOOL",
};

export default async function LearnCoursePage(props: PageProps<"/learn/[courseId]">) {
  const { courseId } = await props.params;
  return (
    <RequireAuth roles={["student"]}>
      <CourseLearnView courseId={Number(courseId)} />
    </RequireAuth>
  );
}
