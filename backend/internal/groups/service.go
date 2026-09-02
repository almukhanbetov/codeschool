package groups

import (
	"context"
	"errors"

	"codeschool/backend/internal/submissions"
)

// reviewer is the slice of *submissions.Service the teacher review flow
// needs. Ownership is already checked here before any of these run.
type reviewer interface {
	TeacherStartReview(ctx context.Context, submissionID int64) (submissions.Submission, error)
	TeacherReview(ctx context.Context, submissionID int64, score *int, feedback string, status string) (submissions.Submission, error)
}

type repository interface {
	DashboardCounts(ctx context.Context, teacherID int64) (Dashboard, error)
	ListByTeacher(ctx context.Context, teacherID int64) ([]GroupListItem, error)
	GetDetailForTeacher(ctx context.Context, teacherID, groupID int64) (GroupDetail, error)
	GroupCourseID(ctx context.Context, teacherID, groupID int64) (int64, error)
	ListStudents(ctx context.Context, groupID, courseID int64) ([]GroupStudentItem, error)
	IsStudentInTeacherGroup(ctx context.Context, teacherID, groupID, studentID int64) (bool, error)
	StudentDetail(ctx context.Context, studentID, courseID int64) (StudentDetail, error)
	ListSubmissionsForTeacher(ctx context.Context, teacherID int64, f SubmissionFilter) ([]SubmissionListItem, int, error)
	GetSubmissionForTeacher(ctx context.Context, teacherID, submissionID int64) (SubmissionDetail, error)
	AddStudentTx(ctx context.Context, groupID, studentID int64) error
}

type Service struct {
	repo     repository
	reviewer reviewer
}

func NewService(repo repository, reviewer reviewer) *Service {
	return &Service{repo: repo, reviewer: reviewer}
}

const (
	defaultLimit = 20
	maxLimit     = 100
)

func (s *Service) Dashboard(ctx context.Context, teacherID int64) (Dashboard, error) {
	return s.repo.DashboardCounts(ctx, teacherID)
}

func (s *Service) ListGroups(ctx context.Context, teacherID int64) ([]GroupListItem, error) {
	items, err := s.repo.ListByTeacher(ctx, teacherID)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []GroupListItem{}
	}
	return items, nil
}

func (s *Service) GetGroup(ctx context.Context, teacherID, groupID int64) (GroupDetail, error) {
	return s.repo.GetDetailForTeacher(ctx, teacherID, groupID)
}

func (s *Service) ListStudents(ctx context.Context, teacherID, groupID int64) ([]GroupStudentItem, error) {
	courseID, err := s.repo.GroupCourseID(ctx, teacherID, groupID)
	if err != nil {
		return nil, err
	}
	items, err := s.repo.ListStudents(ctx, groupID, courseID)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []GroupStudentItem{}
	}
	return items, nil
}

func (s *Service) GetStudent(ctx context.Context, teacherID, groupID, studentID int64) (StudentDetail, error) {
	courseID, err := s.repo.GroupCourseID(ctx, teacherID, groupID)
	if err != nil {
		return StudentDetail{}, err
	}
	inGroup, err := s.repo.IsStudentInTeacherGroup(ctx, teacherID, groupID, studentID)
	if err != nil {
		return StudentDetail{}, err
	}
	if !inGroup {
		return StudentDetail{}, ErrStudentNotInGroup
	}
	return s.repo.StudentDetail(ctx, studentID, courseID)
}

func (s *Service) ListSubmissions(ctx context.Context, teacherID int64, f SubmissionFilter) ([]SubmissionListItem, ListMeta, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.Limit < 1 {
		f.Limit = defaultLimit
	}
	if f.Limit > maxLimit {
		f.Limit = maxLimit
	}

	items, total, err := s.repo.ListSubmissionsForTeacher(ctx, teacherID, f)
	if err != nil {
		return nil, ListMeta{}, err
	}
	return items, ListMeta{Page: f.Page, Limit: f.Limit, Total: total}, nil
}

func (s *Service) GetSubmission(ctx context.Context, teacherID, submissionID int64) (SubmissionDetail, error) {
	return s.repo.GetSubmissionForTeacher(ctx, teacherID, submissionID)
}

// StartReview: submitted → checking (after confirming the teacher owns it).
func (s *Service) StartReview(ctx context.Context, teacherID, submissionID int64) (SubmissionDetail, error) {
	if _, err := s.repo.GetSubmissionForTeacher(ctx, teacherID, submissionID); err != nil {
		return SubmissionDetail{}, err
	}
	if _, err := s.reviewer.TeacherStartReview(ctx, submissionID); err != nil {
		return SubmissionDetail{}, err
	}
	return s.repo.GetSubmissionForTeacher(ctx, teacherID, submissionID)
}

// Review records the verdict (after confirming ownership). Returns the
// refreshed detail.
func (s *Service) Review(ctx context.Context, teacherID, submissionID int64, req ReviewRequest) (SubmissionDetail, error) {
	if _, err := s.repo.GetSubmissionForTeacher(ctx, teacherID, submissionID); err != nil {
		return SubmissionDetail{}, err
	}
	if _, err := s.reviewer.TeacherReview(ctx, submissionID, req.Score, req.Feedback, req.Status); err != nil {
		return SubmissionDetail{}, err
	}
	return s.repo.GetSubmissionForTeacher(ctx, teacherID, submissionID)
}

// AddStudent adds a student to a group + ensures enrollment, atomically.
// No HTTP route yet — used by the dev seed / a future admin action.
func (s *Service) AddStudent(ctx context.Context, groupID, studentID int64) error {
	return s.repo.AddStudentTx(ctx, groupID, studentID)
}

// IsSubmissionError reports whether err is a submissions-package error that
// the handler should surface as-is (used to keep the mapping in one place).
func IsSubmissionError(err error) bool {
	return errors.Is(err, submissions.ErrNotReviewable) ||
		errors.Is(err, submissions.ErrInvalidReviewStatus) ||
		errors.Is(err, submissions.ErrScoreOutOfRange) ||
		errors.Is(err, submissions.ErrScoreRequired) ||
		errors.Is(err, submissions.ErrFeedbackRequired) ||
		errors.Is(err, submissions.ErrNotFound)
}
