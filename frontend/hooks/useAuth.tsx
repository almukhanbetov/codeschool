"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import {
  getMe,
  login as apiLogin,
  logout as apiLogout,
  refresh as apiRefresh,
  register as apiRegister,
  setAccessToken,
  setTokenRefresher,
} from "@/lib/api";
import type { AuthUser, LoginInput, RegisterInput } from "@/types";

interface Session {
  token: string;
  /** epoch ms when the access token expires */
  expiresAt: number;
}

interface AuthContextValue {
  user: AuthUser | null;
  accessToken: string | null;
  /** true until the initial "restore session from cookie" attempt finishes. */
  loading: boolean;
  login: (input: LoginInput) => Promise<AuthUser>;
  register: (input: RegisterInput) => Promise<AuthUser>;
  logout: () => Promise<void>;
  refreshSession: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  const applySession = useCallback((token: string | null, expiresIn?: number) => {
    setAccessToken(token);
    if (token) {
      setSession({ token, expiresAt: Date.now() + (expiresIn ?? 900) * 1000 });
    } else {
      setSession(null);
    }
  }, []);

  const refreshSession = useCallback(async () => {
    const r = await apiRefresh();
    applySession(r.accessToken, r.expiresIn);
  }, [applySession]);

  const clearSession = useCallback(() => {
    applySession(null);
    setUser(null);
  }, [applySession]);

  // Let the API client transparently refresh + retry a protected call that
  // 401s (spec §54) — one shared auth flow, no second mechanism.
  useEffect(() => {
    setTokenRefresher(async () => {
      try {
        const r = await apiRefresh();
        applySession(r.accessToken, r.expiresIn);
        return r.accessToken;
      } catch {
        clearSession();
        return null;
      }
    });
    return () => setTokenRefresher(null);
  }, [applySession, clearSession]);

  // Session restore on first load: the access token is memory-only and gone
  // after a reload, but the HttpOnly refresh cookie may still be valid.
  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const r = await apiRefresh();
        if (cancelled) return;
        applySession(r.accessToken, r.expiresIn);
        const me = await getMe();
        if (!cancelled) setUser(me);
      } catch {
        if (!cancelled) clearSession();
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [applySession, clearSession]);

  // Proactively refresh ~45s before the access token expires so an open tab
  // keeps a working session (and rotates the refresh token).
  useEffect(() => {
    if (!session) return;
    const lead = session.expiresAt - Date.now() - 45_000;
    const delay = Math.max(lead, 5_000);
    const timer = setTimeout(() => {
      refreshSession().catch(() => clearSession());
    }, delay);
    return () => clearTimeout(timer);
  }, [session, refreshSession, clearSession]);

  const login = useCallback(
    async (input: LoginInput) => {
      const res = await apiLogin(input);
      applySession(res.accessToken, res.expiresIn);
      setUser(res.user);
      return res.user;
    },
    [applySession]
  );

  const register = useCallback((input: RegisterInput) => apiRegister(input), []);

  const logout = useCallback(async () => {
    try {
      await apiLogout();
    } catch {
      // Drop local state even if the network call fails.
    }
    clearSession();
  }, [clearSession]);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      accessToken: session?.token ?? null,
      loading,
      login,
      register,
      logout,
      refreshSession,
    }),
    [user, session, loading, login, register, logout, refreshSession]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return ctx;
}
