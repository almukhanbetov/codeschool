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
  AdminOverview,
  AdminUser,
  AdminParentLink,
  AdminProgram,
  AdminLevel,
  AdminCourse,
  AdminModule,
  AdminLesson,
  AdminAssignment,
  AdminGroup,
  AdminGroupStudent,
  AdminAuditRow,
  QuizStartResponse,
  QuizResult,
  QuizAttemptDetail,
  QuizAttemptHistory,
  QuizSubmitAnswer,
  AdminQuiz,
  AdminQuizSettings,
  AdminQuizQuestion,
  AdminQuizOption,
  QuizDeleteResult,
  CodeRunResult,
  CodeRunHistoryItem,
  AssignmentTestsResponse,
  CodeGradeResult,
  AdminAssignmentTest,
  AcademyCourseCard,
  AcademyMyCourse,
  AcademyDashboard,
  AcademyLearnerRow,
  AcademySubmissionRow,
  AcademySubmissionDetail,
  Certificate,
  CertificateVerification,
  AdminCertificateRow,
  AdminCertificateList,
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

// browserFetchBlob is browserFetch for binary responses (PDF downloads). It
// reuses the same auth + one-shot token-refresh flow but returns a Blob.
async function browserFetchBlob(path: string): Promise<Blob> {
  const build = () => {
    const h = new Headers();
    if (accessToken) h.set("Authorization", `Bearer ${accessToken}`);
    return h;
  };
  const call = () =>
    fetch(`${BROWSER_API_URL}${path}`, {
      cache: "no-store",
      credentials: "include",
      headers: build(),
    });

  let res: Response;
  try {
    res = await call();
  } catch {
    throw new ApiError(0, "NETWORK_ERROR", "Could not reach the API");
  }
  if (res.status === 401 && tokenRefresher) {
    const fresh = await tokenRefresher();
    if (fresh) {
      try {
        res = await call();
      } catch {
        throw new ApiError(0, "NETWORK_ERROR", "Could not reach the API");
      }
    }
  }
  if (!res.ok) {
    let message = `Request failed with status ${res.status}`;
    let code = "UNKNOWN_ERROR";
    try {
      const body = (await res.json()) as Partial<ErrorEnvelope>;
      message = body?.error?.message ?? message;
      code = body?.error?.code ?? code;
    } catch {
      /* non-JSON error body */
    }
    throw new ApiError(res.status, code, message);
  }
  return res.blob();
}

