import type { NavItem } from "@/types";

// Real routes (no more hash-scroll-only navigation). `primary` items show in
// the desktop header; the mobile drawer always shows the full list.
export const navItems: NavItem[] = [
  { href: "/courses", key: "courses", primary: true },
  { href: "/programming", key: "programming", primary: true },
  { href: "/robotics", key: "robotics", primary: true },
  { href: "/ai", key: "ai", primary: true },
  { href: "/for-students", key: "forStudents", primary: true },
  { href: "/for-parents", key: "forParents", primary: true },
  { href: "/for-teachers", key: "forTeachers", primary: true },
  { href: "/teacher-academy", key: "academy", primary: true },
  { href: "/how-it-works", key: "howItWorks" },
  { href: "/about", key: "about" },
  { href: "/certificates", key: "certificates" },
];

export const headerNavItems = navItems.filter((i) => i.primary);
