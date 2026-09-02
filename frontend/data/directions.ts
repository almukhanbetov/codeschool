import type { DirectionItem } from "@/types";

export const directions: DirectionItem[] = [
  {
    id: "dc-1",
    icon: "terminal-square",
    accentClass: "dc-1",
    cardKey: "card1",
    tags: [{ literal: "Python" }, { literal: "JavaScript" }, { literal: "Go" }, { key: "tag4" }],
  },
  {
    id: "dc-2",
    icon: "globe-2",
    accentClass: "dc-2",
    cardKey: "card2",
    tags: [{ literal: "HTML" }, { literal: "CSS" }, { literal: "JavaScript" }, { key: "tag4" }],
  },
  {
    id: "dc-3",
    icon: "bot",
    accentClass: "dc-3",
    cardKey: "card3",
    tags: [{ literal: "Arduino" }, { key: "tag2" }, { key: "tag3" }, { key: "tag4" }],
  },
  {
    id: "dc-4",
    icon: "brain-circuit",
    accentClass: "dc-4",
    cardKey: "card4",
    tags: [{ literal: "AI" }, { literal: "Machine Learning" }, { key: "tag3" }, { key: "tag4" }],
  },
  {
    id: "dc-5",
    icon: "smartphone",
    accentClass: "dc-5",
    cardKey: "card5",
    tags: [{ literal: "Flutter" }, { key: "tag2" }, { literal: "UI" }, { literal: "API" }],
  },
  {
    id: "dc-6",
    icon: "gamepad-2",
    accentClass: "dc-6",
    cardKey: "card6",
    tags: [{ literal: "Scratch" }, { key: "tag2" }, { key: "tag3" }, { key: "tag4" }],
  },
];
