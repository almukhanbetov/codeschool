package admin

import (
	"context"
	"errors"
	"log"

	"golang.org/x/crypto/bcrypt"

	"codeschool/backend/internal/groups"
)

// groupMembership is the slice of *groups.Repository the admin needs to add a
// student to a group atomically (membership + guaranteed enrollment).
type groupMembership interface {
	AddStudentTx(ctx context.Context, groupID, studentID int64) error
}

type Service struct {
	repo   *Repository
	groups groupMembership
}

func NewService(repo *Repository, groupMembership groupMembership) *Service {
	return &Service{repo: repo, groups: groupMembership}
}

const (
	defaultLimit = 25
	maxLimit     = 100
)

func clampPage(page, limit int) (int, int) {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = defaultLimit
	}
	if limit > maxLimit {
		limit = maxLimit
	}
	return page, limit
}

func hashPassword(plain string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	return string(b), err
}

/* ================= overview / audit ================= */

func (s *Service) Overview(ctx context.Context) (Overview, error) {
	return s.repo.Overview(ctx)
}

func (s *Service) ListAudit(ctx context.Context, page, limit int) ([]AuditRow, ListMeta, error) {
	page, limit = clampPage(page, limit)
	rows, total, err := s.repo.ListAudit(ctx, page, limit)
	if err != nil {
		return nil, ListMeta{}, err
	}
	return rows, ListMeta{Page: page, Limit: limit, Total: total}, nil
}

// audit records an admin action; a failure to write the log never fails the
// operation it describes.
func (s *Service) audit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) {
	if err := s.repo.WriteAudit(ctx, adminID, action, entity, entityID, summary); err != nil {
		log.Printf("admin: audit write failed (%s %s): %v", action, entity, err)
	}
}

/* ================= users ================= */

func (s *Service) ListUsers(ctx context.Context, f UserFilter) ([]UserRow, ListMeta, error) {
	f.Page, f.Limit = clampPage(f.Page, f.Limit)
	if f.Role != "" && !userRoles[f.Role] {
		return nil, ListMeta{}, invalid("invalid role filter")
	}
	rows, total, err := s.repo.ListUsers(ctx, f)
	if err != nil {
		return nil, ListMeta{}, err
	}
	return rows, ListMeta{Page: f.Page, Limit: f.Limit, Total: total}, nil
}

func (s *Service) GetUser(ctx context.Context, id int64) (UserRow, error) {
	return s.repo.GetUser(ctx, id)
}

func (s *Service) CreateUser(ctx context.Context, adminID int64, req CreateUserRequest) (UserRow, error) {
	if err := validateNewUser(req); err != nil {
		return UserRow{}, err
	}
	hash, err := hashPassword(req.Password)
	if err != nil {
		return UserRow{}, err
	}
	u, err := s.repo.CreateUser(ctx, normStr(req.Email), normStr(req.Phone), hash,
		trimReq(req.FirstName), normStr(req.LastName), req.Role)
	if err != nil {
		return UserRow{}, err
	}
	s.audit(ctx, adminID, "create", "user", &u.ID, u.Role+" "+u.FirstName)
	return u, nil
}

func (s *Service) UpdateUser(ctx context.Context, adminID, id int64, req UpdateUserRequest) (UserRow, error) {
	cur, err := s.repo.GetUser(ctx, id)
	if err != nil {
		return UserRow{}, err
	}
	if req.Role != nil && !userRoles[*req.Role] {
		return UserRow{}, invalid("invalid role")
	}

	demotingAdmin := (req.IsActive != nil && !*req.IsActive && cur.Role == "admin" && cur.IsActive) ||
		(req.Role != nil && *req.Role != "admin" && cur.Role == "admin")
	if demotingAdmin {
		others, err := s.repo.CountActiveAdminsExcluding(ctx, id)
		if err != nil {
			return UserRow{}, err
		}
		if err := canRemoveAdminPrivilege(id, adminID, cur.Role == "admin" && cur.IsActive, others); err != nil {
			return UserRow{}, err
		}
	}
	if req.IsActive != nil && !*req.IsActive && id == adminID {
		return UserRow{}, ErrSelfMutation
	}
	if req.FirstName != nil && trimReq(*req.FirstName) == "" {
		return UserRow{}, invalid("first name cannot be empty")
	}

	fields := map[string]any{}
	putNullableStr(fields, "email", req.Email)
	putNullableStr(fields, "phone", req.Phone)
	putStr(fields, "first_name", req.FirstName)
	putNullableStr(fields, "last_name", req.LastName)
	putStr(fields, "role", req.Role)
	putBool(fields, "is_active", req.IsActive)

	u, err := s.repo.UpdateUser(ctx, id, fields)
	if err != nil {
		return UserRow{}, err
	}
	s.audit(ctx, adminID, "update", "user", &u.ID, u.FirstName)
	return u, nil
}

