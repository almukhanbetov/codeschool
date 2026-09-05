"use client";

import { useEffect, useRef } from "react";

/**
 * Calls `fn` every `intervalMs` while the tab is visible. Pauses when the
 * document is hidden and fires once immediately on re-show. Real-time via
 * WebSocket/SSE is future work — see the support-chat notes.
 */
export function usePolling(fn: () => void, intervalMs: number, enabled = true) {
  const saved = useRef(fn);

  useEffect(() => {
    saved.current = fn;
  });

  useEffect(() => {
    if (!enabled) return;
    let timer: ReturnType<typeof setInterval> | null = null;

    const start = () => {
      if (timer) return;
      timer = setInterval(() => {
        if (!document.hidden) saved.current();
      }, intervalMs);
    };
    const stop = () => {
      if (timer) {
        clearInterval(timer);
        timer = null;
      }
    };
    const onVisibility = () => {
      if (document.hidden) {
        stop();
      } else {
        saved.current();
        start();
      }
    };

    start();
    document.addEventListener("visibilitychange", onVisibility);
    return () => {
      stop();
      document.removeEventListener("visibilitychange", onVisibility);
    };
  }, [intervalMs, enabled]);
}
