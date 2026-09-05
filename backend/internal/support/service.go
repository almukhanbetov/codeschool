package support

import (
	"context"
	"strings"
	"unicode/utf8"
)

// Service is the student- and parent-facing support chat. Every method
// derives the caller's identity from the arguments the handler passes from
// the JWT — the request body never carries user_id / student_id / role.
type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func cleanBody(s string) (string, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return "", ErrEmptyMessage
	}
	if utf8.RuneCountInString(s) > MaxMessageLen {
		return "", ErrMessageTooLong
	}
	return s, nil
}

// CreateThread opens a thread for the caller. For a student the thread is
// about themselves; for a parent it is about a linked child (req.StudentID).
// Any course / lesson / assignment reference is validated against the
// student's own enrollments.
func (s *Service) CreateThread(ctx context.Context, callerID int64, callerRole string, req CreateThreadRequest) (ThreadDetail, error) {
	subject := strings.TrimSpace(req.Subject)
	if subject == "" {
		return ThreadDetail{}, ErrSubjectRequired
	}
	if utf8.RuneCountInString(subject) > 200 {
		subject = string([]rune(subject)[:200])
	}
	category := strings.TrimSpace(req.Category)
	if category == "" {
		category = "general"
	}
	if !validCategory(category) {
		return ThreadDetail{}, ErrInvalidCategory
	}
	firstMsg, err := cleanBody(req.Message)
	if err != nil {
		return ThreadDetail{}, err
	}

	// resolve the student the thread is about
	var studentID int64
	switch callerRole {
	case "parent":
		if req.StudentID == nil {
			return ThreadDetail{}, ErrForbiddenChild
		}
		linked, err := s.repo.IsLinkedChild(ctx, callerID, *req.StudentID)
		if err != nil {
			return ThreadDetail{}, err
		}
		if !linked {
			return ThreadDetail{}, ErrForbiddenChild
		}
		studentID = *req.StudentID
		if category == "general" {
			category = "parent_question"
		}
	default: // student
		studentID = callerID
	}

	// resolve + validate the course context (most specific ref wins)
	var courseID, lessonID, assignmentID *int64
	switch {
	case req.AssignmentID != nil:
		cid, err := s.repo.CourseIDOfAssignment(ctx, *req.AssignmentID)
		if err != nil {
			return ThreadDetail{}, err
		}
		if cid == 0 {
			return ThreadDetail{}, ErrCourseAccess
		}
		if err := s.assertAccess(ctx, studentID, cid); err != nil {
			return ThreadDetail{}, err
		}
		lid, _ := s.assignmentLesson(ctx, *req.AssignmentID)
		courseID, assignmentID = &cid, req.AssignmentID
		if lid != 0 {
			lessonID = &lid
		}
	case req.LessonID != nil:
		cid, err := s.repo.CourseIDOfLesson(ctx, *req.LessonID)
		if err != nil {
			return ThreadDetail{}, err
		}
		if cid == 0 {
			return ThreadDetail{}, ErrCourseAccess
		}
		if err := s.assertAccess(ctx, studentID, cid); err != nil {
			return ThreadDetail{}, err
		}
		courseID, lessonID = &cid, req.LessonID
	case req.CourseID != nil:
		if err := s.assertAccess(ctx, studentID, *req.CourseID); err != nil {
			return ThreadDetail{}, err
		}
		courseID = req.CourseID
	}

	cTitle, lTitle, aTitle, _ := s.repo.RefTitles(ctx, courseID, lessonID, assignmentID)
	sysBody := composeSystemBody(cTitle, lTitle, aTitle)

	t, err := s.repo.CreateThread(ctx, NewThreadInput{
		UserID:       callerID,
		StudentID:    studentID,
		CourseID:     courseID,
		LessonID:     lessonID,
		AssignmentID: assignmentID,
		Subject:      subject,
		Category:     category,
		FirstMessage: firstMsg,
	}, callerRole, sysBody)
	if err != nil {
		return ThreadDetail{}, err
	}
	return s.detail(ctx, callerID, t.ID)
}

func (s *Service) assertAccess(ctx context.Context, studentID, courseID int64) error {
	ok, err := s.repo.StudentHasCourseAccess(ctx, studentID, courseID)
	if err != nil {
		return err
	}
	if !ok {
		return ErrCourseAccess
	}
	return nil
}

