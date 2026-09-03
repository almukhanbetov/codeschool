export type Language = "ru" | "kz" | "en";

export type Theme = "dark" | "light";


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
  resetToStarter: string;
  editorLoading: string;
  editorMobileNote: string;
  editorLanguage: string;
  editorReadOnly: string;
  run: string;
  running: string;
  runOutput: string;
  noOutput: string;
  exitCode: string;
  stdinLabel: string;
  stdinHint: string;
  sampleTests: string;
  runHistory: string;
  runnerUnavailable: string;
  runTimedOut: string;
  outputTruncated: string;
  submitForGrading: string;
  grading: string;
  gradeResult: string;
  testsPassed: string;
  hiddenTest: string;
  expectedLabel: string;
  gotLabel: string;
  autoGraded: string;
  runThrottled: string;
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
  quizResults: string;
  quizBest: string;
  quizAttempts: string;
  quizPassed: string;
  quizFailed: string;
  quizNotTaken: string;
}

export interface FamilyTranslations {
  dashTitle: string;
  myChildren: string;
  noChildren: string;
  courses: string;
  overallProgress: string;
  pendingReview: string;
  needsWork: string;
  openChild: string;
  backToChildren: string;
  backToChild: string;
  childCourses: string;
  activity: string;
  noActivity: string;
  lessonProgress: string;
  assignments: string;
  lesson: string;
  assignment: string;
  score: string;
  status: string;
  teacherFeedback: string;
  noSubmission: string;
  awaitingReview: string;
  viewCourse: string;
  readOnlyNote: string;
  loading: string;
  loadError: string;
  activityLessonCompleted: string;
  activityAssignmentSubmitted: string;
  activityAssignmentPassed: string;
  activityAssignmentFailed: string;
}

export interface AdminTranslations {
  title: string;
  navOverview: string;
  navUsers: string;
  navCatalog: string;
  navGroups: string;
  navLinks: string;
  navAudit: string;
  navAcademy: string;
  navCertificates: string;
  backToPanel: string;
  // overview
  ovUsers: string;
  ovActive: string;
  ovPrograms: string;
  ovCourses: string;
  ovPublished: string;
  ovGroups: string;
  ovPending: string;
  ovLinks: string;
  // common
  create: string;
  edit: string;
  save: string;
  saving: string;
  cancel: string;
  delete: string;
  confirmDelete: string;
  add: string;
  remove: string;
  search: string;
  all: string;
  none: string;
  loading: string;
  loadError: string;
  saved: string;
  nothing: string;
  actions: string;
  yes: string;
  no: string;
  // fields
  fTitle: string;
  fSlug: string;
  fDescription: string;
  fPosition: string;
  fAgeFrom: string;
  fAgeTo: string;
  fActive: string;
  fPublished: string;
  fFirstName: string;
  fLastName: string;
  fEmail: string;
  fPhone: string;
  fPassword: string;
  fRole: string;
  fLessonType: string;
  fContent: string;
  fVideoUrl: string;
  fAssignmentType: string;
  fLanguage: string;
  fPoints: string;
  fStarterCode: string;
  fExpectedOutput: string;
  fShortDescription: string;
  fImageUrl: string;
  fDifficulty: string;
  fDuration: string;
  fProjects: string;
  fCourse: string;
  fTeacher: string;
  fStatus: string;
  fMaxStudents: string;
  fStartDate: string;
  fEndDate: string;
  // users
  usersTitle: string;
  filterRole: string;
  filterActive: string;
  newUser: string;
  resetPassword: string;
  deactivate: string;
  activate: string;
  // catalog
  programs: string;
  levels: string;
  courses: string;
  modules: string;
  lessons: string;
  assignments: string;
  newProgram: string;
  newLevel: string;
  newCourse: string;
  newModule: string;
  newLesson: string;
  newAssignment: string;
  openCurriculum: string;
  // groups
  groupsTitle: string;
  newGroup: string;
  manageStudents: string;
  students: string;
  addStudentById: string;
  studentId: string;
  // links
  linksTitle: string;
  newLink: string;
  parent: string;
  child: string;
  parentId: string;
  childId: string;
  // audit
  auditTitle: string;
  auditWhen: string;
  auditWho: string;
  auditAction: string;
  auditEntity: string;
  auditSummary: string;
  // quiz authoring
  quizConfigure: string;
  quizEditorTitle: string;
  quizSettings: string;
  quizPassPercent: string;
  quizMaxAttempts: string;
  quizMaxAttemptsHint: string;
  quizShowCorrect: string;
  quizShowExplanations: string;
  quizQuestions: string;
  quizAddQuestion: string;
  quizAddOption: string;
  quizQuestionText: string;
  quizQuestionType: string;
  quizExplanation: string;
  quizCorrect: string;
  quizOptionText: string;
  quizNeedsFix: string;
  quizNotAQuiz: string;
  quizSingleChoice: string;
  quizMultipleChoice: string;
  quizTrueFalse: string;
  quizDeactivatedNote: string;
  // code test cases
  manageTests: string;
  testsEditorTitle: string;
  newTest: string;
  fTestName: string;
  fTestStdin: string;
  fTestExpected: string;
  fTestHidden: string;
  fTestWeight: string;
  testHiddenBadge: string;
  testsNotCode: string;
}