func (s *Service) SetPassword(ctx context.Context, adminID, id int64, req SetPasswordRequest) error {
	if err := validatePassword(req.Password); err != nil {
		return err
	}
	hash, err := hashPassword(req.Password)
	if err != nil {
		return err
	}
	if err := s.repo.SetUserPassword(ctx, id, hash); err != nil {
		return err
	}
	s.audit(ctx, adminID, "update", "user", &id, "password reset")
	return nil
}

func (s *Service) DeleteUser(ctx context.Context, adminID, id int64) error {
	cur, err := s.repo.GetUser(ctx, id)
	if err != nil {
		return err
	}
	others, err := s.repo.CountActiveAdminsExcluding(ctx, id)
	if err != nil {
		return err
	}
	if err := canRemoveAdminPrivilege(id, adminID, cur.Role == "admin" && cur.IsActive, others); err != nil {
		return err
	}
	if err := s.repo.DeleteUser(ctx, id); err != nil {
		return err
	}
	s.audit(ctx, adminID, "delete", "user", &id, cur.Role+" "+cur.FirstName)
	return nil
}

/* ================= parent-child links ================= */

func (s *Service) ListParentLinks(ctx context.Context, parentID, childID *int64) ([]ParentLinkRow, error) {
	return s.repo.ListParentLinks(ctx, parentID, childID)
}

func (s *Service) CreateParentLink(ctx context.Context, adminID int64, req CreateParentLinkRequest) error {
	if req.ParentID <= 0 || req.ChildID <= 0 {
		return invalid("parentId and childId are required")
	}
	if req.ParentID == req.ChildID {
		return invalid("a user cannot be linked to themselves")
	}
	prole, err := s.repo.RoleOf(ctx, req.ParentID)
	if err != nil {
		return err
	}
	if prole != "parent" {
		return ErrRoleMismatch
	}
	crole, err := s.repo.RoleOf(ctx, req.ChildID)
	if err != nil {
		return err
	}
	if crole != "student" {
		return ErrRoleMismatch
	}
	if err := s.repo.CreateParentLink(ctx, req.ParentID, req.ChildID); err != nil {
		return err
	}
	pid := req.ParentID
	s.audit(ctx, adminID, "create", "parent_link", &pid, "child "+itoa(req.ChildID))
	return nil
}

func (s *Service) DeleteParentLink(ctx context.Context, adminID, parentID, childID int64) error {
	if err := s.repo.DeleteParentLink(ctx, parentID, childID); err != nil {
		return err
	}
	p := parentID
	s.audit(ctx, adminID, "delete", "parent_link", &p, "child "+itoa(childID))
	return nil
}

/* ================= catalog ================= */

func (s *Service) ListPrograms(ctx context.Context) ([]ProgramRow, error) {
	return s.repo.ListPrograms(ctx)
}
func (s *Service) GetProgram(ctx context.Context, id int64) (ProgramRow, error) {
	return s.repo.GetProgram(ctx, id)
}
func (s *Service) CreateProgram(ctx context.Context, adminID int64, req CreateProgramRequest) (ProgramRow, error) {
	if trimReq(req.Title) == "" || trimReq(req.Slug) == "" {
		return ProgramRow{}, invalid("title and slug are required")
	}
	req.Title, req.Slug = trimReq(req.Title), trimReq(req.Slug)
	p, err := s.repo.CreateProgram(ctx, req)
	if err != nil {
		return ProgramRow{}, err
	}
	s.audit(ctx, adminID, "create", "program", &p.ID, p.Title)
	return p, nil
}
func (s *Service) UpdateProgram(ctx context.Context, adminID, id int64, req UpdateProgramRequest) (ProgramRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return ProgramRow{}, invalid("title cannot be empty")
	}
	p, err := s.repo.UpdateProgram(ctx, id, req.fields())
	if err != nil {
		return ProgramRow{}, err
	}
	s.audit(ctx, adminID, "update", "program", &p.ID, p.Title)
	return p, nil
}
func (s *Service) DeleteProgram(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "program", id, s.repo.DeleteProgram)
}

