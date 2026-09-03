package certificates

import (
	"context"
	"errors"
	"strings"
	"time"
)

// auditor writes to the shared admin_audit_log. Satisfied by
// *admin.Repository — declared here so this package does not import admin.
type auditor interface {
	WriteAudit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) error
}

// pdfRenderer turns a certificate into a PDF document. Satisfied by the
// package's own renderer; an interface keeps the service testable.
type pdfRenderer interface {
	Render(c Certificate, verifyURL, lang string) ([]byte, error)
}

// repository is the slice of *Repository the service needs (an interface so
// the service can be unit-tested with a fake).
type repository interface {
	Eligibility(ctx context.Context, userID, courseID int64) (Eligibility, error)
	YearSeq(ctx context.Context, year int) (int, error)
	Insert(ctx context.Context, c Certificate) (Certificate, error)
	GetByID(ctx context.Context, id int64) (Certificate, error)
	GetByUserCourse(ctx context.Context, userID, courseID int64) (Certificate, error)
	GetByCode(ctx context.Context, code string) (Certificate, error)
	ListByUser(ctx context.Context, userID int64) ([]Certificate, error)
	AdminList(ctx context.Context, f AdminListFilter) ([]AdminRow, int, error)
	AdminGet(ctx context.Context, id int64) (AdminRow, error)
	Revoke(ctx context.Context, id, adminID int64, reason string) (Certificate, error)
}

type Service struct {
	repo    repository
	audit   auditor
	pdf     pdfRenderer
	baseURL string
}

func NewService(repo repository, audit auditor, publicBaseURL string) *Service {
	return &Service{
		repo:    repo,
		audit:   audit,
		pdf:     defaultRenderer{},
		baseURL: strings.TrimRight(publicBaseURL, "/"),
	}
}

func (s *Service) verifyURL(code string) string {
	return s.baseURL + "/certificates/verify/" + code
}

// Issue is lazy + idempotent (spec §10): if the learner already has a
// certificate for the course it is returned unchanged; otherwise it is
// created after independently verifying completion from LMS state. The
// caller's user id is always taken from the authenticated session, never
// from the request body.
func (s *Service) Issue(ctx context.Context, userID, courseID int64) (Response, error) {
	if existing, err := s.repo.GetByUserCourse(ctx, userID, courseID); err == nil {
		return s.toResponse(existing), nil
	} else if !errors.Is(err, ErrNotFound) {
		return Response{}, err
	}

	elig, err := s.repo.Eligibility(ctx, userID, courseID)
	if err != nil {
		return Response{}, err
	}
	if !elig.Enrolled {
		return Response{}, ErrNotEnrolled
	}
	if !elig.Completed {
		return Response{}, ErrNotEligible
	}

	year := time.Now().Year()
	for attempt := 0; attempt < 6; attempt++ {
		seq, err := s.repo.YearSeq(ctx, year)
		if err != nil {
			return Response{}, err
		}
		number, err := newCertificateNumber(year, seq)
		if err != nil {
			return Response{}, err
		}
		code, err := newVerificationCode()
		if err != nil {
			return Response{}, err
		}

		created, err := s.repo.Insert(ctx, Certificate{
			UserID:            userID,
			CourseID:          courseID,
			CertificateNumber: number,
			VerificationCode:  code,
			LearnerName:       elig.LearnerName,
			CourseTitle:       elig.CourseTitle,
			CompletedAt:       elig.CompletedAt,
		})
		switch {
		case err == nil:
			return s.toResponse(created), nil
		case errors.Is(err, errUserCourseConflict):
			// Concurrent issuance won the race — return the winner.
			existing, gErr := s.repo.GetByUserCourse(ctx, userID, courseID)
			if gErr != nil {
				return Response{}, gErr
			}
			return s.toResponse(existing), nil
		case errors.Is(err, errNumberOrCodeConflict):
			continue // regenerate
		default:
			return Response{}, err
		}
	}
	return Response{}, ErrIssueRetriesExhausted
}