export interface QuizTranslations {
  startQuiz: string;
  continueQuiz: string;
  retakeQuiz: string;
  question: string;
  of: string;
  back: string;
  next: string;
  finishQuiz: string;
  submitting: string;
  loading: string;
  loadError: string;
  result: string;
  correct: string;
  incorrect: string;
  passed: string;
  failed: string;
  tryAgain: string;
  attempts: string;
  attemptsLeft: string;
  noAttemptsLeft: string;
  bestResult: string;
  yourAnswer: string;
  correctAnswer: string;
  explanation: string;
  passThreshold: string;
  chooseOne: string;
  chooseMany: string;
  reviewAnswers: string;
  notConfigured: string;
  noQuestions: string;
  backToLesson: string;
  unansweredWarning: string;
  points: string;
  attemptNumber: string;
}

export interface AcademyTranslations {
  navTitle: string;
  heroTitle: string;
  heroLead: string;
  heroCta: string;
  tracksTitle: string;
  benefitsTitle: string;
  benefitMethodology: string;
  benefitPractice: string;
  benefitAutoTests: string;
  benefitCode: string;
  benefitProgress: string;
  benefitCertificate: string;
  browseCourses: string;
  myLearning: string;
  continueLearning: string;
  startLearning: string;
  enroll: string;
  enrolling: string;
  enrolled: string;
  coursesInProgress: string;
  coursesCompleted: string;
  totalProgress: string;
  assessmentsRemaining: string;
  courseComplete: string;
  certificateReady: string;
  lessonsLabel: string;
  practicalAssignment: string;
  submitted: string;
  underReview: string;
  passed: string;
  needsWork: string;
  backToAcademy: string;
  backToDashboard: string;
  noCourses: string;
  loginAsTeacher: string;
  // admin academy
  adminTitle: string;
  adminLearners: string;
  adminReviewQueue: string;
  adminNoPending: string;
  adminReview: string;
  adminMarkPassed: string;
  adminMarkFailed: string;
  fAudience: string;
  tracks: { title: string; text: string }[];
}

