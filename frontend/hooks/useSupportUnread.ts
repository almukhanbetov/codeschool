"use client";

import { useCallback, useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { adminSupportApi, supportApi } from "@/lib/api";
import { usePolling } from "@/hooks/usePolling";

/** Header badge: unread support messages for the current user (student /
 *  parent) or, for an admin, unread across the whole inbox. Polls every 20s
 *  while the tab is visible. */
export function useSupportUnread(): number {
  const { user } = useAuth();
  const [count, setCount] = useState(0);

  const supported =
    user?.role === "student" || user?.role === "parent" || user?.role === "admin";

  const refresh = useCallback(() => {
    if (!supported) return;
    const call = user?.role === "admin" ? adminSupportApi.unread() : supportApi.unread();
    call
      .then((u) => setCount(u.messages))
      .catch(() => {
        /* transient — keep the last known count */
      });
  }, [supported, user?.role]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  usePolling(refresh, 20000, supported);

  // let other components (the chat) nudge a refresh after they act
  useEffect(() => {
    const h = () => refresh();
    window.addEventListener("support:refresh-unread", h);
    return () => window.removeEventListener("support:refresh-unread", h);
  }, [refresh]);

  return supported ? count : 0;
}
