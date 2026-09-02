"use client";

import { useEffect, useRef, useState } from "react";

/**
 * React-safe port of the prototype's IntersectionObserver fade-up effect.
 * The vanilla version toggled a class directly on the DOM node; doing that
 * in React would get clobbered on the next re-render (e.g. a language
 * switch), so visibility is tracked in state instead and the class name is
 * derived declaratively.
 */
function noObserverSupport() {
  return typeof window !== "undefined" && !("IntersectionObserver" in window);
}

export function useReveal<T extends HTMLElement>() {
  const ref = useRef<T>(null);
  // Environments without IntersectionObserver start already-visible; this is
  // decided during render (lazy initializer), not in the effect, so the
  // effect only ever calls setState from inside the observer callback.
  const [isVisible, setIsVisible] = useState(noObserverSupport);

  useEffect(() => {
    if (isVisible) return;
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(true);
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15, rootMargin: "0px 0px -60px 0px" }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [isVisible]);

  const className = `reveal${isVisible ? " is-visible" : ""}`;

  return { ref, className };
}