export interface CertificatesTranslations {
  navTitle: string;
  myTitle: string;
  mySubtitle: string;
  empty: string;
  colCourse: string;
  colNumber: string;
  colIssued: string;
  colStatus: string;
  statusActive: string;
  statusRevoked: string;
  getCertificate: string;
  downloadPdf: string;
  issuing: string;
  downloading: string;
  verify: string;
  notEligibleYet: string;
  issueError: string;
  // public verification page
  verifyTitle: string;
  verifySubtitle: string;
  verifyValid: string;
  verifyRevoked: string;
  verifyInvalid: string;
  verifyLearner: string;
  verifyCourse: string;
  verifyNumber: string;
  verifyIssued: string;
  verifyCompleted: string;
  verifyRevokedAt: string;
  verifyLoading: string;
  // admin
  adminTitle: string;
  adminSubtitle: string;
  adminFilterAll: string;
  adminColLearner: string;
  adminColRole: string;
  adminView: string;
  adminRevoke: string;
  adminRevokeTitle: string;
  adminRevokeReason: string;
  adminRevokeReasonPlaceholder: string;
  adminRevokeConfirm: string;
  adminRevokeSubmit: string;
  adminRevokeReasonRequired: string;
  adminRevokedBadge: string;
  adminRevokedReason: string;
  adminDownloadPdf: string;
  adminBack: string;
}

export interface SitePageHero {
  eyebrow: string;
  title: string;
  lead: string;
}

export interface SiteTranslations {
  back: string;
  home: string;
  notFoundTitle: string;
  notFoundLead: string;
  viewAllCourses: string;
  coursesInDirection: string;
  noCoursesInDirection: string;
  directionTech: string;
  nav: {
    courses: string;
    programming: string;
    robotics: string;
    ai: string;
    forStudents: string;
    forParents: string;
    forTeachers: string;
    academy: string;
    howItWorks: string;
    about: string;
    certificates: string;
  };
  programming: SitePageHero;
  robotics: SitePageHero;
  ai: SitePageHero;
  forStudents: SitePageHero;
  forParents: SitePageHero;
  forTeachers: SitePageHero;
  howItWorks: SitePageHero;
  about: SitePageHero;
  certificates: SitePageHero & {
    verifyTitle: string;
    verifyPlaceholder: string;
    verifyButton: string;
  };
}