func (s *Service) assignmentLesson(ctx context.Context, assignmentID int64) (int64, error) {
	var lid int64
	err := s.repo.pool.QueryRow(ctx, `SELECT lesson_id FROM assignments WHERE id = $1`, assignmentID).Scan(&lid)
	return lid, err
}

func composeSystemBody(c, l, a *string) string {
	parts := []string{}
	if c != nil {
		parts = append(parts, *c)
	}
	if l != nil {
		parts = append(parts, *l)
	}
	if a != nil {
		parts = append(parts, *a)
	}
	if len(parts) == 0 {
		return ""
	}
	return "Обращение по теме: " + strings.Join(parts, " · ")
}

func (s *Service) ListThreads(ctx context.Context, callerID int64) ([]ThreadListItem, error) {
	rows, err := s.repo.ListThreadsForUser(ctx, callerID)
	if err != nil {
		return nil, err
	}
	out := make([]ThreadListItem, 0, len(rows))
	for _, r := range rows {
		out = append(out, toListItem(r))
	}
	return out, nil
}

func (s *Service) GetThread(ctx context.Context, callerID, threadID int64) (ThreadDetail, error) {
	t, err := s.repo.ThreadByID(ctx, threadID)
	if err != nil {
		return ThreadDetail{}, err
	}
	if t.UserID != callerID {
		return ThreadDetail{}, ErrThreadNotFound
	}
	return s.detail(ctx, callerID, threadID)
}

func (s *Service) detail(ctx context.Context, callerID, threadID int64) (ThreadDetail, error) {
	tr, err := s.repo.ThreadRowForViewer(ctx, threadID, callerID, false)
	if err != nil {
		return ThreadDetail{}, err
	}
	return ThreadDetail{
		ThreadListItem: toListItem(tr),
		IsParentThread: tr.OwnerRole == "parent",
	}, nil
}

func (s *Service) ListMessages(ctx context.Context, callerID, threadID, before int64, limit int) ([]MessageDTO, error) {
	t, err := s.repo.ThreadByID(ctx, threadID)
	if err != nil {
		return nil, err
	}
	if t.UserID != callerID {
		return nil, ErrThreadNotFound
	}
	rows, err := s.repo.Messages(ctx, threadID, before, limit, false)
	if err != nil {
		return nil, err
	}
	return toMessageDTOs(rows, callerID), nil
}

func (s *Service) PostMessage(ctx context.Context, callerID int64, callerRole string, threadID int64, body string) (MessageDTO, error) {
	clean, err := cleanBody(body)
	if err != nil {
		return MessageDTO{}, err
	}
	t, err := s.repo.ThreadByID(ctx, threadID)
	if err != nil {
		return MessageDTO{}, err
	}
	if t.UserID != callerID {
		return MessageDTO{}, ErrThreadNotFound
	}
	m, err := s.repo.AddMessage(ctx, threadID, callerID, callerRole, clean, MsgText, false)
	if err != nil {
		return MessageDTO{}, err
	}
	// a user message always puts the ball in staff's court (auto-reopens a
	// closed thread — documented rule).
	_ = s.repo.SetStatus(ctx, threadID, StatusWaitingStaff)

	name, _ := s.senderName(ctx, callerID)
	return MessageDTO{
		ID: m.ID, Body: m.Body, MessageType: m.MessageType,
		SenderRole: m.SenderRole, SenderName: name, Mine: true, CreatedAt: m.CreatedAt,
	}, nil
}

func (s *Service) MarkRead(ctx context.Context, callerID, threadID int64) error {
	t, err := s.repo.ThreadByID(ctx, threadID)
	if err != nil {
		return err
	}
	if t.UserID != callerID {
		return ErrThreadNotFound
	}
	return s.repo.MarkRead(ctx, threadID, callerID, false)
}

func (s *Service) UnreadCount(ctx context.Context, callerID int64) (UnreadCountDTO, error) {
	th, ms, err := s.repo.UnreadForUser(ctx, callerID)
	if err != nil {
		return UnreadCountDTO{}, err
	}
	return UnreadCountDTO{Threads: th, Messages: ms}, nil
}

func (s *Service) senderName(ctx context.Context, userID int64) (string, error) {
	var name string
	err := s.repo.pool.QueryRow(ctx,
		`SELECT trim(first_name || ' ' || coalesce(last_name,'')) FROM users WHERE id = $1`, userID).Scan(&name)
	return name, err
}
