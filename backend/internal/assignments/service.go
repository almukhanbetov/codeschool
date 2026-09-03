package assignments

import (
	"context"
	"errors"

	"codeschool/backend/internal/lessons"
)

// lessonResolver resolves a published lesson to its owning course.
// Satisfied by *lessons.Service.
type lessonResolver interface {
	CourseIDForLesson(ctx context.Context, lessonID int64) (int64, error)
}

// enrollmentChecker reports whether a student is actively enrolled in a
// course. Satisfied by *enrollments.Service.
type enrollmentChecker interface {
	IsEnrolled(ctx context.Context, studentID, courseID int64) (bool, error)
}

// repository is the slice of *Repository the service needs.
type repository interface {
	ListPublishedByLesson(ctx context.Context, lessonID int64) ([]Assignment, error)
	PublishedIDsByLesson(ctx context.Context, lessonID int64) ([]int64, error)
	GetPublishedByID(ctx context.Context, id int64) (Assignment, int64, error)
	GetByID(ctx context.Context, id int64) (Assignment, error)
	CourseIsTeacherOnly(ctx context.Context, courseID int64) (bool, error)
}

type Service struct {
	repo    repository
	lessons lessonResolver
	enroll  enrollmentChecker
}

func NewService(repo repository, lessons lessonResolver, enroll enrollmentChecker) *Service {
	return &Service{repo: repo, lessons: lessons, enroll: enroll}
}

// ListForLesson returns a published lesson's assignments — but only if the
// student is actively enrolled in the course that owns the lesson.
func (s *Service) ListForLesson(ctx context.Context, studentID, lessonID int64) ([]Response, error) {
	courseID, err := s.lessons.CourseIDForLesson(ctx, lessonID)
	if errors.Is(err, lessons.ErrNotFound) {
		return nil, ErrLessonNotFound
	}
	if err != nil {
		return nil, err
	}

	enrolled, err := s.enroll.IsEnrolled(ctx, studentID, courseID)
	if err != nil {
		return nil, err
	}
	if !enrolled {
		// A student can never be enrolled in a Teacher Academy course, so
		// hide it as "not found" instead of confirming it exists with a
		// 403. Enrolled callers (incl. the /teacher-academy re-mount, where
		// the teacher *is* enrolled) never reach this branch.
		teacherOnly, err := s.repo.CourseIsTeacherOnly(ctx, courseID)
		if err != nil {
			return nil, err
		}
		if teacherOnly {
			return nil, ErrLessonNotFound
		}
		return nil, ErrNotEnrolled
	}

	items, err := s.repo.ListPublishedByLesson(ctx, lessonID)
	if err != nil {
		return nil, err
	}
	return toResponseList(items), nil
}

// PublishedIDsForLesson is used by the progress package's lesson-completion
// gate. No authorization here — the caller has already checked enrollment.
func (s *Service) PublishedIDsForLesson(ctx context.Context, lessonID int64) ([]int64, error) {
	return s.repo.PublishedIDsByLesson(ctx, lessonID)
}

// ResolveForSubmission returns a published assignment and its owning course
// id, for the submissions package. ErrNotFound if it is missing/unpublished.
func (s *Service) ResolveForSubmission(ctx context.Context, assignmentID int64) (Assignment, int64, error) {
	return s.repo.GetPublishedByID(ctx, assignmentID)
}

// GetAnyByID returns an assignment (published or not) — for admin/authoring
// callers (the code-runner's test editor). ErrNotFound if it does not exist.
func (s *Service) GetAnyByID(ctx context.Context, assignmentID int64) (Assignment, error) {
	return s.repo.GetByID(ctx, assignmentID)
}
