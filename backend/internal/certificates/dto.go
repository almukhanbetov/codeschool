package certificates

import "time"

// CourseRef is the minimal course identity shown on a certificate.
type CourseRef struct {
	ID    int64  `json:"id"`
	Title string `json:"title"`
}

// Response is the owner-facing certificate payload (GET /me/certificates,
// GET /me/certificates/:id, POST /courses/:id/certificate). It never carries
// email / phone / other user fields.
type Response struct {
	ID                int64     `json:"id"`
	CertificateNumber string    `json:"certificateNumber"`
	VerificationCode  string    `json:"verificationCode"`
	Course            CourseRef `json:"course"`
	LearnerName       string    `json:"learnerName"`
	IssuedAt          time.Time `json:"issuedAt"`
	CompletedAt       time.Time `json:"completedAt"`
	Status            string    `json:"status"`
	VerifyURL         string    `json:"verifyUrl"`
}

// PublicVerification is GET /api/v1/certificates/verify/:code — no auth, only
// safe public fields. No email, phone, user id, enrollment id or progress.
type PublicVerification struct {
	Valid             bool       `json:"valid"`
	Status            string     `json:"status"`
	CertificateNumber string     `json:"certificateNumber"`
	LearnerName       string     `json:"learnerName"`
	CourseTitle       string     `json:"courseTitle"`
	IssuedAt          time.Time  `json:"issuedAt"`
	CompletedAt       time.Time  `json:"completedAt"`
	RevokedAt         *time.Time `json:"revokedAt,omitempty"`
}

// AdminListItem is one row of GET /api/v1/admin/certificates.
type AdminListItem struct {
	ID                int64      `json:"id"`
	CertificateNumber string     `json:"certificateNumber"`
	VerificationCode  string     `json:"verificationCode"`
	UserID            int64      `json:"userId"`
	LearnerName       string     `json:"learnerName"`
	LearnerRole       string     `json:"learnerRole"`
	CourseID          int64      `json:"courseId"`
	CourseTitle       string     `json:"courseTitle"`
	IssuedAt          time.Time  `json:"issuedAt"`
	CompletedAt       time.Time  `json:"completedAt"`
	Status            string     `json:"status"`
	RevokedAt         *time.Time `json:"revokedAt,omitempty"`
	RevokedBy         *int64     `json:"revokedBy,omitempty"`
	RevokeReason      *string    `json:"revokeReason,omitempty"`
}

// AdminList is the paginated GET /api/v1/admin/certificates envelope body.
type AdminList struct {
	Items []AdminListItem `json:"items"`
	Total int             `json:"total"`
	Page  int             `json:"page"`
	Limit int             `json:"limit"`
}

// RevokeRequest is POST /api/v1/admin/certificates/:id/revoke.
type RevokeRequest struct {
	Reason string `json:"reason"`
}

func (s *Service) toResponse(c Certificate) Response {
	return Response{
		ID:                c.ID,
		CertificateNumber: c.CertificateNumber,
		VerificationCode:  c.VerificationCode,
		Course:            CourseRef{ID: c.CourseID, Title: c.CourseTitle},
		LearnerName:       c.LearnerName,
		IssuedAt:          c.IssuedAt,
		CompletedAt:       c.CompletedAt,
		Status:            c.Status,
		VerifyURL:         s.verifyURL(c.VerificationCode),
	}
}

func toPublic(c Certificate) PublicVerification {
	return PublicVerification{
		Valid:             c.Status == StatusActive,
		Status:            c.Status,
		CertificateNumber: c.CertificateNumber,
		LearnerName:       c.LearnerName,
		CourseTitle:       c.CourseTitle,
		IssuedAt:          c.IssuedAt,
		CompletedAt:       c.CompletedAt,
		RevokedAt:         c.RevokedAt,
	}
}

func toAdminItem(ar AdminRow) AdminListItem {
	return AdminListItem{
		ID:                ar.ID,
		CertificateNumber: ar.CertificateNumber,
		VerificationCode:  ar.VerificationCode,
		UserID:            ar.UserID,
		LearnerName:       ar.LearnerName,
		LearnerRole:       ar.LearnerRole,
		CourseID:          ar.CourseID,
		CourseTitle:       ar.CourseTitle,
		IssuedAt:          ar.IssuedAt,
		CompletedAt:       ar.CompletedAt,
		Status:            ar.Status,
		RevokedAt:         ar.RevokedAt,
		RevokedBy:         ar.RevokedBy,
		RevokeReason:      ar.RevokeReason,
	}
}
