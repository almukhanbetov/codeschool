export type Language = "ru" | "kz" | "en";

export type Theme = "dark" | "light";

export interface NavTranslations {
  home: string;
  directions: string;
  courses: string;
  children: string;
  teachers: string;
  parents: string;
  projects: string;
  about: string;
}

export interface HeaderTranslations {
  login: string;
  cta: string;
  logout: string;
}

export interface AuthTranslations {
  loginTitle: string;
  loginSubtitle: string;
  registerTitle: string;
  registerSubtitle: string;
  firstName: string;
  lastName: string;
  lastNameHint: string;
  email: string;
  emailHint: string;
  phone: string;
  phoneHint: string;
  emailOrPhone: string;
  password: string;
  passwordHint: string;
  role: string;
  roleStudent: string;
  roleTeacher: string;
  roleParent: string;
  loginSubmit: string;
  registerSubmit: string;
  submitting: string;
  haveAccount: string;
  noAccount: string;
  toLogin: string;
  toRegister: string;
  errInvalidCredentials: string;
  errEmailTaken: string;
  errPhoneTaken: string;
  errNeedEmailOrPhone: string;
  errPasswordShort: string;
  errFirstNameRequired: string;
  errGeneric: string;
  welcome: string;
  dashTitle: string;
  dashSubtitle: string;
  dashRole: string;
  backHome: string;
  checking: string;
}

export interface HeroTranslations {
  badge: string;
  title1: string;
  title2: string;
  subtitle: string;
  extra: string;
  cta1: string;
  cta2: string;
  trust1: string;
  trust2: string;
  trust3: string;
  trust4: string;
}

export interface PathTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  stage1: string;
  stage2: string;
  stage3: string;
  stage4: string;
  stage5: string;
  stage6: string;
}

export interface DirectionCardTranslations {
  title: string;
  tag2?: string;
  tag3?: string;
  tag4?: string;
}

export interface DirectionsTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  card1: DirectionCardTranslations;
  card2: DirectionCardTranslations;
  card3: DirectionCardTranslations;
  card4: DirectionCardTranslations;
  card5: DirectionCardTranslations;
  card6: DirectionCardTranslations;
}

export interface CoursesTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  loadError: string;
}

export interface FilterTranslations {
  all: string;
  a1: string;
  a2: string;
  a3: string;
  a4: string;
  a5: string;
  empty: string;
}

export interface CourseDetailTranslations {
  modulesHeading: string;
  noModules: string;
  backToCourses: string;
}

// Course titles/descriptions now come from the API (see types.Course) and
// are not yet translated per-language (see backend/README.md) — only the
// surrounding UI chrome (age/lessons/level labels, the "more" button) is.
export interface CourseTranslations {
  age: string;
  years: string;
  lessons: string;
  projects: string;
  levelBeginner: string;
  levelMiddle: string;
  levelAdvanced: string;
  more: string;
}

export interface ChildrenTranslations {
  eyebrow: string;
  title: string;
  lead1: string;
  lead2: string;
  ex1: string;
  ex2: string;
  ex3: string;
  ex4: string;
  ex5: string;
  ex6: string;
}

export interface ProjectItemTranslations {
  title: string;
  age: string;
  desc: string;
}

export interface ProjectsTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  p1: ProjectItemTranslations;
  p2: ProjectItemTranslations;
  p3: ProjectItemTranslations;
  p4: ProjectItemTranslations;
}

export interface TeacherTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  step1: string;
  step2: string;
  step3: string;
  step4: string;
  step5: string;
  cta: string;
}

export interface AiTutorTranslations {
  eyebrow: string;
  title: string;
  desc1: string;
  desc2: string;
  q: string;
  a1: string;
  a2: string;
  a3: string;
}

export interface ParentsTranslations {
  eyebrow: string;
  title: string;
  desc: string;
  progress: string;
  lessons: string;
  projects: string;
  strength: string;
  strengthValue: string;
  nextgoal: string;
  nextgoalValue: string;
}

export interface DashboardTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  sidebar1: string;
  sidebar2: string;
  sidebar3: string;
  sidebar4: string;
  lessonNum: string;
  lessonName: string;
  continue: string;
}

export interface StatsTranslations {
  s1: string;
  s2: string;
  s3: string;
  s4: string;
}

export interface WhyUsTranslations {
  eyebrow: string;
  title: string;
  w1: string;
  w2: string;
  w3: string;
  w4: string;
  w5: string;
  w6: string;
  w7: string;
}

export interface PhilosophyTranslations {
  line1: string;
  line2: string;
}

