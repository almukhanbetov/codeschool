// Typed client for the Go Gin REST API (backend/). Every backend response is
// either {"data": ...} or {"error": {"code", "message"}} — apiFetch unwraps
// the former and throws a normalized ApiError for the latter, so callers
// never deal with the envelope or raw fetch/JSON errors directly.

import type {
  Assignment,
  AuthUser,
  CompleteLessonResult,
  Course,
  CourseContent,
  CourseListFilter,
  CourseProgress,
  CourseProgressDetail,
  Enrollment,
  Level,
  Lesson,
  LessonProgress,
  LoginInput,
  LoginResult,
  Module,
  MyCourseItem,
  Paginated,
  Program,
  RefreshResult,
  RegisterInput,
  Submission,
  SubmissionInput,
  SubmissionReviewRequest,
  TeacherDashboard,
  TeacherGroup,
  TeacherGroupDetail,
  TeacherGroupStudent,
  TeacherStudentDetail,
  TeacherSubmissionDetail,
  TeacherSubmissionListItem,
  TeacherSubmissionQuery,
  ParentChildListItem,
  ParentChildOverview,
  ParentChildCourseDetail,
  ParentActivitySummary,
} from "@/types";

export const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";

// Auth calls run in the browser so the HttpOnly refresh cookie is sent and
// stored. In Docker the server-side API_URL is an internal hostname
// ("backend:8080") the browser can't resolve, hence a separate base.
export const BROWSER_API_URL = process.env.NEXT_PUBLIC_BROWSER_API_URL ?? API_URL;

export class ApiError extends Error {
  readonly status: number;
  readonly code: string;

  constructor(status: number, code: string, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
  }
}

interface DataEnvelope<T> {
  data: T;
}

interface ErrorEnvelope {
  error: { code: string; message: string };
}

export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  let res: Response;
  try {
    // This is a live catalog, not static content — default to no caching so
    // a change in Postgres shows up on next request/refresh instead of
    // being frozen into the build (Next.js's `fetch` is cache: 'force-cache'
    // by default in Server Components, which would otherwise bake API
    // responses into the static HTML at build time).
    res = await fetch(`${API_URL}${path}`, { cache: "no-store", ...init });
  } catch {
    throw new ApiError(0, "NETWORK_ERROR", "Could not reach the API");
  }

  let body: unknown;
  try {
    body = await res.json();
  } catch {
    body = null;
  }

  if (!res.ok) {
    const errBody = body as Partial<ErrorEnvelope> | null;
    const code = errBody?.error?.code ?? "UNKNOWN_ERROR";
    const message = errBody?.error?.message ?? `Request failed with status ${res.status}`;
    throw new ApiError(res.status, code, message);
  }

  return (body as DataEnvelope<T>).data;
}

function buildQuery(params: Record<string, string | number | undefined>): string {
  const search = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined) search.set(key, String(value));
  }
  const qs = search.toString();
  return qs ? `?${qs}` : "";
}

export function getPrograms(): Promise<Program[]> {
  return apiFetch<Program[]>("/programs");
}

export function getProgram(id: number): Promise<Program> {
  return apiFetch<Program>(`/programs/${id}`);
}

export function getProgramLevels(programId: number): Promise<Level[]> {
  return apiFetch<Level[]>(`/programs/${programId}/levels`);
}

export function getCourses(filter: CourseListFilter = {}): Promise<Course[]> {
  const query = buildQuery({
    age_from: filter.ageFrom,
    age_to: filter.ageTo,
    level_id: filter.levelId,
  });
  return apiFetch<Course[]>(`/courses${query}`);
}

export function getCourse(id: number): Promise<Course> {
  return apiFetch<Course>(`/courses/${id}`);
}

export function getCourseBySlug(slug: string): Promise<Course> {
  return apiFetch<Course>(`/courses/slug/${encodeURIComponent(slug)}`);
}

export function getCourseModules(courseId: number): Promise<Module[]> {
  return apiFetch<Module[]>(`/courses/${courseId}/modules`);
}

export function getCourseContent(courseId: number): Promise<CourseContent> {
  return apiFetch<CourseContent>(`/courses/${courseId}/content`);
}

export function getModuleLessons(moduleId: number): Promise<Lesson[]> {
  return apiFetch<Lesson[]>(`/modules/${moduleId}/lessons`);
}

export function getLesson(id: number): Promise<Lesson> {
  return apiFetch<Lesson>(`/lessons/${id}`);
}

/* =========================================================
   Auth — browser-side. The access token lives only in memory
   (set by the AuthProvider); the refresh token is an HttpOnly
   cookie the browser sends automatically with credentials:"include".
   ========================================================= */

