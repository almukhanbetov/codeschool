import type { ProjectItem } from "@/types";

export const projects: ProjectItem[] = [
  { id: "smart-greenhouse", key: "p1", icon: "sprout", thumbClass: "pt-1", tech: "Arduino" },
  { id: "space-game", key: "p2", icon: "rocket", thumbClass: "pt-2", tech: "Scratch" },
  {
    id: "my-first-website",
    key: "p3",
    icon: "layout-template",
    thumbClass: "pt-3",
    tech: "HTML / CSS",
  },
  {
    id: "ai-chatbot",
    key: "p4",
    icon: "message-square-code",
    thumbClass: "pt-4",
    tech: "Python",
  },
];
