package admin

import "time"

// ListMeta is the pagination envelope shared by the paginated admin lists.
type ListMeta struct {
	Page  int `json:"page"`
	Limit int `json:"limit"`
	Total int `json:"total"`
}

/* ================= overview ================= */

type Overview struct {
	Users              map[string]int `json:"users"` // role -> count
	ActiveUsers        int            `json:"activeUsers"`
	Programs           int            `json:"programs"`
	Courses            int            `json:"courses"`
	PublishedCourses   int            `json:"publishedCourses"`
	Groups             int            `json:"groups"`
	PendingSubmissions int            `json:"pendingSubmissions"`
	ParentLinks        int            `json:"parentLinks"`
}

/* ================= users ================= */

type UserRow struct {
	ID        int64     `json:"id"`
	Email     *string   `json:"email"`
	Phone     *string   `json:"phone"`
	FirstName string    `json:"firstName"`
	LastName  *string   `json:"lastName"`
	Role      string    `json:"role"`
	IsActive  bool      `json:"isActive"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

type UserFilter struct {
	Role   string
	Search string
	Active *bool
	Page   int
	Limit  int
}

type CreateUserRequest struct {
	Email     *string `json:"email"`
	Phone     *string `json:"phone"`
	Password  string  `json:"password"`
	FirstName string  `json:"firstName"`
	LastName  *string `json:"lastName"`
	Role      string  `json:"role"`
}

type UpdateUserRequest struct {
	Email     *string `json:"email"`
	Phone     *string `json:"phone"`
	FirstName *string `json:"firstName"`
	LastName  *string `json:"lastName"`
	Role      *string `json:"role"`
	IsActive  *bool   `json:"isActive"`
}

type SetPasswordRequest struct {
	Password string `json:"password"`
}

/* ================= parent-child links ================= */

type ParentLinkRow struct {
	ParentID   int64     `json:"parentId"`
	ParentName string    `json:"parentName"`
	ChildID    int64     `json:"childId"`
	ChildName  string    `json:"childName"`
	LinkedAt   time.Time `json:"linkedAt"`
}

type CreateParentLinkRequest struct {
	ParentID int64 `json:"parentId"`
	ChildID  int64 `json:"childId"`
}

/* ================= programs ================= */

type ProgramRow struct {
	ID          int64     `json:"id"`
	Title       string    `json:"title"`
	Slug        string    `json:"slug"`
	Description *string   `json:"description"`
	AgeFrom     *int      `json:"ageFrom"`
	AgeTo       *int      `json:"ageTo"`
	IsActive    bool      `json:"isActive"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

type CreateProgramRequest struct {
	Title       string  `json:"title"`
	Slug        string  `json:"slug"`
	Description *string `json:"description"`
	AgeFrom     *int    `json:"ageFrom"`
	AgeTo       *int    `json:"ageTo"`
	IsActive    *bool   `json:"isActive"`
}

type UpdateProgramRequest struct {
	Title       *string `json:"title"`
	Slug        *string `json:"slug"`
	Description *string `json:"description"`
	AgeFrom     *int    `json:"ageFrom"`
	AgeTo       *int    `json:"ageTo"`
	IsActive    *bool   `json:"isActive"`
}

/* ================= levels ================= */

type LevelRow struct {
	ID          int64     `json:"id"`
	ProgramID   int64     `json:"programId"`
	Title       string    `json:"title"`
	Description *string   `json:"description"`
	AgeFrom     *int      `json:"ageFrom"`
	AgeTo       *int      `json:"ageTo"`
	Position    int       `json:"position"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

type CreateLevelRequest struct {
	ProgramID   int64   `json:"programId"`
	Title       string  `json:"title"`
	Description *string `json:"description"`
	AgeFrom     *int    `json:"ageFrom"`
	AgeTo       *int    `json:"ageTo"`
	Position    *int    `json:"position"`
}

type UpdateLevelRequest struct {
	ProgramID   *int64  `json:"programId"`
	Title       *string `json:"title"`
	Description *string `json:"description"`
	AgeFrom     *int    `json:"ageFrom"`
	AgeTo       *int    `json:"ageTo"`
	Position    *int    `json:"position"`
}

/* ================= courses ================= */

type CourseRow struct {
	ID               int64     `json:"id"`
	LevelID          int64     `json:"levelId"`
	Title            string    `json:"title"`
	Slug             string    `json:"slug"`
	Description      *string   `json:"description"`
	ShortDescription *string   `json:"shortDescription"`
	ImageURL         *string   `json:"imageUrl"`
	AgeFrom          *int      `json:"ageFrom"`
	AgeTo            *int      `json:"ageTo"`
	DurationLessons  *int      `json:"durationLessons"`
	ProjectsCount    *int      `json:"projectsCount"`
	Difficulty       *string   `json:"difficulty"`
	Audience         string    `json:"audience"`
	IsPublished      bool      `json:"isPublished"`
	Position         int       `json:"position"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
}

type CreateCourseRequest struct {
	LevelID          int64   `json:"levelId"`
	Title            string  `json:"title"`
	Slug             string  `json:"slug"`
	Description      *string `json:"description"`
	ShortDescription *string `json:"shortDescription"`
	ImageURL         *string `json:"imageUrl"`
	AgeFrom          *int    `json:"ageFrom"`
	AgeTo            *int    `json:"ageTo"`
	DurationLessons  *int    `json:"durationLessons"`
	ProjectsCount    *int    `json:"projectsCount"`
	Difficulty       *string `json:"difficulty"`
	Audience         *string `json:"audience"`
	IsPublished      *bool   `json:"isPublished"`
	Position         *int    `json:"position"`
}

type UpdateCourseRequest struct {
	LevelID          *int64  `json:"levelId"`
	Title            *string `json:"title"`
	Slug             *string `json:"slug"`
	Description      *string `json:"description"`
	ShortDescription *string `json:"shortDescription"`
	ImageURL         *string `json:"imageUrl"`
	AgeFrom          *int    `json:"ageFrom"`
	AgeTo            *int    `json:"ageTo"`
	DurationLessons  *int    `json:"durationLessons"`
	ProjectsCount    *int    `json:"projectsCount"`
	Difficulty       *string `json:"difficulty"`
	Audience         *string `json:"audience"`
	IsPublished      *bool   `json:"isPublished"`
	Position         *int    `json:"position"`
}

/* ================= modules ================= */

type ModuleRow struct {
	ID          int64     `json:"id"`
	CourseID    int64     `json:"courseId"`
	Title       string    `json:"title"`
	Description *string   `json:"description"`
	Position    int       `json:"position"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

type CreateModuleRequest struct {
	CourseID    int64   `json:"courseId"`
	Title       string  `json:"title"`
	Description *string `json:"description"`
	Position    *int    `json:"position"`
}

type UpdateModuleRequest struct {
	CourseID    *int64  `json:"courseId"`
	Title       *string `json:"title"`
	Description *string `json:"description"`
	Position    *int    `json:"position"`
}

/* ================= lessons ================= */

type LessonRow struct {
	ID          int64     `json:"id"`
	ModuleID    int64     `json:"moduleId"`
	Title       string    `json:"title"`
	Slug        *string   `json:"slug"`
	Description *string   `json:"description"`
	Content     *string   `json:"content"`
	VideoURL    *string   `json:"videoUrl"`
	LessonType  string    `json:"lessonType"`
	Position    int       `json:"position"`
	IsPublished bool      `json:"isPublished"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

type CreateLessonRequest struct {
	ModuleID    int64   `json:"moduleId"`
	Title       string  `json:"title"`
	Slug        *string `json:"slug"`
	Description *string `json:"description"`
	Content     *string `json:"content"`
	VideoURL    *string `json:"videoUrl"`
	LessonType  *string `json:"lessonType"`
	Position    *int    `json:"position"`
	IsPublished *bool   `json:"isPublished"`
}

type UpdateLessonRequest struct {
	ModuleID    *int64  `json:"moduleId"`
	Title       *string `json:"title"`
	Slug        *string `json:"slug"`
	Description *string `json:"description"`
	Content     *string `json:"content"`
	VideoURL    *string `json:"videoUrl"`
	LessonType  *string `json:"lessonType"`
	Position    *int    `json:"position"`
	IsPublished *bool   `json:"isPublished"`
}

/* ================= assignments ================= */

type AssignmentRow struct {
	ID             int64     `json:"id"`
	LessonID       int64     `json:"lessonId"`
	Title          string    `json:"title"`
	Description    *string   `json:"description"`
	AssignmentType string    `json:"assignmentType"`
	StarterCode    *string   `json:"starterCode"`
	ExpectedOutput *string   `json:"expectedOutput"`
	Language       *string   `json:"language"`
	Points         int       `json:"points"`
	Position       int       `json:"position"`
	IsPublished    bool      `json:"isPublished"`
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`
}

type CreateAssignmentRequest struct {
	LessonID       int64   `json:"lessonId"`
	Title          string  `json:"title"`
	Description    *string `json:"description"`
	AssignmentType string  `json:"assignmentType"`
	StarterCode    *string `json:"starterCode"`
	ExpectedOutput *string `json:"expectedOutput"`
	Language       *string `json:"language"`
	Points         *int    `json:"points"`
	Position       *int    `json:"position"`
	IsPublished    *bool   `json:"isPublished"`
}

type UpdateAssignmentRequest struct {
	LessonID       *int64  `json:"lessonId"`
	Title          *string `json:"title"`
	Description    *string `json:"description"`
	AssignmentType *string `json:"assignmentType"`
	StarterCode    *string `json:"starterCode"`
	ExpectedOutput *string `json:"expectedOutput"`
	Language       *string `json:"language"`
	Points         *int    `json:"points"`
	Position       *int    `json:"position"`
	IsPublished    *bool   `json:"isPublished"`
}

/* ================= groups ================= */

type GroupRow struct {
	ID           int64      `json:"id"`
	CourseID     int64      `json:"courseId"`
	CourseTitle  string     `json:"courseTitle"`
	TeacherID    int64      `json:"teacherId"`
	TeacherName  string     `json:"teacherName"`
	Title        string     `json:"title"`
	Description  *string    `json:"description"`
	StartDate    *time.Time `json:"startDate"`
	EndDate      *time.Time `json:"endDate"`
	MaxStudents  *int       `json:"maxStudents"`
	Status       string     `json:"status"`
	StudentCount int        `json:"studentCount"`
	CreatedAt    time.Time  `json:"createdAt"`
	UpdatedAt    time.Time  `json:"updatedAt"`
}

type CreateGroupRequest struct {
	CourseID    int64      `json:"courseId"`
	TeacherID   int64      `json:"teacherId"`
	Title       string     `json:"title"`
	Description *string    `json:"description"`
	StartDate   *time.Time `json:"startDate"`
	EndDate     *time.Time `json:"endDate"`
	MaxStudents *int       `json:"maxStudents"`
	Status      *string    `json:"status"`
}

type UpdateGroupRequest struct {
	CourseID    *int64     `json:"courseId"`
	TeacherID   *int64     `json:"teacherId"`
	Title       *string    `json:"title"`
	Description *string    `json:"description"`
	StartDate   *time.Time `json:"startDate"`
	EndDate     *time.Time `json:"endDate"`
	MaxStudents *int       `json:"maxStudents"`
	Status      *string    `json:"status"`
}

type GroupStudentRow struct {
	StudentID int64     `json:"studentId"`
	FirstName string    `json:"firstName"`
	LastName  *string   `json:"lastName"`
	Email     *string   `json:"email"`
	JoinedAt  time.Time `json:"joinedAt"`
}

type AddGroupStudentRequest struct {
	StudentID int64 `json:"studentId"`
}

/* ================= audit ================= */

type AuditRow struct {
	ID        int64     `json:"id"`
	AdminID   int64     `json:"adminId"`
	AdminName string    `json:"adminName"`
	Action    string    `json:"action"`
	Entity    string    `json:"entity"`
	EntityID  *int64    `json:"entityId"`
	Summary   *string   `json:"summary"`
	CreatedAt time.Time `json:"createdAt"`
}