let accessToken: string | null = null;

/** Called by the AuthProvider whenever the in-memory access token changes. */
export function setAccessToken(token: string | null): void {
  accessToken = token;
}

// The AuthProvider registers a refresher so a protected call that 401s can
// transparently get a new access token (via the HttpOnly refresh cookie) and
// retry once — reusing the one auth flow, per spec §54.
let tokenRefresher: (() => Promise<string | null>) | null = null;

export function setTokenRefresher(fn: (() => Promise<string | null>) | null): void {
  tokenRefresher = fn;
}

async function rawBrowserFetch(
  path: string,
  rest: RequestInit,
  headers: Headers
): Promise<{ res: Response; body: unknown }> {
  let res: Response;
  try {
    res = await fetch(`${BROWSER_API_URL}${path}`, {
      cache: "no-store",
      credentials: "include",
      headers,
      ...rest,
    });
  } catch {
    throw new ApiError(0, "NETWORK_ERROR", "Could not reach the API");
  }
  let body: unknown = null;
  try {
    body = await res.json();
  } catch {
    body = null;
  }
  return { res, body };
}

async function browserFetch<T>(
  path: string,
  init: RequestInit & { auth?: boolean } = {}
): Promise<T> {
  const { auth = false, headers, ...rest } = init;

  const build = () => {
    const h = new Headers(headers);
    if (rest.body !== undefined) h.set("Content-Type", "application/json");
    if (auth && accessToken) h.set("Authorization", `Bearer ${accessToken}`);
    return h;
  };

  let { res, body } = await rawBrowserFetch(path, rest, build());

  // One transparent retry after refreshing the access token.
  if (res.status === 401 && auth && tokenRefresher) {
    const fresh = await tokenRefresher();
    if (fresh) {
      ({ res, body } = await rawBrowserFetch(path, rest, build()));
    }
  }

  if (!res.ok) {
    const errBody = body as Partial<ErrorEnvelope> | null;
    throw new ApiError(
      res.status,
      errBody?.error?.code ?? "UNKNOWN_ERROR",
      errBody?.error?.message ?? `Request failed with status ${res.status}`
    );
  }

  return (body as DataEnvelope<T>).data;
}