export interface FinalCtaTranslations {
  title: string;
  cta1: string;
  cta2: string;
  cta3: string;
}

export interface FooterTranslations {
  tagline: string;
  platform: string;
  programming: string;
  robotics: string;
  ai: string;
  people: string;
  teacherAcademy: string;
  about: string;
  contacts: string;
  language: string;
  rights: string;
  note: string;
}

export interface PlaceholderAuthTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  nameLabel?: string;
  emailLabel: string;
  passwordLabel: string;
  submit: string;
  switchText: string;
  switchLinkLabel: string;
}

export interface PlaceholderInfoTranslations {
  eyebrow: string;
  title: string;
  subtitle: string;
  backCta: string;
}

export interface PlaceholderTranslations {
  login: PlaceholderAuthTranslations;
  register: PlaceholderAuthTranslations;
  teacher: PlaceholderInfoTranslations;
}

export interface StudentTranslations {
  title: string;
  myCourses: string;
  overallProgress: string;
  continueLearning: string;
  lastActive: string;
  noCourses: string;
  browseCourses: string;
  viewAll: string;
  completed: string;
  inProgress: string;
  notStarted: string;
  lessonsDone: string;
}

export interface LearnTranslations {
  backToCourse: string;
  backToDashboard: string;
  lessonsNav: string;
  content: string;
  assignment: string;
  noAssignment: string;
  saveDraft: string;
  submit: string;
  saving: string;
  saved: string;
  submitting: string;
  submittedNotice: string;
  completeLesson: string;
  completeHint: string;
  completing: string;
  lessonCompleted: string;
  courseCompleted: string;
  yourAnswer: string;
  yourCode: string;
  projectPlaceholder: string;
  expectedOutput: string;
  starterCode: string;
  loading: string;
  loadError: string;
  notEnrolled: string;
  progress: string;
  loginToStart: string;
  startLearning: string;
  openCourse: string;
  statusDraft: string;
  statusSubmitted: string;
  statusChecking: string;
  statusPassed: string;
  statusFailed: string;
}

export interface TeachTranslations {
  dashTitle: string;
  cardGroups: string;
  cardStudents: string;
  cardPending: string;
  cardReviewed: string;
  myGroups: string;
  groupsEmpty: string;
  openGroup: string;
  students: string;
  studentsCount: string;
  progress: string;
  pending: string;
  joined: string;
  avgProgress: string;
  backToGroups: string;
  backToGroup: string;
  backToDashboard: string;
  backToQueue: string;
  viewStudent: string;
  lessonProgress: string;
  assignments: string;
  noSubmission: string;
  queueTitle: string;
  tabPending: string;
  tabChecking: string;
  tabPassed: string;
  tabFailed: string;
  tabAll: string;
  allReviewed: string;
  review: string;
  student: string;
  course: string;
  lesson: string;
  assignment: string;
  submittedAt: string;
  studentAnswer: string;
  studentCode: string;
  description: string;
  starterCode: string;
  maxPoints: string;
  score: string;
  feedback: string;
  feedbackPlaceholder: string;
  markPassed: string;
  markFailed: string;
  startReview: string;
  saving: string;
  reviewSaved: string;
  reviewError: string;
  feedbackRequired: string;
  loading: string;
  loadError: string;
  prevPage: string;
  nextPage: string;
  notReviewable: string;
}

export interface Translations {
  meta: { title: string };
  nav: NavTranslations;
  header: HeaderTranslations;
  auth: AuthTranslations;
  student: StudentTranslations;
  learn: LearnTranslations;
  teach: TeachTranslations;
  hero: HeroTranslations;
  path: PathTranslations;
  directions: DirectionsTranslations;
  courses: CoursesTranslations;
  courseDetail: CourseDetailTranslations;
  filter: FilterTranslations;
  course: CourseTranslations;
  children: ChildrenTranslations;
  projects: ProjectsTranslations;
  teacher: TeacherTranslations;
  aitutor: AiTutorTranslations;
  parents: ParentsTranslations;
  dashboard: DashboardTranslations;
  stats: StatsTranslations;
  whyus: WhyUsTranslations;
  philosophy: PhilosophyTranslations;
  finalcta: FinalCtaTranslations;
  footer: FooterTranslations;
  placeholder: PlaceholderTranslations;
}

export type AgeFilter = "all" | "6-8" | "8-10" | "10-12" | "12-14" | "14-17";

export type PathStageKey =
  | "stage1"
  | "stage2"
  | "stage3"
  | "stage4"
  | "stage5"
  | "stage6";

