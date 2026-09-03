package admin

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the admin panel API under /admin. The group is
// expected to already carry auth + RequireRole("admin").
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	a := rg.Group("/admin")

	a.GET("/overview", h.Overview)
	a.GET("/audit", h.ListAudit)

	// users
	a.GET("/users", h.ListUsers)
	a.POST("/users", h.CreateUser)
	a.GET("/users/:id", h.GetUser)
	a.PATCH("/users/:id", h.UpdateUser)
	a.DELETE("/users/:id", h.DeleteUser)
	a.POST("/users/:id/password", h.SetPassword)

	// parent-child links
	a.GET("/parent-links", h.ListParentLinks)
	a.POST("/parent-links", h.CreateParentLink)
	a.DELETE("/parent-links", h.DeleteParentLink)

	// catalog
	crud(a, "programs", h.ListPrograms, h.CreateProgram, h.GetProgram, h.UpdateProgram, h.DeleteProgram)
	crud(a, "levels", h.ListLevels, h.CreateLevel, h.GetLevel, h.UpdateLevel, h.DeleteLevel)
	crud(a, "courses", h.ListCourses, h.CreateCourse, h.GetCourse, h.UpdateCourse, h.DeleteCourse)
	crud(a, "modules", h.ListModules, h.CreateModule, h.GetModule, h.UpdateModule, h.DeleteModule)
	crud(a, "lessons", h.ListLessons, h.CreateLesson, h.GetLesson, h.UpdateLesson, h.DeleteLesson)
	crud(a, "assignments", h.ListAssignments, h.CreateAssignment, h.GetAssignment, h.UpdateAssignment, h.DeleteAssignment)

	// groups (+ membership)
	crud(a, "groups", h.ListGroups, h.CreateGroup, h.GetGroup, h.UpdateGroup, h.DeleteGroup)
	a.GET("/groups/:id/students", h.ListGroupStudents)
	a.POST("/groups/:id/students", h.AddGroupStudent)
	a.DELETE("/groups/:id/students/:studentId", h.RemoveGroupStudent)
}

func crud(rg *gin.RouterGroup, name string, list, create, get, update, del gin.HandlerFunc) {
	rg.GET("/"+name, list)
	rg.POST("/"+name, create)
	rg.GET("/"+name+"/:id", get)
	rg.PATCH("/"+name+"/:id", update)
	rg.DELETE("/"+name+"/:id", del)
}