function triggerDownload(blob: Blob, filename: string): void {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  // Revoke on the next tick so the download has started.
  setTimeout(() => URL.revokeObjectURL(url), 0);
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

export function getCourseProgress(courseId: number, prefix = ""): Promise<CourseProgressDetail> {
  return browserFetch<CourseProgressDetail>(`${prefix}/me/courses/${courseId}/progress`, { auth: true });
}

export function startLesson(lessonId: number, prefix = ""): Promise<LessonProgress> {
  return browserFetch<LessonProgress>(`${prefix}/lessons/${lessonId}/start`, { method: "POST", auth: true });
}

export function completeLesson(lessonId: number, prefix = ""): Promise<CompleteLessonResult> {
  return browserFetch<CompleteLessonResult>(`${prefix}/lessons/${lessonId}/complete`, {
    method: "POST",
    auth: true,
  });
}

export function getLessonAssignments(lessonId: number, prefix = ""): Promise<Assignment[]> {
  return browserFetch<Assignment[]>(`${prefix}/lessons/${lessonId}/assignments`, { auth: true });
}

export function getMySubmission(assignmentId: number, prefix = ""): Promise<Submission | null> {
  return browserFetch<Submission | null>(`${prefix}/assignments/${assignmentId}/submission`, { auth: true });
}

export function saveSubmissionDraft(
  assignmentId: number,
  input: SubmissionInput,
  prefix = ""
): Promise<Submission> {
  return browserFetch<Submission>(`${prefix}/assignments/${assignmentId}/submission`, {
    method: "PUT",
    body: JSON.stringify(input),
    auth: true,
  });
}

export function submitAssignment(assignmentId: number, prefix = ""): Promise<Submission> {
  return browserFetch<Submission>(`${prefix}/assignments/${assignmentId}/submit`, {
    method: "POST",
    auth: true,
  });
}

/* =========================================================
   Quiz engine — student side. Scoring is entirely server-side;
   the client never sends or trusts a score.
   ========================================================= */

export function startQuizAttempt(assignmentId: number, prefix = ""): Promise<QuizStartResponse> {
  return browserFetch<QuizStartResponse>(`${prefix}/assignments/${assignmentId}/quiz/attempts`, {
    method: "POST",
    auth: true,
  });
}

export function getQuizAttempts(assignmentId: number, prefix = ""): Promise<QuizAttemptHistory> {
  return browserFetch<QuizAttemptHistory>(`${prefix}/assignments/${assignmentId}/quiz/attempts`, {
    auth: true,
  });
}

export function submitQuizAttempt(
  attemptId: number,
  answers: QuizSubmitAnswer[],
  prefix = ""
): Promise<QuizResult> {
  return browserFetch<QuizResult>(`${prefix}/quiz/attempts/${attemptId}/submit`, {
    method: "POST",
    body: JSON.stringify({ answers }),
    auth: true,
  });
}

export function getQuizAttempt(attemptId: number, prefix = ""): Promise<QuizAttemptDetail> {
  return browserFetch<QuizAttemptDetail>(`${prefix}/quiz/attempts/${attemptId}`, { auth: true });
}

export function getTeacherQuizAttempt(attemptId: number): Promise<QuizResult> {
  return browserFetch<QuizResult>(`/teacher/quiz/attempts/${attemptId}`, { auth: true });
}

/* =========================================================
   Code runner — student side. Execution happens in a sandboxed
   service; the client only ever sees stdout/stderr/exit code.
   ========================================================= */

export function runCode(
  assignmentId: number,
  code: string,
  stdin: string,
  prefix = ""
): Promise<CodeRunResult> {
  return browserFetch<CodeRunResult>(`${prefix}/assignments/${assignmentId}/run`, {
    method: "POST",
    body: JSON.stringify({ code, stdin }),
    auth: true,
  });
}

export function getCodeRuns(assignmentId: number, prefix = ""): Promise<CodeRunHistoryItem[]> {
  return browserFetch<CodeRunHistoryItem[]>(`${prefix}/assignments/${assignmentId}/runs`, { auth: true });
}

export function getAssignmentTests(assignmentId: number, prefix = ""): Promise<AssignmentTestsResponse> {
  return browserFetch<AssignmentTestsResponse>(`${prefix}/assignments/${assignmentId}/tests`, { auth: true });
}

export function submitCodeForGrading(
  assignmentId: number,
  code: string,
  prefix = ""
): Promise<CodeGradeResult> {
  return browserFetch<CodeGradeResult>(`${prefix}/assignments/${assignmentId}/code/submit`, {
    method: "POST",
    body: JSON.stringify({ code }),
    auth: true,
  });
}

/* =========================================================
   Teacher Academy — the teacher's own professional learning.
   ACADEMY_API is the prefix passed to the shared learn functions
   above so they hit the /teacher-academy/* copy of the routes.
   ========================================================= */

export const ACADEMY_API = "/teacher-academy";

export function getTeacherAcademyCourses(): Promise<AcademyCourseCard[]> {
  return browserFetch<AcademyCourseCard[]>("/teacher-academy/courses", { auth: true });
}

export function enrollTeacherAcademyCourse(courseId: number): Promise<Enrollment> {
  return browserFetch<Enrollment>(`/teacher-academy/courses/${courseId}/enroll`, {
    method: "POST",
    auth: true,
  });
}

export function getMyAcademyCourses(): Promise<AcademyMyCourse[]> {
  return browserFetch<AcademyMyCourse[]>("/teacher-academy/me/courses", { auth: true });
}

export function getAcademyDashboard(): Promise<AcademyDashboard> {
  return browserFetch<AcademyDashboard>("/teacher-academy/dashboard", { auth: true });
}

export function getAcademyCourseContent(courseId: number): Promise<CourseContent> {
  return browserFetch<CourseContent>(`/teacher-academy/courses/${courseId}/content`, { auth: true });
}

/* Admin academy review */
export const adminAcademyApi = {
  learners: () =>
    browserFetch<AcademyLearnerRow[]>("/admin/academy/learners", { auth: true }),
  submissions: (status?: string) =>
    browserFetch<AcademySubmissionRow[]>(
      `/admin/academy/submissions${status ? `?status=${encodeURIComponent(status)}` : ""}`,
      { auth: true }
    ),
  submission: (id: number) =>
    browserFetch<AcademySubmissionDetail>(`/admin/academy/submissions/${id}`, { auth: true }),
  review: (id: number, body: { score?: number | null; feedback: string; status: "passed" | "failed" }) =>
    browserFetch<AcademySubmissionDetail>(`/admin/academy/submissions/${id}/review`, {
      method: "POST",
      body: JSON.stringify(body),
      auth: true,
    }),
};

/* =========================================================
   Certificates — one universal engine for every learner (student or
   teacher academy). Ownership, not role, is the boundary.
   ========================================================= */

// Issue-or-get (idempotent). prefix "" hits /courses/:id/certificate;
// prefix "/teacher-academy" hits the academy alias — same backend service.
export function issueCertificate(courseId: number, prefix = ""): Promise<Certificate> {
  return browserFetch<Certificate>(`${prefix}/courses/${courseId}/certificate`, {
    method: "POST",
    auth: true,
  });
}

export function getMyCertificates(): Promise<Certificate[]> {
  return browserFetch<Certificate[]>("/me/certificates", { auth: true });
}

export function getMyCertificate(id: number): Promise<Certificate> {
  return browserFetch<Certificate>(`/me/certificates/${id}`, { auth: true });
}

// Public — no auth. Throws ApiError(404) when the code is unknown.
export function verifyCertificate(code: string): Promise<CertificateVerification> {
  return browserFetch<CertificateVerification>(
    `/certificates/verify/${encodeURIComponent(code)}`
  );
}

// Streams the owner's certificate PDF and triggers a browser download.
export async function downloadCertificatePdf(
  id: number,
  lang: string,
  filenameHint: string
): Promise<void> {
  const blob = await browserFetchBlob(`/me/certificates/${id}/pdf?lang=${encodeURIComponent(lang)}`);
  triggerDownload(blob, `${filenameHint}.pdf`);
}

export const adminCertificatesApi = {
  list: (params: { status?: string; courseId?: number; q?: string; page?: number; limit?: number }) =>
    browserFetch<AdminCertificateList>(
      `/admin/certificates${buildQuery({
        status: params.status,
        course_id: params.courseId,
        q: params.q,
        page: params.page,
        limit: params.limit,
      })}`,
      { auth: true }
    ),
  get: (id: number) =>
    browserFetch<AdminCertificateRow>(`/admin/certificates/${id}`, { auth: true }),
  revoke: (id: number, reason: string) =>
    browserFetch<AdminCertificateRow>(`/admin/certificates/${id}/revoke`, {
      method: "POST",
      body: JSON.stringify({ reason }),
      auth: true,
    }),
  downloadPdf: async (id: number, lang: string, filenameHint: string) => {
    const blob = await browserFetchBlob(
      `/admin/certificates/${id}/pdf?lang=${encodeURIComponent(lang)}`
    );
    triggerDownload(blob, `${filenameHint}.pdf`);
  },
};

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

/* =========================================================
   Admin panel — browser-side, require an admin token.
   Every mutating call is audited server-side.
   ========================================================= */

function aq(params: Record<string, string | number | boolean | undefined>): string {
  const s = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== "") s.set(k, String(v));
  }
  const q = s.toString();
  return q ? `?${q}` : "";
}