func (s *Service) ListLevels(ctx context.Context, programID *int64) ([]LevelRow, error) {
	return s.repo.ListLevels(ctx, programID)
}
func (s *Service) GetLevel(ctx context.Context, id int64) (LevelRow, error) {
	return s.repo.GetLevel(ctx, id)
}
func (s *Service) CreateLevel(ctx context.Context, adminID int64, req CreateLevelRequest) (LevelRow, error) {
	if req.ProgramID <= 0 || trimReq(req.Title) == "" {
		return LevelRow{}, invalid("programId and title are required")
	}
	req.Title = trimReq(req.Title)
	l, err := s.repo.CreateLevel(ctx, req)
	if err != nil {
		return LevelRow{}, err
	}
	s.audit(ctx, adminID, "create", "level", &l.ID, l.Title)
	return l, nil
}
func (s *Service) UpdateLevel(ctx context.Context, adminID, id int64, req UpdateLevelRequest) (LevelRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return LevelRow{}, invalid("title cannot be empty")
	}
	l, err := s.repo.UpdateLevel(ctx, id, req.fields())
	if err != nil {
		return LevelRow{}, err
	}
	s.audit(ctx, adminID, "update", "level", &l.ID, l.Title)
	return l, nil
}
func (s *Service) DeleteLevel(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "level", id, s.repo.DeleteLevel)
}

func (s *Service) ListCourses(ctx context.Context, levelID *int64, published *bool) ([]CourseRow, error) {
	return s.repo.ListCourses(ctx, levelID, published)
}
func (s *Service) GetCourse(ctx context.Context, id int64) (CourseRow, error) {
	return s.repo.GetCourse(ctx, id)
}
func (s *Service) CreateCourse(ctx context.Context, adminID int64, req CreateCourseRequest) (CourseRow, error) {
	if req.LevelID <= 0 || trimReq(req.Title) == "" || trimReq(req.Slug) == "" {
		return CourseRow{}, invalid("levelId, title and slug are required")
	}
	if d := normStr(req.Difficulty); d != nil && !courseDifficulty[*d] {
		return CourseRow{}, invalid("invalid difficulty")
	}
	req.Title, req.Slug = trimReq(req.Title), trimReq(req.Slug)
	c, err := s.repo.CreateCourse(ctx, req)
	if err != nil {
		return CourseRow{}, err
	}
	s.audit(ctx, adminID, "create", "course", &c.ID, c.Title)
	return c, nil
}
func (s *Service) UpdateCourse(ctx context.Context, adminID, id int64, req UpdateCourseRequest) (CourseRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return CourseRow{}, invalid("title cannot be empty")
	}
	if d := normStr(req.Difficulty); req.Difficulty != nil && d != nil && !courseDifficulty[*d] {
		return CourseRow{}, invalid("invalid difficulty")
	}
	c, err := s.repo.UpdateCourse(ctx, id, req.fields())
	if err != nil {
		return CourseRow{}, err
	}
	s.audit(ctx, adminID, "update", "course", &c.ID, c.Title)
	return c, nil
}
func (s *Service) DeleteCourse(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "course", id, s.repo.DeleteCourse)
}

func (s *Service) ListModules(ctx context.Context, courseID *int64) ([]ModuleRow, error) {
	return s.repo.ListModules(ctx, courseID)
}
func (s *Service) GetModule(ctx context.Context, id int64) (ModuleRow, error) {
	return s.repo.GetModule(ctx, id)
}
func (s *Service) CreateModule(ctx context.Context, adminID int64, req CreateModuleRequest) (ModuleRow, error) {
	if req.CourseID <= 0 || trimReq(req.Title) == "" {
		return ModuleRow{}, invalid("courseId and title are required")
	}
	req.Title = trimReq(req.Title)
	m, err := s.repo.CreateModule(ctx, req)
	if err != nil {
		return ModuleRow{}, err
	}
	s.audit(ctx, adminID, "create", "module", &m.ID, m.Title)
	return m, nil
}
func (s *Service) UpdateModule(ctx context.Context, adminID, id int64, req UpdateModuleRequest) (ModuleRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return ModuleRow{}, invalid("title cannot be empty")
	}
	m, err := s.repo.UpdateModule(ctx, id, req.fields())
	if err != nil {
		return ModuleRow{}, err
	}
	s.audit(ctx, adminID, "update", "module", &m.ID, m.Title)
	return m, nil
}
func (s *Service) DeleteModule(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "module", id, s.repo.DeleteModule)
}

