import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { ParentChildCourse } from "@/components/parent/ParentChildCourse";

export const metadata: Metadata = {
  title: "Child course — CODESCHOOL",
};

export default async function ParentChildCoursePage(
  props: PageProps<"/parent/children/[id]/courses/[courseId]">
) {
  const { id, courseId } = await props.params;
  return (
    <RequireAuth roles={["parent"]}>
      <ParentChildCourse childId={Number(id)} courseId={Number(courseId)} />
    </RequireAuth>
  );
}