export interface Translations {
  meta: { title: string };
  header: HeaderTranslations;
  auth: AuthTranslations;
  student: StudentTranslations;
  learn: LearnTranslations;
  quiz: QuizTranslations;
  teach: TeachTranslations;
  family: FamilyTranslations;
  admin: AdminTranslations;
  academy: AcademyTranslations;
  certificates: CertificatesTranslations;
  site: SiteTranslations;
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
  key: keyof SiteTranslations["nav"];
  /** Shown in the desktop header bar (all items always appear in the mobile menu). */
  primary?: boolean;
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

export type CourseAudience = "student" | "teacher" | "both";

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
  audience: CourseAudience;
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

/* ---- Teacher Academy (backend/internal/academy) ---- */

export interface AcademyCourseCard {
  id: number;
  title: string;
  slug: string;
  shortDescription: string | null;
  description: string | null;
  imageUrl: string | null;
  difficulty: CourseDifficulty | null;
  audience: CourseAudience;
  totalLessons: number;
  enrolled: boolean;
}

export interface AcademyMyCourse {
  courseId: number;
  title: string;
  slug: string;
  shortDescription: string | null;
  imageUrl: string | null;
  difficulty: CourseDifficulty | null;
  enrollmentStatus: "active" | "completed";
  enrolledAt: string;
  completedAt: string | null;
  completedLessons: number;
  totalLessons: number;
  progressPercent: number;
  courseCompleted: boolean;
  certificateEligible: boolean;
}

export interface AcademyDashboard {
  coursesInProgress: number;
  coursesCompleted: number;
  totalCourses: number;
  overallPercent: number;
  courses: AcademyMyCourse[];
}

export interface AcademyLearnerRow {
  teacherId: number;
  name: string;
  email: string | null;
  coursesEnrolled: number;
  coursesCompleted: number;
}

export interface AcademySubmissionRow {
  id: number;
  status: SubmissionStatus;
  score: number | null;
  submittedAt: string | null;
  checkedAt: string | null;
  teacherId: number;
  teacherName: string;
  assignmentId: number;
  assignmentType: AssignmentType;
  assignmentName: string;
  points: number;
  lessonTitle: string;
  courseId: number;
  courseTitle: string;
}

export interface AcademySubmissionDetail extends AcademySubmissionRow {
  answer: string | null;
  code: string | null;
  teacherFeedback: string | null;
  assignmentDescription: string | null;
  assignmentLanguage: CodeLanguage | null;
}

export interface CourseListFilter {
  ageFrom?: number;
  ageTo?: number;
  levelId?: number;
}

/* ---- Certificates (backend/internal/certificates) ---- */

export type CertificateStatus = "active" | "revoked";

export interface Certificate {
  id: number;
  certificateNumber: string;
  verificationCode: string;
  course: { id: number; title: string };
  learnerName: string;
  issuedAt: string;
  completedAt: string;
  status: CertificateStatus;
  verifyUrl: string;
}

export interface CertificateVerification {
  valid: boolean;
  status: CertificateStatus;
  certificateNumber: string;
  learnerName: string;
  courseTitle: string;
  issuedAt: string;
  completedAt: string;
  revokedAt?: string | null;
}

export interface AdminCertificateRow {
  id: number;
  certificateNumber: string;
  verificationCode: string;
  userId: number;
  learnerName: string;
  learnerRole: UserRole;
  courseId: number;
  courseTitle: string;
  issuedAt: string;
  completedAt: string;
  status: CertificateStatus;
  revokedAt?: string | null;
  revokedBy?: number | null;
  revokeReason?: string | null;
}

export interface AdminCertificateList {
  items: AdminCertificateRow[];
  total: number;
  page: number;
  limit: number;
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

/** Monaco language mode for a code assignment (backend `assignments.language`). */
export type CodeLanguage = "python" | "javascript" | "go" | "plaintext";

export interface Assignment {
  id: number;
  lessonId: number;
  title: string;
  description: string | null;
  assignmentType: AssignmentType;
  starterCode: string | null;
  expectedOutput: string | null;
  language: CodeLanguage | null;
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

export interface TeacherQuizResult {
  assignmentId: number;
  title: string;
  lessonTitle: string;
  attempts: number;
  bestPercent: number | null;
  passed: boolean;
}

export interface TeacherStudentDetail {
  student: TeacherStudentBrief;
  course: TeacherCourseBrief;
  progress: TeacherProgressBrief;
  lessons: TeacherLessonProgress[];
  submissions: TeacherSubmissionSummary[];
  quizResults: TeacherQuizResult[];
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
    language: CodeLanguage | null;
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

/* ---- Parent flow (backend/internal/parents) — read-only ---- */

export interface ChildBrief {
  id: number;
  firstName: string;
  lastName: string | null;
}

export interface ChildCourseBrief {
  id: number;
  title: string;
  slug: string;
}

export interface ChildProgressBrief {
  completedLessons: number;
  totalLessons: number;
  progressPercent: number;
}

export interface ParentChildListItem {
  child: ChildBrief;
  coursesCount: number;
  overallProgressPercent: number;
  pendingReview: number;
  needsWork: number;
}

export interface ParentChildCourseProgress {
  course: ChildCourseBrief;
  enrollmentStatus: "active" | "completed";
  progress: ChildProgressBrief;
}

export interface ParentChildOverview {
  child: ChildBrief;
  courses: ParentChildCourseProgress[];
}

export interface ParentAssignmentFeedback {
  assignmentId: number;
  title: string;
  lessonTitle: string;
  assignmentType: AssignmentType;
  points: number;
  status: SubmissionStatus | "";
  score: number | null;
  teacherFeedback: string | null;
  submittedAt: string | null;
  checkedAt: string | null;
  quizAttempts: number | null;
  quizBestPercent: number | null;
  quizPassed: boolean | null;
}

export interface ParentChildCourseDetail {
  child: ChildBrief;
  course: ChildCourseBrief;
  progress: ChildProgressBrief;
  lessons: TeacherLessonProgress[];
  assignments: ParentAssignmentFeedback[];
}

export type ParentActivityType =
  | "lesson_completed"
  | "assignment_submitted"
  | "assignment_passed"
  | "assignment_failed";

export interface ParentActivityItem {
  type: ParentActivityType;
  at: string;
  courseTitle: string;
  lessonTitle: string;
  assignmentTitle: string | null;
  score: number | null;
  points: number | null;
}

export interface ParentActivitySummary {
  child: ChildBrief;
  items: ParentActivityItem[];
}

/* ---- Admin panel (backend/internal/admin) ---- */

export interface AdminOverview {
  users: Record<string, number>;
  activeUsers: number;
  programs: number;
  courses: number;
  publishedCourses: number;
  groups: number;
  pendingSubmissions: number;
  parentLinks: number;
}

export interface AdminUser {
  id: number;
  email: string | null;
  phone: string | null;
  firstName: string;
  lastName: string | null;
  role: UserRole;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AdminParentLink {
  parentId: number;
  parentName: string;
  childId: number;
  childName: string;
  linkedAt: string;
}

export interface AdminProgram {
  id: number;
  title: string;
  slug: string;
  description: string | null;
  ageFrom: number | null;
  ageTo: number | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AdminLevel {
  id: number;
  programId: number;
  title: string;
  description: string | null;
  ageFrom: number | null;
  ageTo: number | null;
  position: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminCourse {
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
  difficulty: string | null;
  audience: CourseAudience;
  isPublished: boolean;
  position: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminModule {
  id: number;
  courseId: number;
  title: string;
  description: string | null;
  position: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminLesson {
  id: number;
  moduleId: number;
  title: string;
  slug: string | null;
  description: string | null;
  content: string | null;
  videoUrl: string | null;
  lessonType: string;
  position: number;
  isPublished: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AdminAssignment {
  id: number;
  lessonId: number;
  title: string;
  description: string | null;
  assignmentType: AssignmentType;
  starterCode: string | null;
  expectedOutput: string | null;
  language: CodeLanguage | null;
  points: number;
  position: number;
  isPublished: boolean;
  createdAt: string;
  updatedAt: string;
}

/* ---- Code runner (backend/internal/runs) ---- */

export type CodeRunStatus = "ok" | "error" | "timeout" | "runner_error";

export interface CodeRunResult {
  runId: number;
  language: string;
  status: CodeRunStatus;
  stdout: string;
  stderr: string;
  exitCode: number | null;
  timedOut: boolean;
  truncated: boolean;
  durationMs: number | null;
  createdAt: string;
}

export interface CodeRunHistoryItem {
  runId: number;
  kind: "run" | "grade";
  status: CodeRunStatus;
  exitCode: number | null;
  durationMs: number | null;
  stdout: string;
  stderr: string;
  createdAt: string;
}

export interface VisibleTest {
  id: number;
  name: string;
  stdin: string;
  expectedStdout: string;
}

export interface AssignmentTestsResponse {
  hasTests: boolean;
  total: number;
  visible: VisibleTest[];
}

export interface CodeTestOutcome {
  testId: number;
  name: string;
  hidden: boolean;
  passed: boolean;
  timedOut: boolean;
  stdin?: string;
  expected?: string;
  got?: string;
  stderr?: string;
}

export interface CodeGradeResult {
  submissionId: number;
  status: "passed" | "failed";
  passed: boolean;
  score: number | null;
  points: number;
  percent: number;
  testsPassed: number;
  testsTotal: number;
  feedback: string;
  outcomes: CodeTestOutcome[];
}

export interface AdminAssignmentTest {
  id: number;
  assignmentId: number;
  name: string;
  stdin: string;
  expectedStdout: string;
  isHidden: boolean;
  weight: number;
  position: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminGroup {
  id: number;
  courseId: number;
  courseTitle: string;
  teacherId: number;
  teacherName: string;
  title: string;
  description: string | null;
  startDate: string | null;
  endDate: string | null;
  maxStudents: number | null;
  status: "draft" | "active" | "completed" | "cancelled";
  studentCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminGroupStudent {
  studentId: number;
  firstName: string;
  lastName: string | null;
  email: string | null;
  joinedAt: string;
}

export interface AdminAuditRow {
  id: number;
  adminId: number;
  adminName: string;
  action: "create" | "update" | "delete";
  entity: string;
  entityId: number | null;
  summary: string | null;
  createdAt: string;
}

/* ---- Quiz engine (backend/internal/quizzes) ---- */

export type QuizQuestionType = "single_choice" | "multiple_choice" | "true_false";
export type QuizAttemptStatus = "in_progress" | "submitted";

export interface QuizStudentOption {
  id: number;
  optionText: string;
  position: number;
}

export interface QuizStudentQuestion {
  id: number;
  questionText: string;
  questionType: QuizQuestionType;
  points: number;
  position: number;
  options: QuizStudentOption[];
}

export interface QuizStudentQuiz {
  assignmentId: number;
  title: string;
  passPercent: number;
  questions: QuizStudentQuestion[];
}

export interface QuizAttemptBrief {
  id: number;
  status: QuizAttemptStatus;
  startedAt: string;
  submittedAt: string | null;
}

export interface QuizStartResponse {
  attempt: QuizAttemptBrief;
  quiz: QuizStudentQuiz;
}

export interface QuizSubmitAnswer {
  questionId: number;
  selectedOptionIds: number[];
}

export interface QuizResultOption {
  id: number;
  optionText: string;
  position: number;
  selected: boolean;
  isCorrect: boolean | null;
}

export interface QuizResultQuestion {
  questionId: number;
  questionText: string;
  questionType: QuizQuestionType;
  points: number;
  pointsAwarded: number;
  isCorrect: boolean;
  explanation: string | null;
  options: QuizResultOption[];
}

export interface QuizResult {
  attemptId: number;
  assignmentId: number;
  status: QuizAttemptStatus;
  score: number;
  maxScore: number;
  percent: number;
  passed: boolean;
  passPercent: number;
  submittedAt: string | null;
  showCorrectAnswers: boolean;
  questions: QuizResultQuestion[];
}

export interface QuizAttemptDetail {
  attempt: QuizAttemptBrief;
  quiz: QuizStudentQuiz | null;
  result: QuizResult | null;
}

export interface QuizHistoryItem {
  attemptId: number;
  attemptNumber: number;
  status: QuizAttemptStatus;
  score: number | null;
  maxScore: number | null;
  percent: number | null;
  passed: boolean | null;
  startedAt: string;
  submittedAt: string | null;
}

export interface QuizAttemptHistory {
  assignmentId: number;
  title: string;
  passPercent: number;
  maxAttempts: number | null;
  attemptsUsed: number;
  attemptsLeft: number | null;
  canStart: boolean;
  passed: boolean;
  bestScore: number | null;
  bestMaxScore: number | null;
  bestPercent: number | null;
  inProgressId: number | null;
  attempts: QuizHistoryItem[];
}

/* admin authoring */

export interface AdminQuizOption {
  id: number;
  optionText: string;
  isCorrect: boolean;
  position: number;
  isActive: boolean;
}

export interface AdminQuizQuestion {
  id: number;
  questionText: string;
  questionType: QuizQuestionType;
  points: number;
  position: number;
  explanation: string | null;
  isActive: boolean;
  wellFormed: boolean;
  options: AdminQuizOption[];
}

export interface AdminQuizSettings {
  passPercent: number;
  maxAttempts: number | null;
  showCorrectAnswers: boolean;
  showExplanations: boolean;
}

export interface AdminQuiz {
  assignmentId: number;
  assignmentType: AssignmentType;
  title: string;
  settings: AdminQuizSettings;
  questions: AdminQuizQuestion[];
}

export interface QuizDeleteResult {
  deleted: boolean;
  deactivated: boolean;
}