// ListMine returns every certificate the authenticated learner owns.
func (s *Service) ListMine(ctx context.Context, userID int64) ([]Response, error) {
	rows, err := s.repo.ListByUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	out := make([]Response, 0, len(rows))
	for _, c := range rows {
		out = append(out, s.toResponse(c))
	}
	return out, nil
}

// GetMine returns one of the learner's own certificates. A certificate that
// belongs to someone else is reported as ErrNotFound — never ErrForbidden —
// so ownership is not leaked.
func (s *Service) GetMine(ctx context.Context, userID, id int64) (Response, error) {
	c, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return Response{}, err
	}
	if c.UserID != userID {
		return Response{}, ErrNotFound
	}
	return s.toResponse(c), nil
}

// PDFForOwner renders the owner's certificate as a PDF in the given language
// ("ru" | "kz" | "en", default "ru").
func (s *Service) PDFForOwner(ctx context.Context, userID, id int64, lang string) ([]byte, Certificate, error) {
	c, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, Certificate{}, err
	}
	if c.UserID != userID {
		return nil, Certificate{}, ErrNotFound
	}
	pdf, err := s.pdf.Render(c, s.verifyURL(c.VerificationCode), normalizeLang(lang))
	return pdf, c, err
}

// PDFForAdmin renders any certificate as a PDF (admin support tooling).
func (s *Service) PDFForAdmin(ctx context.Context, id int64, lang string) ([]byte, Certificate, error) {
	c, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, Certificate{}, err
	}
	pdf, err := s.pdf.Render(c, s.verifyURL(c.VerificationCode), normalizeLang(lang))
	return pdf, c, err
}

// Verify is the public verification lookup. An unknown code returns
// ErrNotFound; a known one returns a safe payload with valid=false when the
// certificate is revoked.
func (s *Service) Verify(ctx context.Context, code string) (PublicVerification, error) {
	c, err := s.repo.GetByCode(ctx, code)
	if err != nil {
		return PublicVerification{}, err
	}
	return toPublic(c), nil
}

/* ================= admin ================= */

func (s *Service) AdminList(ctx context.Context, f AdminListFilter) (AdminList, error) {
	rows, total, err := s.repo.AdminList(ctx, f)
	if err != nil {
		return AdminList{}, err
	}
	items := make([]AdminListItem, 0, len(rows))
	for _, ar := range rows {
		items = append(items, toAdminItem(ar))
	}
	page := f.Page
	if page <= 0 {
		page = 1
	}
	limit := f.Limit
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return AdminList{Items: items, Total: total, Page: page, Limit: limit}, nil
}

func (s *Service) AdminGet(ctx context.Context, id int64) (AdminListItem, error) {
	ar, err := s.repo.AdminGet(ctx, id)
	if err != nil {
		return AdminListItem{}, err
	}
	return toAdminItem(ar), nil
}

// Revoke marks a certificate revoked and writes an admin_audit_log entry.
func (s *Service) Revoke(ctx context.Context, adminID, id int64, req RevokeRequest) (AdminListItem, error) {
	reason := strings.TrimSpace(req.Reason)
	if reason == "" {
		return AdminListItem{}, ErrReasonRequired
	}
	c, err := s.repo.Revoke(ctx, id, adminID, reason)
	if err != nil {
		return AdminListItem{}, err
	}
	// admin_audit_log.action is CHECK-constrained to create|update|delete, so
	// a revoke is recorded as an "update" on entity "certificate" with the
	// reason in the summary. Best-effort: the revoke itself is already
	// committed and must not be undone if the audit insert fails.
	entityID := c.ID
	_ = s.audit.WriteAudit(ctx, adminID, "update", "certificate", &entityID,
		"revoked "+c.CertificateNumber+": "+reason)

	ar, err := s.repo.AdminGet(ctx, id)
	if err != nil {
		return AdminListItem{}, err
	}
	return toAdminItem(ar), nil
}

func normalizeLang(lang string) string {
	switch strings.ToLower(strings.TrimSpace(lang)) {
	case "kz", "kk":
		return "kz"
	case "en":
		return "en"
	default:
		return "ru"
	}
}