func (s *Service) ListLessons(ctx context.Context, moduleID *int64) ([]LessonRow, error) {
	return s.repo.ListLessons(ctx, moduleID)
}
func (s *Service) GetLesson(ctx context.Context, id int64) (LessonRow, error) {
	return s.repo.GetLesson(ctx, id)
}
func (s *Service) CreateLesson(ctx context.Context, adminID int64, req CreateLessonRequest) (LessonRow, error) {
	if req.ModuleID <= 0 || trimReq(req.Title) == "" {
		return LessonRow{}, invalid("moduleId and title are required")
	}
	if lt := normStr(req.LessonType); lt != nil && !lessonTypes[*lt] {
		return LessonRow{}, invalid("invalid lessonType")
	}
	req.Title = trimReq(req.Title)
	l, err := s.repo.CreateLesson(ctx, req)
	if err != nil {
		return LessonRow{}, err
	}
	s.audit(ctx, adminID, "create", "lesson", &l.ID, l.Title)
	return l, nil
}
func (s *Service) UpdateLesson(ctx context.Context, adminID, id int64, req UpdateLessonRequest) (LessonRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return LessonRow{}, invalid("title cannot be empty")
	}
	if req.LessonType != nil {
		if lt := normStr(req.LessonType); lt == nil || !lessonTypes[*lt] {
			return LessonRow{}, invalid("invalid lessonType")
		}
	}
	l, err := s.repo.UpdateLesson(ctx, id, req.fields())
	if err != nil {
		return LessonRow{}, err
	}
	s.audit(ctx, adminID, "update", "lesson", &l.ID, l.Title)
	return l, nil
}
func (s *Service) DeleteLesson(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "lesson", id, s.repo.DeleteLesson)
}

func (s *Service) ListAssignments(ctx context.Context, lessonID *int64) ([]AssignmentRow, error) {
	return s.repo.ListAssignments(ctx, lessonID)
}
func (s *Service) GetAssignment(ctx context.Context, id int64) (AssignmentRow, error) {
	return s.repo.GetAssignment(ctx, id)
}
func (s *Service) CreateAssignment(ctx context.Context, adminID int64, req CreateAssignmentRequest) (AssignmentRow, error) {
	if req.LessonID <= 0 || trimReq(req.Title) == "" {
		return AssignmentRow{}, invalid("lessonId and title are required")
	}
	if !assignmentTypes[req.AssignmentType] {
		return AssignmentRow{}, invalid("invalid assignmentType")
	}
	if l := normStr(req.Language); l != nil && !assignmentLanguages[*l] {
		return AssignmentRow{}, invalid("invalid language")
	}
	req.Language = normStr(req.Language)
	if req.Points != nil && *req.Points < 0 {
		return AssignmentRow{}, invalid("points must be >= 0")
	}
	req.Title = trimReq(req.Title)
	a, err := s.repo.CreateAssignment(ctx, req)
	if err != nil {
		return AssignmentRow{}, err
	}
	s.audit(ctx, adminID, "create", "assignment", &a.ID, a.Title)
	return a, nil
}
func (s *Service) UpdateAssignment(ctx context.Context, adminID, id int64, req UpdateAssignmentRequest) (AssignmentRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return AssignmentRow{}, invalid("title cannot be empty")
	}
	if req.AssignmentType != nil && !assignmentTypes[trimReq(*req.AssignmentType)] {
		return AssignmentRow{}, invalid("invalid assignmentType")
	}
	if req.Language != nil {
		if l := normStr(req.Language); l != nil && !assignmentLanguages[*l] {
			return AssignmentRow{}, invalid("invalid language")
		}
	}
	if req.Points != nil && *req.Points < 0 {
		return AssignmentRow{}, invalid("points must be >= 0")
	}
	a, err := s.repo.UpdateAssignment(ctx, id, req.fields())
	if err != nil {
		return AssignmentRow{}, err
	}
	s.audit(ctx, adminID, "update", "assignment", &a.ID, a.Title)
	return a, nil
}
func (s *Service) DeleteAssignment(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "assignment", id, s.repo.DeleteAssignment)
}

/* ================= groups ================= */

