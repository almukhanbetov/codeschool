import type { Metadata } from "next";
import { RequireAuth } from "@/components/auth/RequireAuth";
import { ParentChildDetail } from "@/components/parent/ParentChildDetail";

export const metadata: Metadata = {
  title: "Child — CODESCHOOL",
};

export default async function ParentChildPage(props: PageProps<"/parent/children/[id]">) {
  const { id } = await props.params;
  return (
    <RequireAuth roles={["parent"]}>
      <ParentChildDetail childId={Number(id)} />
    </RequireAuth>
  );
}
