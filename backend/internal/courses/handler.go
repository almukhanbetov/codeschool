package courses

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/httpx"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) List(c *gin.Context) {
	filter, ok := parseListFilter(c)
	if !ok {
		return
	}

	items, err := h.service.List(c.Request.Context(), filter)
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

func (h *Handler) GetBySlug(c *gin.Context) {
	slug := c.Param("slug")
	if slug == "" {
		httpx.Fail(c, httpx.BadRequest("INVALID_SLUG", "Course slug is required"))
		return
	}

	item, err := h.service.GetBySlug(c.Request.Context(), slug)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, item)
}

func (h *Handler) GetContent(c *gin.Context) {
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	item, err := h.service.GetContent(c.Request.Context(), id)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, item)
}

// parseListFilter reads the optional ?age_from=&age_to=&level_id= query
// params. On a malformed value it writes the 400 response itself and
// returns ok=false.
func parseListFilter(c *gin.Context) (ListFilter, bool) {
	var filter ListFilter

	if raw := c.Query("age_from"); raw != "" {
		v, err := strconv.Atoi(raw)
		if err != nil {
			httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "age_from must be an integer"))
			return ListFilter{}, false
		}
		filter.AgeFrom = &v
	}

	if raw := c.Query("age_to"); raw != "" {
		v, err := strconv.Atoi(raw)
		if err != nil {
			httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "age_to must be an integer"))
			return ListFilter{}, false
		}
		filter.AgeTo = &v
	}

	if raw := c.Query("level_id"); raw != "" {
		v, err := strconv.ParseInt(raw, 10, 64)
		if err != nil || v <= 0 {
			httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "level_id must be a positive integer"))
			return ListFilter{}, false
		}
		filter.LevelID = &v
	}

	return filter, true
}