func (s *Service) ListGroups(ctx context.Context, teacherID, courseID *int64, status string) ([]GroupRow, error) {
	if status != "" && !groupStatuses[status] {
		return nil, invalid("invalid status filter")
	}
	return s.repo.ListGroups(ctx, teacherID, courseID, status)
}
func (s *Service) GetGroup(ctx context.Context, id int64) (GroupRow, error) {
	return s.repo.GetGroup(ctx, id)
}
func (s *Service) CreateGroup(ctx context.Context, adminID int64, req CreateGroupRequest) (GroupRow, error) {
	if req.CourseID <= 0 || req.TeacherID <= 0 || trimReq(req.Title) == "" {
		return GroupRow{}, invalid("courseId, teacherId and title are required")
	}
	if st := normStr(req.Status); st != nil && !groupStatuses[*st] {
		return GroupRow{}, invalid("invalid status")
	}
	if err := s.requireTeacher(ctx, req.TeacherID); err != nil {
		return GroupRow{}, err
	}
	req.Title = trimReq(req.Title)
	id, err := s.repo.CreateGroup(ctx, req)
	if err != nil {
		return GroupRow{}, err
	}
	g, err := s.repo.GetGroup(ctx, id)
	if err != nil {
		return GroupRow{}, err
	}
	s.audit(ctx, adminID, "create", "group", &g.ID, g.Title)
	return g, nil
}
func (s *Service) UpdateGroup(ctx context.Context, adminID, id int64, req UpdateGroupRequest) (GroupRow, error) {
	if req.Title != nil && trimReq(*req.Title) == "" {
		return GroupRow{}, invalid("title cannot be empty")
	}
	if req.Status != nil && !groupStatuses[trimReq(*req.Status)] {
		return GroupRow{}, invalid("invalid status")
	}
	if req.TeacherID != nil {
		if err := s.requireTeacher(ctx, *req.TeacherID); err != nil {
			return GroupRow{}, err
		}
	}
	if err := s.repo.UpdateGroup(ctx, id, req.fields()); err != nil {
		return GroupRow{}, err
	}
	g, err := s.repo.GetGroup(ctx, id)
	if err != nil {
		return GroupRow{}, err
	}
	s.audit(ctx, adminID, "update", "group", &g.ID, g.Title)
	return g, nil
}
func (s *Service) DeleteGroup(ctx context.Context, adminID, id int64) error {
	return s.del(ctx, adminID, "group", id, s.repo.DeleteGroup)
}
func (s *Service) ListGroupStudents(ctx context.Context, groupID int64) ([]GroupStudentRow, error) {
	if ok, err := s.repo.GroupExists(ctx, groupID); err != nil {
		return nil, err
	} else if !ok {
		return nil, ErrNotFound
	}
	return s.repo.ListGroupStudents(ctx, groupID)
}
func (s *Service) AddGroupStudent(ctx context.Context, adminID, groupID, studentID int64) error {
	if studentID <= 0 {
		return invalid("studentId is required")
	}
	err := s.groups.AddStudentTx(ctx, groupID, studentID)
	switch {
	case errors.Is(err, groups.ErrGroupNotFound):
		return ErrNotFound
	case errors.Is(err, groups.ErrAlreadyInGroup):
		return ErrConflict
	case errors.Is(err, groups.ErrGroupFull):
		return invalid("the group is full")
	case errors.Is(err, groups.ErrNotAStudent):
		return ErrRoleMismatch
	case err != nil:
		return err
	}
	g := groupID
	s.audit(ctx, adminID, "create", "group_student", &g, "student "+itoa(studentID))
	return nil
}
func (s *Service) RemoveGroupStudent(ctx context.Context, adminID, groupID, studentID int64) error {
	if err := s.repo.RemoveGroupStudent(ctx, groupID, studentID); err != nil {
		return err
	}
	g := groupID
	s.audit(ctx, adminID, "delete", "group_student", &g, "student "+itoa(studentID))
	return nil
}

/* ================= helpers ================= */

func (s *Service) requireTeacher(ctx context.Context, id int64) error {
	role, err := s.repo.RoleOf(ctx, id)
	if err != nil {
		return err
	}
	if role != "teacher" {
		return ErrRoleMismatch
	}
	return nil
}

// del runs a delete + audit for the simple catalog entities.
func (s *Service) del(ctx context.Context, adminID int64, entity string, id int64, fn func(context.Context, int64) error) error {
	if err := fn(ctx, id); err != nil {
		return err
	}
	eid := id
	s.audit(ctx, adminID, "delete", entity, &eid, "")
	return nil
}
