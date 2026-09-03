package runs

import (
	"context"
	"log"
	"strconv"
	"strings"

	"codeschool/backend/internal/assignments"
)

// AdminService is I/O test-case authoring for `code` assignments. Every
// mutation is written to the shared admin_audit_log (spec §63 pattern).
type AdminService struct {
	repo   *Repository
	assign adminAssignmentReader
}

// adminAssignmentReader resolves an assignment (published or not) to its type.
// Satisfied by *assignments.Service.
type adminAssignmentReader interface {
	GetAnyByID(ctx context.Context, assignmentID int64) (assignments.Assignment, error)
}

func NewAdminService(repo *Repository, assign adminAssignmentReader) *AdminService {
	return &AdminService{repo: repo, assign: assign}
}

func (s *AdminService) audit(ctx context.Context, adminID int64, action, entity string, entityID int64, summary string) {
	id := entityID
	if err := s.repo.WriteAudit(ctx, adminID, action, entity, &id, summary); err != nil {
		log.Printf("runs: audit write failed (%s %s): %v", action, entity, err)
	}
}

func (s *AdminService) List(ctx context.Context, assignmentID int64) ([]AdminTest, error) {
	return s.repo.AdminTestsForAssignment(ctx, assignmentID)
}

func (s *AdminService) Create(ctx context.Context, adminID, assignmentID int64, req CreateTestRequest) (AdminTest, error) {
	a, err := s.assign.GetAnyByID(ctx, assignmentID)
	if err != nil {
		return AdminTest{}, ErrAssignmentNotFound
	}
	if a.AssignmentType != assignments.TypeCode {
		return AdminTest{}, ErrNotCodeAssignment
	}
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return AdminTest{}, invalid("name is required")
	}
	weight := 1
	if req.Weight != nil {
		weight = *req.Weight
	}
	if weight < 1 {
		return AdminTest{}, invalid("weight must be at least 1")
	}
	position := 0
	if req.Position != nil {
		position = *req.Position
	}
	hidden := false
	if req.IsHidden != nil {
		hidden = *req.IsHidden
	}
	t, err := s.repo.CreateTest(ctx, assignmentID, name, req.Stdin, req.ExpectedStdout, hidden, weight, position)
	if err != nil {
		return AdminTest{}, err
	}
	s.audit(ctx, adminID, "create", "assignment_test", t.ID, name)
	return t, nil
}

func (s *AdminService) Update(ctx context.Context, adminID, id int64, req UpdateTestRequest) (AdminTest, error) {
	fields := map[string]any{}
	if req.Name != nil {
		n := strings.TrimSpace(*req.Name)
		if n == "" {
			return AdminTest{}, invalid("name cannot be empty")
		}
		fields["name"] = n
	}
	if req.Stdin != nil {
		fields["stdin"] = *req.Stdin
	}
	if req.ExpectedStdout != nil {
		fields["expected_stdout"] = *req.ExpectedStdout
	}
	if req.IsHidden != nil {
		fields["is_hidden"] = *req.IsHidden
	}
	if req.Weight != nil {
		if *req.Weight < 1 {
			return AdminTest{}, invalid("weight must be at least 1")
		}
		fields["weight"] = *req.Weight
	}
	if req.Position != nil {
		fields["position"] = *req.Position
	}
	t, err := s.repo.UpdateTest(ctx, id, fields)
	if err != nil {
		return AdminTest{}, err
	}
	s.audit(ctx, adminID, "update", "assignment_test", t.ID, t.Name)
	return t, nil
}

func (s *AdminService) Delete(ctx context.Context, adminID, id int64) error {
	if err := s.repo.DeleteTest(ctx, id); err != nil {
		return err
	}
	s.audit(ctx, adminID, "delete", "assignment_test", id, "test "+strconv.FormatInt(id, 10))
	return nil
}