export function login(input: LoginInput): Promise<LoginResult> {
  return browserFetch<LoginResult>("/auth/login", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export function register(input: RegisterInput): Promise<AuthUser> {
  return browserFetch<AuthUser>("/auth/register", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

/** Uses the HttpOnly refresh cookie — no argument needed. */
export function refresh(): Promise<RefreshResult> {
  return browserFetch<RefreshResult>("/auth/refresh", { method: "POST" });
}

export function logout(): Promise<unknown> {
  return browserFetch<unknown>("/auth/logout", { method: "POST" });
}

export function getMe(): Promise<AuthUser> {
  return browserFetch<AuthUser>("/me", { auth: true });
}

/* =========================================================
   Student flow — all browser-side, all require a student token.
   ========================================================= */

export function enrollCourse(courseId: number): Promise<Enrollment> {
  return browserFetch<Enrollment>(`/courses/${courseId}/enroll`, { method: "POST", auth: true });
}

export function getMyCourses(): Promise<MyCourseItem[]> {
  return browserFetch<MyCourseItem[]>("/me/courses", { auth: true });
}

export function getMyProgress(): Promise<CourseProgress[]> {
  return browserFetch<CourseProgress[]>("/me/progress", { auth: true });
}

export function getCourseProgress(courseId: number): Promise<CourseProgressDetail> {
  return browserFetch<CourseProgressDetail>(`/me/courses/${courseId}/progress`, { auth: true });
}

export function startLesson(lessonId: number): Promise<LessonProgress> {
  return browserFetch<LessonProgress>(`/lessons/${lessonId}/start`, { method: "POST", auth: true });
}

export function completeLesson(lessonId: number): Promise<CompleteLessonResult> {
  return browserFetch<CompleteLessonResult>(`/lessons/${lessonId}/complete`, {
    method: "POST",
    auth: true,
  });
}

export function getLessonAssignments(lessonId: number): Promise<Assignment[]> {
  return browserFetch<Assignment[]>(`/lessons/${lessonId}/assignments`, { auth: true });
}

export function getMySubmission(assignmentId: number): Promise<Submission | null> {
  return browserFetch<Submission | null>(`/assignments/${assignmentId}/submission`, { auth: true });
}

export function saveSubmissionDraft(
  assignmentId: number,
  input: SubmissionInput
): Promise<Submission> {
  return browserFetch<Submission>(`/assignments/${assignmentId}/submission`, {
    method: "PUT",
    body: JSON.stringify(input),
    auth: true,
  });
}

export function submitAssignment(assignmentId: number): Promise<Submission> {
  return browserFetch<Submission>(`/assignments/${assignmentId}/submit`, {
    method: "POST",
    auth: true,
  });
}

/* =========================================================
   Teacher flow — all browser-side, all require a teacher token.
   ========================================================= */

// browserFetchRaw is browserFetch that returns the whole envelope (so the
// paginated teacher list can read `meta`). Same auth + 401-retry path.
async function browserFetchRaw<T>(
  path: string,
  init: RequestInit & { auth?: boolean } = {}
): Promise<T> {
  const { auth = false, headers, ...rest } = init;
  const build = () => {
    const h = new Headers(headers);
    if (rest.body !== undefined) h.set("Content-Type", "application/json");
    if (auth && accessToken) h.set("Authorization", `Bearer ${accessToken}`);
    return h;
  };
  let { res, body } = await rawBrowserFetch(path, rest, build());
  if (res.status === 401 && auth && tokenRefresher) {
    const fresh = await tokenRefresher();
    if (fresh) ({ res, body } = await rawBrowserFetch(path, rest, build()));
  }
  if (!res.ok) {
    const errBody = body as Partial<ErrorEnvelope> | null;
    throw new ApiError(
      res.status,
      errBody?.error?.code ?? "UNKNOWN_ERROR",
      errBody?.error?.message ?? `Request failed with status ${res.status}`
    );
  }
  return body as T;
}

export function getTeacherDashboard(): Promise<TeacherDashboard> {
  return browserFetch<TeacherDashboard>("/teacher/dashboard", { auth: true });
}

export function getTeacherGroups(): Promise<TeacherGroup[]> {
  return browserFetch<TeacherGroup[]>("/teacher/groups", { auth: true });
}

export function getTeacherGroup(groupId: number): Promise<TeacherGroupDetail> {
  return browserFetch<TeacherGroupDetail>(`/teacher/groups/${groupId}`, { auth: true });
}

export function getTeacherGroupStudents(groupId: number): Promise<TeacherGroupStudent[]> {
  return browserFetch<TeacherGroupStudent[]>(`/teacher/groups/${groupId}/students`, { auth: true });
}

export function getTeacherStudent(
  groupId: number,
  studentId: number
): Promise<TeacherStudentDetail> {
  return browserFetch<TeacherStudentDetail>(
    `/teacher/groups/${groupId}/students/${studentId}`,
    { auth: true }
  );
}

export function getTeacherSubmissions(
  query: TeacherSubmissionQuery = {}
): Promise<Paginated<TeacherSubmissionListItem>> {
  const qs = buildQuery({
    status: query.status,
    group_id: query.groupId,
    course_id: query.courseId,
    page: query.page,
    limit: query.limit,
  });
  return browserFetchRaw<Paginated<TeacherSubmissionListItem>>(`/teacher/submissions${qs}`, {
    auth: true,
  });
}

export function getTeacherSubmission(id: number): Promise<TeacherSubmissionDetail> {
  return browserFetch<TeacherSubmissionDetail>(`/teacher/submissions/${id}`, { auth: true });
}

export function startSubmissionReview(id: number): Promise<TeacherSubmissionDetail> {
  return browserFetch<TeacherSubmissionDetail>(`/teacher/submissions/${id}/start-review`, {
    method: "POST",
    auth: true,
  });
}

export function reviewSubmission(
  id: number,
  body: SubmissionReviewRequest
): Promise<TeacherSubmissionDetail> {
  return browserFetch<TeacherSubmissionDetail>(`/teacher/submissions/${id}/review`, {
    method: "POST",
    body: JSON.stringify(body),
    auth: true,
  });
}

/* =========================================================
   Parent flow — browser-side, read-only, require a parent token.
   ========================================================= */

export function getParentChildren(): Promise<ParentChildListItem[]> {
  return browserFetch<ParentChildListItem[]>("/parent/children", { auth: true });
}

export function getParentChild(childId: number): Promise<ParentChildOverview> {
  return browserFetch<ParentChildOverview>(`/parent/children/${childId}`, { auth: true });
}

export function getParentChildCourse(
  childId: number,
  courseId: number
): Promise<ParentChildCourseDetail> {
  return browserFetch<ParentChildCourseDetail>(
    `/parent/children/${childId}/courses/${courseId}`,
    { auth: true }
  );
}

export function getParentChildActivity(childId: number): Promise<ParentActivitySummary> {
  return browserFetch<ParentActivitySummary>(`/parent/children/${childId}/activity`, {
    auth: true,
  });
}
