package certificates

import "time"

// Certificate statuses (see migration 00026's CHECK constraint).
const (
	StatusActive  = "active"
	StatusRevoked = "revoked"
)

// Certificate is the internal representation of a row in `certificates`.
// The learner is always an existing users.id regardless of role.
type Certificate struct {
	ID                int64
	UserID            int64
	CourseID          int64
	CertificateNumber string
	VerificationCode  string
	LearnerName       string // issuance-time snapshot
	CourseTitle       string // issuance-time snapshot
	IssuedAt          time.Time
	CompletedAt       time.Time
	Status            string
	RevokedAt         *time.Time
	RevokedBy         *int64
	RevokeReason      *string
	CreatedAt         time.Time
	UpdatedAt         time.Time
}

// Eligibility is the authoritative "has the learner completed this course"
// answer, derived from existing LMS state (enrollments + lesson_progress) —
// never from anything the client sends.
type Eligibility struct {
	Enrolled     bool
	Completed    bool
	LearnerName  string
	CourseTitle  string
	CompletedAt  time.Time
	TotalLessons int
	DoneLessons  int
}

// AdminListFilter narrows GET /admin/certificates.
type AdminListFilter struct {
	Status   string // "", "active", "revoked"
	CourseID *int64
	Query    string // matches certificate_number or learner_name
	Page     int
	Limit    int
}
