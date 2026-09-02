package modules

import (
	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/httpx"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// ListByCourse serves GET /api/v1/courses/:id/modules.
func (h *Handler) ListByCourse(c *gin.Context) {
	courseID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	items, err := h.service.ListByCourseID(c.Request.Context(), courseID)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}
