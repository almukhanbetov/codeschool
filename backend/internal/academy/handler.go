package academy

import (
	"errors"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/submissions"
)

/* ================= teacher handler ================= */

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func teacherID(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
	}
	return id, ok
}

// ListCourses handles GET /teacher-academy/courses.
func (h *Handler) ListCourses(c *gin.Context) {
	tid, ok := teacherID(c)
	if !ok {
		return
	}
	res, err := h.service.ListCourses(c.Request.Context(), tid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// CourseContent handles GET /teacher-academy/courses/:id/content.
func (h *Handler) CourseContent(c *gin.Context) {
	if _, ok := teacherID(c); !ok {
		return
	}
	courseID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.CourseContent(c.Request.Context(), courseID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// Enroll handles POST /teacher-academy/courses/:id/enroll.
func (h *Handler) Enroll(c *gin.Context) {
	tid, ok := teacherID(c)
	if !ok {
		return
	}
	courseID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.Enroll(c.Request.Context(), tid, courseID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.Created(c, res)
}

// MyCourses handles GET /teacher-academy/me/courses.
func (h *Handler) MyCourses(c *gin.Context) {
	tid, ok := teacherID(c)
	if !ok {
		return
	}
	res, err := h.service.MyCourses(c.Request.Context(), tid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// Dashboard handles GET /teacher-academy/dashboard.
func (h *Handler) Dashboard(c *gin.Context) {
	tid, ok := teacherID(c)
	if !ok {
		return
	}
	res, err := h.service.Dashboard(c.Request.Context(), tid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= admin handler ================= */

type AdminHandler struct {
	service *Service
}

func NewAdminHandler(service *Service) *AdminHandler {
	return &AdminHandler{service: service}
}

func (h *AdminHandler) Learners(c *gin.Context) {
	res, err := h.service.Learners(c.Request.Context())
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) Submissions(c *gin.Context) {
	res, err := h.service.Submissions(c.Request.Context(), c.Query("status"))
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) SubmissionDetail(c *gin.Context) {
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.SubmissionDetail(c.Request.Context(), id)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) Review(c *gin.Context) {
	adminID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req ReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.Review(c.Request.Context(), adminID, id, req)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= error mapping ================= */

func mapErr(err error) error {
	switch {
	case errors.Is(err, ErrCourseNotFound), errors.Is(err, ErrSubmissionNotFound):
		return httpx.NotFound(httpx.CodeNotFound, "Not found")
	case errors.Is(err, ErrNotTeacherCourse):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "This course is not a Teacher Academy course")
	case errors.Is(err, ErrAlreadyEnrolled):
		return httpx.Conflict(httpx.CodeConflict, "Already enrolled in this academy course")
	case errors.Is(err, submissions.ErrNotReviewable):
		return httpx.Conflict(httpx.CodeConflict, "This submission is not awaiting review")
	case errors.Is(err, submissions.ErrInvalidReviewStatus):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Review status must be passed or failed")
	case errors.Is(err, submissions.ErrScoreOutOfRange):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Score is outside the assignment's points range")
	case errors.Is(err, submissions.ErrScoreRequired):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "A score is required")
	case errors.Is(err, submissions.ErrFeedbackRequired):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Feedback is required when marking a submission failed")
	default:
		return err
	}
}
