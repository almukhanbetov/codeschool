"use client";

import { useEffect, useRef, useState } from "react";

interface AnimatedCounterProps {
  target: number;
  suffix?: string;
  duration?: number;
}

function shouldSkipAnimation() {
  if (typeof window === "undefined") return false;
  const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  return prefersReduced || !("IntersectionObserver" in window);
}

export function AnimatedCounter({ target, suffix = "", duration = 1400 }: AnimatedCounterProps) {
  const ref = useRef<HTMLSpanElement>(null);
  // If we can't (or shouldn't) animate, start already at the final value —
  // decided during render, so the effect below only ever calls setState
  // from inside the observer/rAF callbacks, never synchronously itself.
  const [value, setValue] = useState(() => (shouldSkipAnimation() ? target : 0));
  const hasAnimated = useRef(shouldSkipAnimation());

  useEffect(() => {
    const el = ref.current;
    if (!el || hasAnimated.current) return;

    let frameId: number;

    const animate = () => {
      const start = performance.now();
      const tick = (now: number) => {
        const progress = Math.min((now - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        setValue(Math.round(target * eased));
        if (progress < 1) {
          frameId = requestAnimationFrame(tick);
        }
      };
      frameId = requestAnimationFrame(tick);
    };

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !hasAnimated.current) {
            hasAnimated.current = true;
            animate();
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.5 }
    );

    observer.observe(el);

    return () => {
      observer.disconnect();
      if (frameId) cancelAnimationFrame(frameId);
    };
  }, [target, duration]);

  return (
    <span ref={ref} className="stat-number">
      {value}
      {suffix}
    </span>
  );
}
