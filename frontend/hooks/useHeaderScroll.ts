"use client";

import { useEffect, useState } from "react";

/** True once the page has scrolled past a small threshold — drives the
 * header's stronger shadow, matching the prototype's `.scrolled` class. */
export function useHeaderScroll(threshold = 12): boolean {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const update = () => setScrolled(window.scrollY > threshold);
    update();
    window.addEventListener("scroll", update, { passive: true });
    return () => window.removeEventListener("scroll", update);
  }, [threshold]);

  return scrolled;
}