export interface LearningPathStage {
  id: string;
  age: string;
  icon: string;
  titleKey: PathStageKey;
  final?: boolean;
}

export type DirectionCardKey =
  | "card1"
  | "card2"
  | "card3"
  | "card4"
  | "card5"
  | "card6";

export type DirectionTag =
  | { literal: string }
  | { key: keyof DirectionCardTranslations };

export interface DirectionItem {
  id: string;
  icon: string;
  accentClass: string;
  cardKey: DirectionCardKey;
  tags: DirectionTag[];
}

export type ProjectKey = "p1" | "p2" | "p3" | "p4";

export interface ProjectItem {
  id: string;
  key: ProjectKey;
  icon: string;
  thumbClass: string;
  tech: string;
}

export interface WhyUsItem {
  id: string;
  icon: string;
  key: keyof WhyUsTranslations;
}

export interface ChildrenExample {
  id: string;
  icon: string;
  key: keyof ChildrenTranslations;
}

export interface NavItem {
  href: string;
  key: keyof NavTranslations;
}

export interface StatItem {
  id: string;
  count?: number;
  suffix?: string;
  staticValue?: string;
  key: keyof StatsTranslations;
}

/* =========================================================
   API — Go Gin REST backend (frontend/lib/api.ts)
   Mirrors the JSON shape of backend/internal/{programs,levels,
   courses,modules,lessons}/dto.go exactly (camelCase field names).
   ========================================================= */

export interface Program {
  id: number;
  title: string;
  slug: string;
  description: string;
  ageFrom: number | null;
  ageTo: number | null;
  isActive: boolean;
}

export interface Level {
  id: number;
  programId: number;
  title: string;
  description: string;
  ageFrom: number | null;
  ageTo: number | null;
  position: number;
}

export type CourseDifficulty = "beginner" | "intermediate" | "advanced";

export interface Course {
  id: number;
  levelId: number;
  title: string;
  slug: string;
  description: string | null;
  shortDescription: string | null;
  imageUrl: string | null;
  ageFrom: number | null;
  ageTo: number | null;
  durationLessons: number | null;
  projectsCount: number | null;
  difficulty: CourseDifficulty | null;
}

export interface Module {
  id: number;
  courseId: number;
  title: string;
  description: string;
  position: number;
}

export interface Lesson {
  id: number;
  moduleId: number;
  title: string;
  slug: string | null;
  description: string | null;
  content: string | null;
  videoUrl: string | null;
  lessonType: "text" | "video" | "code" | "quiz" | "project";
  position: number;
}

export interface ModuleWithLessons extends Module {
  lessons: Lesson[];
}

export interface CourseContent {
  course: Course;
  modules: ModuleWithLessons[];
}

export interface CourseListFilter {
  ageFrom?: number;
  ageTo?: number;
  levelId?: number;
}

/* ---- Auth / users (backend/internal/{auth,users}) ---- */

export type UserRole = "student" | "teacher" | "parent" | "admin";
export type PublicRole = "student" | "teacher" | "parent";

export const PUBLIC_ROLES: PublicRole[] = ["student", "teacher", "parent"];

export interface AuthUser {
  id: number;
  email: string | null;
  phone: string | null;
  firstName: string;
  lastName: string | null;
  role: UserRole;
  isActive: boolean;
}

export interface LoginResult {
  accessToken: string;
  expiresIn: number;
  user: AuthUser;
}

export interface RefreshResult {
  accessToken: string;
  expiresIn: number;
}

export interface RegisterInput {
  firstName: string;
  lastName?: string;
  email?: string;
  phone?: string;
  password: string;
  role: PublicRole;
}

export interface LoginInput {
  email?: string;
  phone?: string;
  password: string;
}

// Where each role lands after login (spec §48).
export const ROLE_HOME: Record<UserRole, string> = {
  student: "/student",
  teacher: "/teacher",
  parent: "/parent",
  admin: "/admin",
};

/* ---- Student flow (backend/internal/{enrollments,assignments,progress,submissions}) ---- */

export type EnrollmentStatus = "active" | "completed" | "cancelled";

export interface Enrollment {
  id: number;
  studentId: number;
  courseId: number;
  status: EnrollmentStatus;
  enrolledAt: string;
  completedAt?: string | null;
}

export interface MyCourseItem {
  enrollmentId: number;
  status: EnrollmentStatus;
  enrolledAt: string;
  course: {
    id: number;
    title: string;
    slug: string;
    shortDescription: string | null;
    imageUrl: string | null;
    durationLessons: number | null;
  };
}