interface AdminCrud<Row> {
  list(query?: Record<string, string | number | boolean | undefined>): Promise<Row[]>;
  get(id: number): Promise<Row>;
  create(body: unknown): Promise<Row>;
  update(id: number, body: unknown): Promise<Row>;
  remove(id: number): Promise<unknown>;
}

function adminCrud<Row>(base: string): AdminCrud<Row> {
  return {
    list: (query = {}) => browserFetch<Row[]>(`${base}${aq(query)}`, { auth: true }),
    get: (id) => browserFetch<Row>(`${base}/${id}`, { auth: true }),
    create: (body) =>
      browserFetch<Row>(base, { method: "POST", body: JSON.stringify(body), auth: true }),
    update: (id, body) =>
      browserFetch<Row>(`${base}/${id}`, { method: "PATCH", body: JSON.stringify(body), auth: true }),
    remove: (id) => browserFetch<unknown>(`${base}/${id}`, { method: "DELETE", auth: true }),
  };
}

export const adminApi = {
  overview: () => browserFetch<AdminOverview>("/admin/overview", { auth: true }),

  audit: (page = 1, limit = 30) =>
    browserFetchRaw<{ data: AdminAuditRow[]; meta: { page: number; limit: number; total: number } }>(
      `/admin/audit${aq({ page, limit })}`,
      { auth: true }
    ),

  users: {
    list: (query: Record<string, string | number | boolean | undefined> = {}) =>
      browserFetchRaw<{ data: AdminUser[]; meta: { page: number; limit: number; total: number } }>(
        `/admin/users${aq(query)}`,
        { auth: true }
      ),
    get: (id: number) => browserFetch<AdminUser>(`/admin/users/${id}`, { auth: true }),
    create: (body: unknown) =>
      browserFetch<AdminUser>("/admin/users", { method: "POST", body: JSON.stringify(body), auth: true }),
    update: (id: number, body: unknown) =>
      browserFetch<AdminUser>(`/admin/users/${id}`, { method: "PATCH", body: JSON.stringify(body), auth: true }),
    remove: (id: number) =>
      browserFetch<unknown>(`/admin/users/${id}`, { method: "DELETE", auth: true }),
    setPassword: (id: number, password: string) =>
      browserFetch<unknown>(`/admin/users/${id}/password`, {
        method: "POST",
        body: JSON.stringify({ password }),
        auth: true,
      }),
  },

  parentLinks: {
    list: (query: Record<string, string | number | boolean | undefined> = {}) =>
      browserFetch<AdminParentLink[]>(`/admin/parent-links${aq(query)}`, { auth: true }),
    create: (parentId: number, childId: number) =>
      browserFetch<unknown>("/admin/parent-links", {
        method: "POST",
        body: JSON.stringify({ parentId, childId }),
        auth: true,
      }),
    remove: (parentId: number, childId: number) =>
      browserFetch<unknown>(`/admin/parent-links${aq({ parentId, childId })}`, {
        method: "DELETE",
        auth: true,
      }),
  },

  programs: adminCrud<AdminProgram>("/admin/programs"),
  levels: adminCrud<AdminLevel>("/admin/levels"),
  courses: adminCrud<AdminCourse>("/admin/courses"),
  modules: adminCrud<AdminModule>("/admin/modules"),
  lessons: adminCrud<AdminLesson>("/admin/lessons"),
  assignments: adminCrud<AdminAssignment>("/admin/assignments"),
  groups: adminCrud<AdminGroup>("/admin/groups"),

  groupStudents: {
    list: (groupId: number) =>
      browserFetch<AdminGroupStudent[]>(`/admin/groups/${groupId}/students`, { auth: true }),
    add: (groupId: number, studentId: number) =>
      browserFetch<unknown>(`/admin/groups/${groupId}/students`, {
        method: "POST",
        body: JSON.stringify({ studentId }),
        auth: true,
      }),
    remove: (groupId: number, studentId: number) =>
      browserFetch<unknown>(`/admin/groups/${groupId}/students/${studentId}`, {
        method: "DELETE",
        auth: true,
      }),
  },

  // Quiz authoring. Every call here is audited server-side.
  quiz: {
    get: (assignmentId: number) =>
      browserFetch<AdminQuiz>(`/admin/assignments/${assignmentId}/quiz`, { auth: true }),
    updateSettings: (assignmentId: number, body: AdminQuizSettings) =>
      browserFetch<AdminQuizSettings>(`/admin/assignments/${assignmentId}/quiz/settings`, {
        method: "PUT",
        body: JSON.stringify(body),
        auth: true,
      }),
    createQuestion: (assignmentId: number, body: unknown) =>
      browserFetch<AdminQuizQuestion>(`/admin/assignments/${assignmentId}/quiz/questions`, {
        method: "POST",
        body: JSON.stringify(body),
        auth: true,
      }),
    updateQuestion: (questionId: number, body: unknown) =>
      browserFetch<AdminQuizQuestion>(`/admin/quiz/questions/${questionId}`, {
        method: "PATCH",
        body: JSON.stringify(body),
        auth: true,
      }),
    deleteQuestion: (questionId: number) =>
      browserFetch<QuizDeleteResult>(`/admin/quiz/questions/${questionId}`, {
        method: "DELETE",
        auth: true,
      }),
    createOption: (questionId: number, body: unknown) =>
      browserFetch<AdminQuizOption>(`/admin/quiz/questions/${questionId}/options`, {
        method: "POST",
        body: JSON.stringify(body),
        auth: true,
      }),
    updateOption: (optionId: number, body: unknown) =>
      browserFetch<AdminQuizOption>(`/admin/quiz/options/${optionId}`, {
        method: "PATCH",
        body: JSON.stringify(body),
        auth: true,
      }),
    deleteOption: (optionId: number) =>
      browserFetch<QuizDeleteResult>(`/admin/quiz/options/${optionId}`, {
        method: "DELETE",
        auth: true,
      }),
  },

  // Code assignment I/O test cases (visible + hidden). Audited server-side.
  tests: {
    list: (assignmentId: number) =>
      browserFetch<AdminAssignmentTest[]>(`/admin/assignments/${assignmentId}/tests`, { auth: true }),
    create: (assignmentId: number, body: unknown) =>
      browserFetch<AdminAssignmentTest>(`/admin/assignments/${assignmentId}/tests`, {
        method: "POST",
        body: JSON.stringify(body),
        auth: true,
      }),
    update: (testId: number, body: unknown) =>
      browserFetch<AdminAssignmentTest>(`/admin/tests/${testId}`, {
        method: "PATCH",
        body: JSON.stringify(body),
        auth: true,
      }),
    remove: (testId: number) =>
      browserFetch<unknown>(`/admin/tests/${testId}`, { method: "DELETE", auth: true }),
  },
};
