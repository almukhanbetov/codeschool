package programs

import (
	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/levels"
)

type Handler struct {
	service       *Service
	levelsService *levels.Service
}

func NewHandler(service *Service, levelsService *levels.Service) *Handler {
	return &Handler{service: service, levelsService: levelsService}
}

func (h *Handler) List(c *gin.Context) {
	items, err := h.service.List(c.Request.Context())
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}

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

// ListLevels serves GET /api/v1/programs/:id/levels. It lives here (rather
// than in the levels package) because the route is scoped by program id;
// the levels domain still owns the query and response shape.
func (h *Handler) ListLevels(c *gin.Context) {
	programID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	if _, err := h.service.GetByID(c.Request.Context(), programID); err != nil {
		httpx.Fail(c, err)
		return
	}

	items, err := h.levelsService.ListByProgramID(c.Request.Context(), programID)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}
