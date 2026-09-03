package academy

import (
	"context"
	"errors"
	"fmt"
	"log"
	"strconv"

	"codeschool/backend/internal/courses"
	"codeschool/backend/internal/enrollments"
	"codeschool/backend/internal/submissions"
)

// contentProvider serves a course tree including teacher-audience courses.
// Satisfied by *courses.Service.
type contentProvider interface {
	GetContentAny(ctx context.Context, id int64) (courses.ContentResponse, error)
}

// enrollWriter is the slice of *enrollments.Repository the academy needs.
type enrollWriter interface {
	Create(ctx context.Context, studentID, courseID int64) (enrollments.Enrollment, error)
	HasActive(ctx context.Context, studentID, courseID int64) (bool, error)
}

// reviewer applies an admin verdict to an academy submission. Satisfied by
// *submissions.Service (its TeacherReview carries no group-ownership check —
// that lives in the groups package — so it doubles as the admin reviewer).
type reviewer interface {
	TeacherReview(ctx context.Context, submissionID int64, score *int, feedback string, status string) (submissions.Submission, error)
}

type Service struct {
	repo    *Repository
	content contentProvider
	enroll  enrollWriter
	review  reviewer
}

func NewService(repo *Repository, content contentProvider, enroll enrollWriter, review reviewer) *Service {
	return &Service{repo: repo, content: content, enroll: enroll, review: review}
}

/* ================= teacher-facing ================= */

// ListCourses returns the published academy catalog, each card marked with
// whether the calling teacher is already enrolled.
func (s *Service) ListCourses(ctx context.Context, teacherID int64) ([]CourseCard, error) {
	cards, err := s.repo.PublishedCourses(ctx)
	if err != nil {
		return nil, err
	}
	enrolled, err := s.repo.EnrolledCourseIDs(ctx, teacherID)
	if err != nil {
		return nil, err
	}
	for i := range cards {
		cards[i].Enrolled = enrolled[cards[i].ID]
	}
	return cards, nil
}

// CourseContent serves the module/lesson tree for an academy course.
func (s *Service) CourseContent(ctx context.Context, courseID int64) (courses.ContentResponse, error) {
	if err := s.requireAcademyCourse(ctx, courseID); err != nil {
		return courses.ContentResponse{}, err
	}
	return s.content.GetContentAny(ctx, courseID)
}

// Enroll enrols the teacher in an academy course (spec §11).
func (s *Service) Enroll(ctx context.Context, teacherID, courseID int64) (enrollments.Enrollment, error) {
	if err := s.requireAcademyCourse(ctx, courseID); err != nil {
		return enrollments.Enrollment{}, err
	}
	already, err := s.enroll.HasActive(ctx, teacherID, courseID)
	if err != nil {
		return enrollments.Enrollment{}, err
	}
	if already {
		return enrollments.Enrollment{}, ErrAlreadyEnrolled
	}
	e, err := s.enroll.Create(ctx, teacherID, courseID)
	if errors.Is(err, enrollments.ErrAlreadyEnrolled) {
		return enrollments.Enrollment{}, ErrAlreadyEnrolled
	}
	return e, err
}

func (s *Service) requireAcademyCourse(ctx context.Context, courseID int64) error {
	audience, published, err := s.repo.CourseAudience(ctx, courseID)
	if err != nil {
		return err
	}
	if !published {
		return ErrCourseNotFound
	}
	if audience != "teacher" && audience != "both" {
		return ErrNotTeacherCourse
	}
	return nil
}

// MyCourses is the teacher's enrolled academy courses + progress.
func (s *Service) MyCourses(ctx context.Context, teacherID int64) ([]MyCourse, error) {
	return s.repo.MyCourses(ctx, teacherID)
}

// Dashboard is the "Моё обучение" roll-up.
func (s *Service) Dashboard(ctx context.Context, teacherID int64) (Dashboard, error) {
	courses, err := s.repo.MyCourses(ctx, teacherID)
	if err != nil {
		return Dashboard{}, err
	}
	d := Dashboard{TotalCourses: len(courses), Courses: courses}
	var pctSum int
	for _, c := range courses {
		if c.CourseCompleted {
			d.CoursesCompleted++
		} else {
			d.CoursesInProgress++
		}
		pctSum += c.ProgressPercent
	}
	if len(courses) > 0 {
		d.OverallPercent = pctSum / len(courses)
	}
	return d, nil
}

/* ================= admin-facing ================= */

func (s *Service) Learners(ctx context.Context) ([]LearnerRow, error) {
	return s.repo.Learners(ctx)
}

func (s *Service) Submissions(ctx context.Context, status string) ([]AcademySubmissionRow, error) {
	return s.repo.Submissions(ctx, status)
}

func (s *Service) SubmissionDetail(ctx context.Context, id int64) (AcademySubmissionDetail, error) {
	return s.repo.SubmissionDetail(ctx, id)
}

func (s *Service) PendingReviewCount(ctx context.Context) (int, error) {
	return s.repo.PendingReviewCount(ctx)
}

// Review records an admin verdict on an academy methodology/project
// submission. Reuses the submissions review primitive (status must be
// passed/failed, feedback required for failed, score within the assignment's
// points). Audited.
func (s *Service) Review(ctx context.Context, adminID, submissionID int64, req ReviewRequest) (AcademySubmissionDetail, error) {
	ok, err := s.repo.IsAcademySubmission(ctx, submissionID)
	if err != nil {
		return AcademySubmissionDetail{}, err
	}
	if !ok {
		return AcademySubmissionDetail{}, ErrSubmissionNotFound
	}
	if _, err := s.review.TeacherReview(ctx, submissionID, req.Score, req.Feedback, req.Status); err != nil {
		return AcademySubmissionDetail{}, err
	}
	id := submissionID
	if aerr := s.repo.WriteAudit(ctx, adminID, "update", "academy_submission", &id,
		fmt.Sprintf("%s (score %s)", req.Status, scoreStr(req.Score))); aerr != nil {
		log.Printf("academy: audit write failed: %v", aerr)
	}
	return s.repo.SubmissionDetail(ctx, submissionID)
}

func scoreStr(p *int) string {
	if p == nil {
		return "-"
	}
	return strconv.Itoa(*p)
}
