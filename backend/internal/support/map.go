package support

import "unicode/utf8"

func preview(body, msgType string) string {
	const max = 140
	if msgType == MsgSystem {
		body = "— " + body
	}
	if utf8.RuneCountInString(body) <= max {
		return body
	}
	return string([]rune(body)[:max]) + "…"
}

func toListItem(r threadRow) ThreadListItem {
	return ThreadListItem{
		ID:       r.ID,
		Subject:  r.Subject,
		Category: r.Category,
		Status:   r.Status,
		Priority: r.Priority,
		About: ThreadAbout{
			StudentName:    r.StudentName,
			CourseTitle:    r.CourseTitle,
			LessonTitle:    r.LessonTitle,
			AssignmentName: r.AssignmentName,
		},
		LastMessage:     preview(r.LastBody, r.LastType),
		LastMessageAt:   r.LastMessageAt,
		UnreadCount:     r.Unread,
		AssignedToStaff: r.AssignedAdminID != nil,
		CreatedAt:       r.CreatedAt,
	}
}

func toAdminListItem(r threadRow) AdminThreadListItem {
	kind := "student"
	if r.OwnerRole == "parent" {
		kind = "parent"
	}
	var assigned *PersonRef
	if r.AssignedAdminID != nil && r.AssignedName != nil {
		assigned = &PersonRef{ID: *r.AssignedAdminID, Name: *r.AssignedName}
	}
	return AdminThreadListItem{
		ID:            r.ID,
		Kind:          kind,
		Owner:         PersonRef{ID: r.UserID, Name: r.OwnerName, Email: r.OwnerEmail},
		StudentName:   r.StudentName,
		Subject:       r.Subject,
		Category:      r.Category,
		Status:        r.Status,
		Priority:      r.Priority,
		CourseTitle:   r.CourseTitle,
		AssignedAdmin: assigned,
		LastMessage:   preview(r.LastBody, r.LastType),
		LastMessageAt: r.LastMessageAt,
		UnreadCount:   r.Unread,
		CreatedAt:     r.CreatedAt,
	}
}

func toMessageDTOs(rows []messageRow, callerID int64) []MessageDTO {
	// repo returns newest-first; the UI wants oldest-first
	out := make([]MessageDTO, 0, len(rows))
	for i := len(rows) - 1; i >= 0; i-- {
		m := rows[i]
		out = append(out, MessageDTO{
			ID:          m.ID,
			Body:        m.Body,
			MessageType: m.MessageType,
			SenderRole:  m.SenderRole,
			SenderName:  m.SenderName,
			Mine:        m.SenderUserID == callerID,
			IsInternal:  m.IsInternal,
			CreatedAt:   m.CreatedAt,
			EditedAt:    m.EditedAt,
		})
	}
	return out
}
