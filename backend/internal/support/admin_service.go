package support

import "context"

// auditor writes to the shared admin_audit_log. Satisfied by *admin.Repository.
type auditor interface {
	WriteAudit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) error
}

// AdminService is the staff side of the support chat. Staff = role "admin"
// (see docs — a dedicated manager/curator sub-role is future work).
type AdminService struct {
	repo  *Repository
	audit auditor
}

func NewAdminService(repo *Repository, audit auditor) *AdminService {
	return &AdminService{repo: repo, audit: audit}
}

type ListMeta struct {
	Page  int `json:"page"`
	Limit int `json:"limit"`
	Total int `json:"total"`
}

func (s *AdminService) List(ctx context.Context, adminID int64, f AdminFilter) ([]AdminThreadListItem, ListMeta, error) {
	f.ViewerID = adminID
	rows, total, err := s.repo.AdminList(ctx, f)
	if err != nil {
		return nil, ListMeta{}, err
	}
	items := make([]AdminThreadListItem, 0, len(rows))
	for _, r := range rows {
		items = append(items, toAdminListItem(r))
	}
	page, limit := f.Page, f.Limit
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return items, ListMeta{Page: page, Limit: limit, Total: total}, nil
}

func (s *AdminService) Get(ctx context.Context, adminID, threadID int64) (AdminThreadDetail, error) {
	tr, err := s.repo.ThreadRowForViewer(ctx, threadID, adminID, true)
	if err != nil {
		return AdminThreadDetail{}, err
	}
	d := AdminThreadDetail{
		AdminThreadListItem: toAdminListItem(tr),
		LessonTitle:         tr.LessonTitle,
		AssignmentName:      tr.AssignmentName,
	}
	if tr.StudentID != nil {
		var parentID *int64
		if tr.OwnerRole == "parent" {
			pid := tr.UserID
			parentID = &pid
		}
		lc, err := s.repo.LearningContext(ctx, *tr.StudentID, tr.CourseID, parentID)
		if err != nil {
			return AdminThreadDetail{}, err
		}
		d.Context = lc
	}
	return d, nil
}

func (s *AdminService) ListMessages(ctx context.Context, adminID, threadID, before int64, limit int) ([]MessageDTO, error) {
	if _, err := s.repo.ThreadByID(ctx, threadID); err != nil {
		return nil, err
	}
	rows, err := s.repo.Messages(ctx, threadID, before, limit, true)
	if err != nil {
		return nil, err
	}
	return toMessageDTOs(rows, adminID), nil
}

func (s *AdminService) PostMessage(ctx context.Context, adminID, threadID int64, body string, internal bool) (MessageDTO, error) {
	clean, err := cleanBody(body)
	if err != nil {
		return MessageDTO{}, err
	}
	if _, err := s.repo.ThreadByID(ctx, threadID); err != nil {
		return MessageDTO{}, err
	}
	msgType := MsgText
	if internal {
		msgType = MsgInternalNote
	}
	m, err := s.repo.AddMessage(ctx, threadID, adminID, "admin", clean, msgType, internal)
	if err != nil {
		return MessageDTO{}, err
	}
	if !internal {
		// a staff reply hands the thread back to the user
		_ = s.repo.SetStatus(ctx, threadID, StatusWaitingUser)
	}
	name, _ := (&Service{repo: s.repo}).senderName(ctx, adminID)
	return MessageDTO{
		ID: m.ID, Body: m.Body, MessageType: m.MessageType, SenderRole: "admin",
		SenderName: name, Mine: true, IsInternal: internal, CreatedAt: m.CreatedAt,
	}, nil
}

func (s *AdminService) Assign(ctx context.Context, adminID, threadID int64, target *int64) (AdminThreadDetail, error) {
	if _, err := s.repo.ThreadByID(ctx, threadID); err != nil {
		return AdminThreadDetail{}, err
	}
	if target != nil {
		ok, err := s.repo.IsAdmin(ctx, *target)
		if err != nil {
			return AdminThreadDetail{}, err
		}
		if !ok {
			return AdminThreadDetail{}, ErrNotAnAdmin
		}
	}
	if err := s.repo.Assign(ctx, threadID, target); err != nil {
		return AdminThreadDetail{}, err
	}
	summary := "unassigned"
	sysBody := "Обращение снято с назначения"
	if target != nil {
		name, _ := (&Service{repo: s.repo}).senderName(ctx, *target)
		summary = "assigned to " + name
		sysBody = "Обращение назначено: " + name
	}
	_, _ = s.repo.AddMessage(ctx, threadID, adminID, "admin", sysBody, MsgSystem, true)
	tid := threadID
	_ = s.audit.WriteAudit(ctx, adminID, "update", "support_thread", &tid, summary)
	return s.Get(ctx, adminID, threadID)
}

func (s *AdminService) SetStatus(ctx context.Context, adminID, threadID int64, status string) (AdminThreadDetail, error) {
	if !validStatus(status) {
		return AdminThreadDetail{}, ErrInvalidStatus
	}
	cur, err := s.repo.ThreadByID(ctx, threadID)
	if err != nil {
		return AdminThreadDetail{}, err
	}
	if err := s.repo.SetStatus(ctx, threadID, status); err != nil {
		return AdminThreadDetail{}, err
	}
	tid := threadID
	switch {
	case status == StatusClosed && cur.Status != StatusClosed:
		_, _ = s.repo.AddMessage(ctx, threadID, adminID, "admin", "Обращение закрыто", MsgSystem, false)
		_ = s.audit.WriteAudit(ctx, adminID, "update", "support_thread", &tid, "closed")
	case cur.Status == StatusClosed && status != StatusClosed:
		_, _ = s.repo.AddMessage(ctx, threadID, adminID, "admin", "Обращение снова открыто", MsgSystem, false)
		_ = s.audit.WriteAudit(ctx, adminID, "update", "support_thread", &tid, "reopened")
	}
	return s.Get(ctx, adminID, threadID)
}

func (s *AdminService) MarkRead(ctx context.Context, adminID, threadID int64) error {
	if _, err := s.repo.ThreadByID(ctx, threadID); err != nil {
		return err
	}
	return s.repo.MarkRead(ctx, threadID, adminID, true)
}

func (s *AdminService) UnreadCount(ctx context.Context, adminID int64) (UnreadCountDTO, error) {
	th, ms, err := s.repo.UnreadForAdmin(ctx, adminID)
	if err != nil {
		return UnreadCountDTO{}, err
	}
	return UnreadCountDTO{Threads: th, Messages: ms}, nil
}
