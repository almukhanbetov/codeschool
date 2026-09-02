"use client";

import { useEffect, useState } from "react";

/**
 * Tracks which section id is "current" while scrolling, so the matching
 * nav link can be highlighted. Ported from the prototype's script.js —
 * recomputes from getBoundingClientRect() on every observer tick instead of
 * trusting individual IntersectionObserver entries, which avoided a bug
 * where the wrong link could end up active on initial load.
 */
export function useScrollSpy(sectionIds: string[]): string | null {
  const [activeId, setActiveId] = useState<string | null>(sectionIds[0] ?? null);

  useEffect(() => {
    const sections = sectionIds
      .map((id) => document.getElementById(id))
      .filter((el): el is HTMLElement => el !== null);

    if (!sections.length || !("IntersectionObserver" in window)) return;

    const markerY = () => window.innerHeight * 0.48;

    const updateActive = () => {
      const y = markerY();
      let current = sections[0];
      for (const section of sections) {
        if (section.getBoundingClientRect().top <= y) current = section;
      }
      setActiveId(current.id);
    };

    const observer = new IntersectionObserver(updateActive, {
      rootMargin: "-45% 0px -50% 0px",
      threshold: 0,
    });
    sections.forEach((section) => observer.observe(section));
    updateActive();

    return () => observer.disconnect();
  }, [sectionIds]);

  return activeId;
}
