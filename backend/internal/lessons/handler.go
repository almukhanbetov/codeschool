package lessons

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

// ListByModule serves GET /api/v1/modules/:id/lessons.
func (h *Handler) ListByModule(c *gin.Context) {
	moduleID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	items, err := h.service.ListByModuleID(c.Request.Context(), moduleID)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}

// GetByID serves GET /api/v1/lessons/:id.
func (h *Handler) GetByID(c *gin.Context) {
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	item, err := h.service.GetByID(c.Request.Context(), id)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, item)
}
