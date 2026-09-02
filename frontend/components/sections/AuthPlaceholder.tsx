"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useLanguage } from "@/hooks/useLanguage";
import { useAuth } from "@/hooks/useAuth";
import { ApiError } from "@/lib/api";
import { Button } from "@/components/ui/Button";
import { PUBLIC_ROLES, ROLE_HOME, type PublicRole } from "@/types";

export function AuthPlaceholder({ variant }: { variant: "login" | "register" }) {
  const { t } = useLanguage();
  const router = useRouter();
  const { login, register } = useAuth();
  const a = t.auth;

  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // login
  const [identifier, setIdentifier] = useState("");
  const [loginPassword, setLoginPassword] = useState("");

  // register
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState<PublicRole>("student");

  const switchHref = variant === "login" ? "/register" : "/login";

  function messageForError(err: unknown): string {
    if (err instanceof ApiError) {
      if (err.status === 401) return a.errInvalidCredentials;
      if (err.status === 409) {
        return err.message.toLowerCase().includes("phone") ? a.errPhoneTaken : a.errEmailTaken;
      }
      if (err.status === 400 && err.message) return err.message;
    }
    return a.errGeneric;
  }

  async function handleLogin(e: FormEvent) {
    e.preventDefault();
    setError(null);

    const id = identifier.trim();
    const payload = id.includes("@") ? { email: id } : { phone: id };

    setPending(true);
    try {
      const user = await login({ ...payload, password: loginPassword });
      router.push(ROLE_HOME[user.role]);
    } catch (err) {
      setError(messageForError(err));
      setPending(false);
    }
  }

  async function handleRegister(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!firstName.trim()) return setError(a.errFirstNameRequired);
    if (!email.trim() && !phone.trim()) return setError(a.errNeedEmailOrPhone);
    if (password.length < 8) return setError(a.errPasswordShort);

    setPending(true);
    try {
      await register({
        firstName: firstName.trim(),
        lastName: lastName.trim() || undefined,
        email: email.trim() || undefined,
        phone: phone.trim() || undefined,
        password,
        role,
      });
      // Per spec: register then log in separately.
      router.push("/login");
    } catch (err) {
      setError(messageForError(err));
      setPending(false);
    }
  }

  const title = variant === "login" ? a.loginTitle : a.registerTitle;
  const subtitle = variant === "login" ? a.loginSubtitle : a.registerSubtitle;
  const eyebrow = variant === "login" ? a.loginSubmit : a.registerSubmit;

  return (
    <section className="section placeholder-section">
      <div className="container">
        <div className="placeholder-card">
          <span className="eyebrow">{eyebrow}</span>
          <h1>{title}</h1>
          <p>{subtitle}</p>

          {variant === "login" ? (
            <form className="placeholder-form" onSubmit={handleLogin} noValidate>
              <div>
                <label htmlFor="identifier">{a.emailOrPhone}</label>
                <input
                  id="identifier"
                  name="identifier"
                  type="text"
                  autoComplete="username"
                  value={identifier}
                  onChange={(e) => setIdentifier(e.target.value)}
                  required
                />
              </div>
              <div>
                <label htmlFor="password">{a.password}</label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  value={loginPassword}
                  onChange={(e) => setLoginPassword(e.target.value)}
                  required
                />
              </div>

              {error && (
                <p className="auth-error" role="alert">
                  {error}
                </p>
              )}

              <Button type="submit" variant="primary" disabled={pending}>
                {pending ? a.submitting : a.loginSubmit}
              </Button>
            </form>
          ) : (
            <form className="placeholder-form" onSubmit={handleRegister} noValidate>
              <div>
                <label htmlFor="firstName">{a.firstName}</label>
                <input
                  id="firstName"
                  name="firstName"
                  type="text"
                  autoComplete="given-name"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  required
                />
              </div>
              <div>
                <label htmlFor="lastName">
                  {a.lastName} <span className="auth-hint">{a.lastNameHint}</span>
                </label>
                <input
                  id="lastName"
                  name="lastName"
                  type="text"
                  autoComplete="family-name"
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                />
              </div>
              <div>
                <label htmlFor="email">
                  {a.email} <span className="auth-hint">{a.emailHint}</span>
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>
              <div>
                <label htmlFor="phone">
                  {a.phone} <span className="auth-hint">{a.phoneHint}</span>
                </label>
                <input
                  id="phone"
                  name="phone"
                  type="tel"
                  autoComplete="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                />
              </div>
              <div>
                <label htmlFor="reg-password">
                  {a.password} <span className="auth-hint">{a.passwordHint}</span>
                </label>
                <input
                  id="reg-password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              <div>
                <label htmlFor="role">{a.role}</label>
                <select
                  id="role"
                  name="role"
                  value={role}
                  onChange={(e) => setRole(e.target.value as PublicRole)}
                >
                  {PUBLIC_ROLES.map((r) => (
                    <option key={r} value={r}>
                      {r === "student" ? a.roleStudent : r === "teacher" ? a.roleTeacher : a.roleParent}
                    </option>
                  ))}
                </select>
              </div>

              {error && (
                <p className="auth-error" role="alert">
                  {error}
                </p>
              )}

              <Button type="submit" variant="primary" disabled={pending}>
                {pending ? a.submitting : a.registerSubmit}
              </Button>
            </form>
          )}

          <div className="placeholder-links">
            <span>
              {variant === "login" ? a.noAccount : a.haveAccount}{" "}
              <Link href={switchHref}>{variant === "login" ? a.toRegister : a.toLogin}</Link>
            </span>
            <Link href="/">{a.backHome}</Link>
          </div>
        </div>
      </div>
    </section>
  );
}
