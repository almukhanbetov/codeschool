package enrollments

import (
	"context"
	"errors"

	"codeschool/backend/internal/courses"
)

// courseLookup is the slice of *courses.Repository the enrollment flows need.
// GetByID already returns only *published* courses (courses.ErrNotFound
// otherwise), which is exactly the "must exist and be published" rule.
type courseLookup interface {
	GetByID(ctx context.Context, id int64) (courses.Course, error)
	ListByIDs(ctx context.Context, ids []int64) ([]courses.Course, error)
}

// repository is the slice of *Repository the service needs.
type repository interface {
	Create(ctx context.Context, studentID, courseID int64) (Enrollment, error)
	GetActive(ctx context.Context, studentID, courseID int64) (Enrollment, error)
	HasActive(ctx context.Context, studentID, courseID int64) (bool, error)
	StatusFor(ctx context.Context, studentID, courseID int64) (string, error)
	ListByStudent(ctx context.Context, studentID int64) ([]Enrollment, error)
}

type Service struct {
	repo    repository
	courses courseLookup
}

func NewService(repo repository, courseLookup courseLookup) *Service {
	return &Service{repo: repo, courses: courseLookup}
}

// Enroll records an active enrollment for a student. The course must exist
// and be published; a second active enrollment for the same course is
// rejected with ErrAlreadyEnrolled.
func (s *Service) Enroll(ctx context.Context, studentID, courseID int64) (Response, error) {
	if _, err := s.courses.GetByID(ctx, courseID); err != nil {
		if errors.Is(err, courses.ErrNotFound) {
			return Response{}, ErrCourseNotAvailable
		}
		return Response{}, err
	}

	e, err := s.repo.Create(ctx, studentID, courseID)
	if err != nil {
		return Response{}, err // ErrAlreadyEnrolled or a real failure
	}
	return toResponse(e), nil
}

// IsEnrolled reports whether the student has course access — an active or
// completed enrollment (not cancelled). Used by the other student-flow
// packages (progress, submissions, quizzes, runs) to authorize access, so a
// student who finished a course keeps reviewing/re-running it afterwards.
func (s *Service) IsEnrolled(ctx context.Context, studentID, courseID int64) (bool, error) {
	return s.repo.HasActive(ctx, studentID, courseID)
}

// StatusFor returns the student's enrollment status for a course ("active",
// "completed", "cancelled") or "" if they have never enrolled.
func (s *Service) StatusFor(ctx context.Context, studentID, courseID int64) (string, error) {
	return s.repo.StatusFor(ctx, studentID, courseID)
}

// ListMyCourses returns the student's enrollments with a trimmed course
// payload. Enrollments whose course is no longer published are omitted.
func (s *Service) ListMyCourses(ctx context.Context, studentID int64) ([]MyCourseItem, error) {
	rows, err := s.repo.ListByStudent(ctx, studentID)
	if err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return []MyCourseItem{}, nil
	}

	ids := make([]int64, 0, len(rows))
	seen := map[int64]bool{}
	for _, e := range rows {
		if !seen[e.CourseID] {
			seen[e.CourseID] = true
			ids = append(ids, e.CourseID)
		}
	}

	courseRows, err := s.courses.ListByIDs(ctx, ids)
	if err != nil {
		return nil, err
	}
	byID := make(map[int64]courses.Course, len(courseRows))
	for _, c := range courseRows {
		byID[c.ID] = c
	}

	out := make([]MyCourseItem, 0, len(rows))
	for _, e := range rows {
		c, ok := byID[e.CourseID]
		if !ok {
			continue
		}
		out = append(out, MyCourseItem{
			EnrollmentID: e.ID,
			Status:       e.Status,
			EnrolledAt:   e.EnrolledAt,
			Course: CourseBrief{
				ID:               c.ID,
				Title:            c.Title,
				Slug:             c.Slug,
				ShortDescription: c.ShortDescription,
				ImageURL:         c.ImageURL,
				DurationLessons:  c.DurationLessons,
			},
		})
	}
	return out, nil
}
