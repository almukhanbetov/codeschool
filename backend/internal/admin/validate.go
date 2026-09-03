package admin

import (
	"strconv"
	"strings"
)

func trimReq(s string) string { return strings.TrimSpace(s) }
func itoa(v int64) string     { return strconv.FormatInt(v, 10) }

// Pure decision helpers — no DB, no HTTP — so they can be unit-tested in
// isolation. The service wires repository lookups to these.

var groupStatuses = map[string]bool{"draft": true, "active": true, "completed": true, "cancelled": true}
var assignmentTypes = map[string]bool{"text": true, "code": true, "quiz": true, "project": true}
var assignmentLanguages = map[string]bool{"python": true, "javascript": true, "go": true, "plaintext": true}
var lessonTypes = map[string]bool{"text": true, "video": true, "code": true, "quiz": true, "project": true}
var courseDifficulty = map[string]bool{"beginner": true, "intermediate": true, "advanced": true}
var userRoles = map[string]bool{"student": true, "teacher": true, "parent": true, "admin": true}

const minPasswordLen = 8

// canRemoveAdminPrivilege guards the "last admin" and "self" rules for the
// user delete / deactivate / demote paths.
//
//	targetID / actorID   — the user being changed and the admin doing it
//	targetIsAdmin        — whether the target currently has role=admin & is active
//	otherActiveAdmins    — active admins OTHER than the target
//	demoteOrDeactivate   — true for delete/deactivate/role-change-away-from-admin
func canRemoveAdminPrivilege(targetID, actorID int64, targetIsActiveAdmin bool, otherActiveAdmins int) error {
	if targetID == actorID {
		return ErrSelfMutation
	}
	if targetIsActiveAdmin && otherActiveAdmins == 0 {
		return ErrLastAdmin
	}
	return nil
}

func validateNewUser(req CreateUserRequest) error {
	if len(req.Password) < minPasswordLen {
		return invalid("password must be at least 8 characters")
	}
	if strings.TrimSpace(req.FirstName) == "" {
		return invalid("first name is required")
	}
	if !userRoles[req.Role] {
		return invalid("invalid role")
	}
	if normStr(req.Email) == nil && normStr(req.Phone) == nil {
		return invalid("an email or a phone is required")
	}
	return nil
}

func validatePassword(p string) error {
	if len(p) < minPasswordLen {
		return invalid("password must be at least 8 characters")
	}
	return nil
}

// normStr trims a *string and collapses "" / whitespace to nil.
func normStr(s *string) *string {
	if s == nil {
		return nil
	}
	t := strings.TrimSpace(*s)
	if t == "" {
		return nil
	}
	return &t
}

// --- field-map builders for the dynamic UPDATE statements ---

func putStr(m map[string]any, col string, v *string) {
	if v != nil {
		m[col] = strings.TrimSpace(*v)
	}
}
func putNullableStr(m map[string]any, col string, v *string) {
	if v != nil {
		m[col] = normStr(v) // nil or trimmed value
	}
}
func putInt(m map[string]any, col string, v *int) {
	if v != nil {
		m[col] = *v
	}
}
func putInt64(m map[string]any, col string, v *int64) {
	if v != nil {
		m[col] = *v
	}
}
func putBool(m map[string]any, col string, v *bool) {
	if v != nil {
		m[col] = *v
	}
}

func (req UpdateProgramRequest) fields() map[string]any {
	m := map[string]any{}
	putStr(m, "title", req.Title)
	putStr(m, "slug", req.Slug)
	putNullableStr(m, "description", req.Description)
	putInt(m, "age_from", req.AgeFrom)
	putInt(m, "age_to", req.AgeTo)
	putBool(m, "is_active", req.IsActive)
	return m
}

func (req UpdateLevelRequest) fields() map[string]any {
	m := map[string]any{}
	putInt64(m, "program_id", req.ProgramID)
	putStr(m, "title", req.Title)
	putNullableStr(m, "description", req.Description)
	putInt(m, "age_from", req.AgeFrom)
	putInt(m, "age_to", req.AgeTo)
	putInt(m, "position", req.Position)
	return m
}

func (req UpdateCourseRequest) fields() map[string]any {
	m := map[string]any{}
	putInt64(m, "level_id", req.LevelID)
	putStr(m, "title", req.Title)
	putStr(m, "slug", req.Slug)
	putNullableStr(m, "description", req.Description)
	putNullableStr(m, "short_description", req.ShortDescription)
	putNullableStr(m, "image_url", req.ImageURL)
	putInt(m, "age_from", req.AgeFrom)
	putInt(m, "age_to", req.AgeTo)
	putInt(m, "duration_lessons", req.DurationLessons)
	putInt(m, "projects_count", req.ProjectsCount)
	putNullableStr(m, "difficulty", req.Difficulty)
	putBool(m, "is_published", req.IsPublished)
	putInt(m, "position", req.Position)
	return m
}

func (req UpdateModuleRequest) fields() map[string]any {
	m := map[string]any{}
	putInt64(m, "course_id", req.CourseID)
	putStr(m, "title", req.Title)
	putNullableStr(m, "description", req.Description)
	putInt(m, "position", req.Position)
	return m
}

func (req UpdateLessonRequest) fields() map[string]any {
	m := map[string]any{}
	putInt64(m, "module_id", req.ModuleID)
	putStr(m, "title", req.Title)
	putNullableStr(m, "slug", req.Slug)
	putNullableStr(m, "description", req.Description)
	putNullableStr(m, "content", req.Content)
	putNullableStr(m, "video_url", req.VideoURL)
	putStr(m, "lesson_type", req.LessonType)
	putInt(m, "position", req.Position)
	putBool(m, "is_published", req.IsPublished)
	return m
}

func (req UpdateAssignmentRequest) fields() map[string]any {
	m := map[string]any{}
	putInt64(m, "lesson_id", req.LessonID)
	putStr(m, "title", req.Title)
	putNullableStr(m, "description", req.Description)
	putStr(m, "assignment_type", req.AssignmentType)
	putNullableStr(m, "starter_code", req.StarterCode)
	putNullableStr(m, "expected_output", req.ExpectedOutput)
	putNullableStr(m, "language", req.Language)
	putInt(m, "points", req.Points)
	putInt(m, "position", req.Position)
	putBool(m, "is_published", req.IsPublished)
	return m
}

func (req UpdateGroupRequest) fields() map[string]any {
	m := map[string]any{}
	putInt64(m, "course_id", req.CourseID)
	putInt64(m, "teacher_id", req.TeacherID)
	putStr(m, "title", req.Title)
	putNullableStr(m, "description", req.Description)
	putInt(m, "max_students", req.MaxStudents)
	putStr(m, "status", req.Status)
	if req.StartDate != nil {
		m["start_date"] = *req.StartDate
	}
	if req.EndDate != nil {
		m["end_date"] = *req.EndDate
	}
	return m
}
