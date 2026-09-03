import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { CourseLearnView } from "@/components/learn/CourseLearnView";

export const metadata: Metadata = { title: "Academy course — Teacher Academy" };

export default async function Page(props: PageProps<"/teacher-academy/learn/[courseId]">) {
  const { courseId } = await props.params;
  return (
    <RequireAuth roles={["teacher"]}>
      <CourseLearnView
        courseId={Number(courseId)}
        apiPrefix="/teacher-academy"
        basePath="/teacher-academy/learn"
        backHref="/teacher-academy/dashboard"
      />
    </RequireAuth>
  );
}