export interface CourseProgress {
  courseId: number;
  title: string;
  completedLessons: number;
  totalLessons: number;
  progressPercent: number;
}

export type LessonProgressStatus = "not_started" | "in_progress" | "completed";

export interface LessonProgress {
  lessonId: number;
  status: LessonProgressStatus;
  progressPercent: number;
  startedAt: string | null;
  completedAt: string | null;
}

export interface CourseProgressDetail extends CourseProgress {
  enrollmentStatus: EnrollmentStatus;
  lessons: LessonProgress[];
}

export interface CompleteLessonResult {
  lesson: LessonProgress;
  course: CourseProgress;
  enrollmentCompleted: boolean;
}

export type AssignmentType = "text" | "code" | "quiz" | "project";

export interface Assignment {
  id: number;
  lessonId: number;
  title: string;
  description: string | null;
  assignmentType: AssignmentType;
  starterCode: string | null;
  expectedOutput: string | null;
  points: number;
  position: number;
}

export type SubmissionStatus = "draft" | "submitted" | "checking" | "passed" | "failed";

export interface Submission {
  id: number;
  assignmentId: number;
  studentId: number;
  code: string | null;
  answer: string | null;
  status: SubmissionStatus;
  score: number | null;
  teacherFeedback: string | null;
  submittedAt: string | null;
  checkedAt: string | null;
  updatedAt: string;
}

export interface SubmissionInput {
  code?: string | null;
  answer?: string | null;
}

/* ---- Teacher flow (backend/internal/groups) ---- */

export interface TeacherDashboard {
  groupsCount: number;
  studentsCount: number;
  pendingSubmissions: number;
  reviewedSubmissions: number;
}

export interface TeacherCourseBrief {
  id: number;
  title: string;
  slug: string;
}

export interface TeacherStudentBrief {
  id: number;
  firstName: string;
  lastName: string | null;
}

export interface TeacherProgressBrief {
  completedLessons: number;
  totalLessons: number;
  progressPercent: number;
}

export interface TeacherGroup {
  id: number;
  title: string;
  status: "draft" | "active" | "completed" | "cancelled";
  studentCount: number;
  avgProgressPercent: number;
  startDate: string | null;
  course: TeacherCourseBrief;
}

export interface TeacherGroupDetail extends TeacherGroup {
  description: string | null;
  endDate: string | null;
  maxStudents: number | null;
}

export interface TeacherGroupStudent {
  student: TeacherStudentBrief;
  progress: TeacherProgressBrief;
  pendingSubmissions: number;
  joinedAt: string;
}

export interface TeacherLessonProgress {
  lessonId: number;
  title: string;
  status: LessonProgressStatus;
  completedAt: string | null;
}

export interface TeacherSubmissionSummary {
  submissionId: number | null;
  assignmentId: number;
  assignmentTitle: string;
  lessonTitle: string;
  points: number;
  status: SubmissionStatus | "";
  score: number | null;
  submittedAt: string | null;
}

export interface TeacherStudentDetail {
  student: TeacherStudentBrief;
  course: TeacherCourseBrief;
  progress: TeacherProgressBrief;
  lessons: TeacherLessonProgress[];
  submissions: TeacherSubmissionSummary[];
}

export interface TeacherSubmissionListItem {
  id: number;
  status: SubmissionStatus;
  submittedAt: string | null;
  student: TeacherStudentBrief;
  course: TeacherCourseBrief;
  lesson: { id: number; title: string };
  assignment: { id: number; title: string; points: number };
}

export interface TeacherSubmissionDetail {
  id: number;
  status: SubmissionStatus;
  code: string | null;
  answer: string | null;
  score: number | null;
  teacherFeedback: string | null;
  submittedAt: string | null;
  checkedAt: string | null;
  student: TeacherStudentBrief;
  group: { id: number; title: string };
  course: TeacherCourseBrief;
  module: { id: number; title: string };
  lesson: { id: number; title: string };
  assignment: {
    id: number;
    title: string;
    description: string | null;
    assignmentType: AssignmentType;
    starterCode: string | null;
    expectedOutput: string | null;
    points: number;
  };
}

export interface SubmissionReviewRequest {
  score?: number | null;
  feedback?: string;
  status: "passed" | "failed";
}

export interface ListMeta {
  page: number;
  limit: number;
  total: number;
}

export interface Paginated<T> {
  data: T[];
  meta: ListMeta;
}

export interface TeacherSubmissionQuery {
  status?: SubmissionStatus;
  groupId?: number;
  courseId?: number;
  page?: number;
  limit?: number;
}
