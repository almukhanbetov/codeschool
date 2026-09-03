package admin

import (
	"context"

	"github.com/gin-gonic/gin"
)

// Generic CRUD glue — the create/update/delete flows are identical across the
// catalog entities apart from the request/response types and the service fn.

func crudCreate[Req any, Res any](h *Handler, c *gin.Context, fn func(ctx context.Context, adminID int64, req Req) (Res, error)) {
	adminID, ok := h.actor(c)
	if !ok {
		return
	}
	req, ok := bind[Req](c)
	if !ok {
		return
	}
	res, err := fn(c.Request.Context(), adminID, req)
	if err != nil {
		fail(c, err)
		return
	}
	created(c, res)
}

func crudUpdate[Req any, Res any](h *Handler, c *gin.Context, fn func(ctx context.Context, adminID, id int64, req Req) (Res, error)) {
	adminID, ok := h.actor(c)
	if !ok {
		return
	}
	id, ok := idParam(c, "id")
	if !ok {
		return
	}
	req, ok := bind[Req](c)
	if !ok {
		return
	}
	res, err := fn(c.Request.Context(), adminID, id, req)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, res)
}

func crudGet[Res any](h *Handler, c *gin.Context, fn func(ctx context.Context, id int64) (Res, error)) {
	id, ok := idParam(c, "id")
	if !ok {
		return
	}
	res, err := fn(c.Request.Context(), id)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, res)
}

func crudDelete(h *Handler, c *gin.Context, fn func(ctx context.Context, adminID, id int64) error) {
	adminID, ok := h.actor(c)
	if !ok {
		return
	}
	id, ok := idParam(c, "id")
	if !ok {
		return
	}
	if err := fn(c.Request.Context(), adminID, id); err != nil {
		fail(c, err)
		return
	}
	respond(c, gin.H{"deleted": true})
}

/* ---- programs ---- */

func (h *Handler) ListPrograms(c *gin.Context) {
	rows, err := h.service.ListPrograms(c.Request.Context())
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}
func (h *Handler) GetProgram(c *gin.Context)    { crudGet(h, c, h.service.GetProgram) }
func (h *Handler) CreateProgram(c *gin.Context) { crudCreate(h, c, h.service.CreateProgram) }
func (h *Handler) UpdateProgram(c *gin.Context) { crudUpdate(h, c, h.service.UpdateProgram) }
func (h *Handler) DeleteProgram(c *gin.Context) { crudDelete(h, c, h.service.DeleteProgram) }

/* ---- levels ---- */

func (h *Handler) ListLevels(c *gin.Context) {
	programID, ok := queryI64(c, "programId")
	if !ok {
		return
	}
	rows, err := h.service.ListLevels(c.Request.Context(), programID)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}
func (h *Handler) GetLevel(c *gin.Context)    { crudGet(h, c, h.service.GetLevel) }
func (h *Handler) CreateLevel(c *gin.Context) { crudCreate(h, c, h.service.CreateLevel) }
func (h *Handler) UpdateLevel(c *gin.Context) { crudUpdate(h, c, h.service.UpdateLevel) }
func (h *Handler) DeleteLevel(c *gin.Context) { crudDelete(h, c, h.service.DeleteLevel) }

/* ---- courses ---- */

func (h *Handler) ListCourses(c *gin.Context) {
	levelID, ok1 := queryI64(c, "levelId")
	if !ok1 {
		return
	}
	published, ok2 := queryBool(c, "published")
	if !ok2 {
		return
	}
	rows, err := h.service.ListCourses(c.Request.Context(), levelID, published)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}
func (h *Handler) GetCourse(c *gin.Context)    { crudGet(h, c, h.service.GetCourse) }
func (h *Handler) CreateCourse(c *gin.Context) { crudCreate(h, c, h.service.CreateCourse) }
func (h *Handler) UpdateCourse(c *gin.Context) { crudUpdate(h, c, h.service.UpdateCourse) }
func (h *Handler) DeleteCourse(c *gin.Context) { crudDelete(h, c, h.service.DeleteCourse) }

/* ---- modules ---- */

func (h *Handler) ListModules(c *gin.Context) {
	courseID, ok := queryI64(c, "courseId")
	if !ok {
		return
	}
	rows, err := h.service.ListModules(c.Request.Context(), courseID)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}
func (h *Handler) GetModule(c *gin.Context)    { crudGet(h, c, h.service.GetModule) }
func (h *Handler) CreateModule(c *gin.Context) { crudCreate(h, c, h.service.CreateModule) }
func (h *Handler) UpdateModule(c *gin.Context) { crudUpdate(h, c, h.service.UpdateModule) }
func (h *Handler) DeleteModule(c *gin.Context) { crudDelete(h, c, h.service.DeleteModule) }

/* ---- lessons ---- */

func (h *Handler) ListLessons(c *gin.Context) {
	moduleID, ok := queryI64(c, "moduleId")
	if !ok {
		return
	}
	rows, err := h.service.ListLessons(c.Request.Context(), moduleID)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}
func (h *Handler) GetLesson(c *gin.Context)    { crudGet(h, c, h.service.GetLesson) }
func (h *Handler) CreateLesson(c *gin.Context) { crudCreate(h, c, h.service.CreateLesson) }
func (h *Handler) UpdateLesson(c *gin.Context) { crudUpdate(h, c, h.service.UpdateLesson) }
func (h *Handler) DeleteLesson(c *gin.Context) { crudDelete(h, c, h.service.DeleteLesson) }

/* ---- assignments ---- */

func (h *Handler) ListAssignments(c *gin.Context) {
	lessonID, ok := queryI64(c, "lessonId")
	if !ok {
		return
	}
	rows, err := h.service.ListAssignments(c.Request.Context(), lessonID)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}
func (h *Handler) GetAssignment(c *gin.Context)    { crudGet(h, c, h.service.GetAssignment) }
func (h *Handler) CreateAssignment(c *gin.Context) { crudCreate(h, c, h.service.CreateAssignment) }
func (h *Handler) UpdateAssignment(c *gin.Context) { crudUpdate(h, c, h.service.UpdateAssignment) }
func (h *Handler) DeleteAssignment(c *gin.Context) { crudDelete(h, c, h.service.DeleteAssignment) }
