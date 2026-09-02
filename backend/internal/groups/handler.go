package groups

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/submissions"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) teacherID(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return 0, false
	}
	return id, true
}

// GET /teacher/dashboard
func (h *Handler) Dashboard(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	d, err := h.service.Dashboard(c.Request.Context(), tid)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, d)
}

// GET /teacher/groups
func (h *Handler) ListGroups(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	items, err := h.service.ListGroups(c.Request.Context(), tid)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}

// GET /teacher/groups/:id
func (h *Handler) GetGroup(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	gid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	g, err := h.service.GetGroup(c.Request.Context(), tid, gid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, g)
}

// GET /teacher/groups/:id/students
func (h *Handler) ListGroupStudents(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	gid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	items, err := h.service.ListStudents(c.Request.Context(), tid, gid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, items)
}

// GET /teacher/groups/:id/students/:studentId
func (h *Handler) GetGroupStudent(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	gid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	sid, err := strconv.ParseInt(c.Param("studentId"), 10, 64)
	if err != nil || sid <= 0 {
		httpx.Fail(c, httpx.BadRequest("INVALID_ID", "studentId must be a positive integer"))
		return
	}
	d, serr := h.service.GetStudent(c.Request.Context(), tid, gid, sid)
	if serr != nil {
		httpx.Fail(c, mapErr(serr))
		return
	}
	httpx.OK(c, d)
}

// GET /teacher/submissions
func (h *Handler) ListSubmissions(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}

	f := SubmissionFilter{
		Status: c.Query("status"),
		Page:   atoiDefault(c.Query("page"), 1),
		Limit:  atoiDefault(c.Query("limit"), defaultLimit),
	}
	if raw := c.Query("group_id"); raw != "" {
		v, err := strconv.ParseInt(raw, 10, 64)
		if err != nil || v <= 0 {
			httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "group_id must be a positive integer"))
			return
		}
		f.GroupID = &v
	}
	if raw := c.Query("course_id"); raw != "" {
		v, err := strconv.ParseInt(raw, 10, 64)
		if err != nil || v <= 0 {
			httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "course_id must be a positive integer"))
			return
		}
		f.CourseID = &v
	}
	if f.Status != "" && !validStatus(f.Status) {
		httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "unknown status filter"))
		return
	}

	items, meta, err := h.service.ListSubmissions(c.Request.Context(), tid, f)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": items, "meta": meta})
}

// GET /teacher/submissions/:id
func (h *Handler) GetSubmission(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	sid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	d, err := h.service.GetSubmission(c.Request.Context(), tid, sid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, d)
}

// POST /teacher/submissions/:id/start-review
func (h *Handler) StartReview(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	sid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	d, err := h.service.StartReview(c.Request.Context(), tid, sid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, d)
}

// POST /teacher/submissions/:id/review
func (h *Handler) Review(c *gin.Context) {
	tid, ok := h.teacherID(c)
	if !ok {
		return
	}
	sid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req ReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	d, err := h.service.Review(c.Request.Context(), tid, sid, req)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, d)
}

func mapErr(err error) error {
	switch {
	case errors.Is(err, ErrGroupNotFound):
		return httpx.NotFound("GROUP_NOT_FOUND", "Group not found")
	case errors.Is(err, ErrStudentNotInGroup):
		return httpx.Forbidden(httpx.CodeForbidden, "This student is not in your group")
	case errors.Is(err, ErrSubmissionNotFound), errors.Is(err, submissions.ErrNotFound):
		return httpx.NotFound("SUBMISSION_NOT_FOUND", "Submission not found")
	case errors.Is(err, submissions.ErrNotReviewable):
		return httpx.Conflict(httpx.CodeConflict, "This submission is not awaiting review")
	case errors.Is(err, submissions.ErrInvalidReviewStatus):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Review status must be 'passed' or 'failed'")
	case errors.Is(err, submissions.ErrScoreOutOfRange):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Score is outside the assignment's points range")
	case errors.Is(err, submissions.ErrScoreRequired):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "A score is required for this assignment")
	case errors.Is(err, submissions.ErrFeedbackRequired):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Feedback is required when marking a submission failed")
	default:
		return err
	}
}

func atoiDefault(s string, def int) int {
	if s == "" {
		return def
	}
	v, err := strconv.Atoi(s)
	if err != nil {
		return def
	}
	return v
}

func validStatus(s string) bool {
	switch s {
	case submissions.StatusDraft, submissions.StatusSubmitted, submissions.StatusChecking,
		submissions.StatusPassed, submissions.StatusFailed:
		return true
	default:
		return false
	}
}
