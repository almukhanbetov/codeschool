package admin

import "github.com/gin-gonic/gin"

func (h *Handler) ListGroups(c *gin.Context) {
	teacherID, ok1 := queryI64(c, "teacherId")
	if !ok1 {
		return
	}
	courseID, ok2 := queryI64(c, "courseId")
	if !ok2 {
		return
	}
	rows, err := h.service.ListGroups(c.Request.Context(), teacherID, courseID, c.Query("status"))
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}

func (h *Handler) GetGroup(c *gin.Context)    { crudGet(h, c, h.service.GetGroup) }
func (h *Handler) CreateGroup(c *gin.Context) { crudCreate(h, c, h.service.CreateGroup) }
func (h *Handler) UpdateGroup(c *gin.Context) { crudUpdate(h, c, h.service.UpdateGroup) }
func (h *Handler) DeleteGroup(c *gin.Context) { crudDelete(h, c, h.service.DeleteGroup) }

func (h *Handler) ListGroupStudents(c *gin.Context) {
	id, ok := idParam(c, "id")
	if !ok {
		return
	}
	rows, err := h.service.ListGroupStudents(c.Request.Context(), id)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}

func (h *Handler) AddGroupStudent(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	id, okP := idParam(c, "id")
	if !okP {
		return
	}
	req, okB := bind[AddGroupStudentRequest](c)
	if !okB {
		return
	}
	if err := h.service.AddGroupStudent(c.Request.Context(), adminID, id, req.StudentID); err != nil {
		fail(c, err)
		return
	}
	created(c, gin.H{"added": true})
}

func (h *Handler) RemoveGroupStudent(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	id, okP := idParam(c, "id")
	if !okP {
		return
	}
	studentID, okS := idParam(c, "studentId")
	if !okS {
		return
	}
	if err := h.service.RemoveGroupStudent(c.Request.Context(), adminID, id, studentID); err != nil {
		fail(c, err)
		return
	}
	respond(c, gin.H{"removed": true})
}
