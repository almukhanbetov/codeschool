package parents

import "context"

type repository interface {
	IsLinked(ctx context.Context, parentID, childID int64) (bool, error)
	ListChildren(ctx context.Context, parentID int64) ([]ChildListItem, error)
	ChildOverview(ctx context.Context, childID int64) (ChildOverview, error)
	ChildCourseDetail(ctx context.Context, childID, courseID int64) (ChildCourseDetail, error)
	Activity(ctx context.Context, childID int64) (ActivitySummary, error)
}

type Service struct {
	repo repository
}

func NewService(repo repository) *Service {
	return &Service{repo: repo}
}

// requireLinked is the single authorization gate: a parent may only ever
// read a child that is linked to them. An unlinked (or non-existent) child
// yields ErrChildNotFound so nothing about other users leaks.
func (s *Service) requireLinked(ctx context.Context, parentID, childID int64) error {
	linked, err := s.repo.IsLinked(ctx, parentID, childID)
	if err != nil {
		return err
	}
	if !linked {
		return ErrChildNotFound
	}
	return nil
}

func (s *Service) ListChildren(ctx context.Context, parentID int64) ([]ChildListItem, error) {
	return s.repo.ListChildren(ctx, parentID)
}

func (s *Service) GetChild(ctx context.Context, parentID, childID int64) (ChildOverview, error) {
	if err := s.requireLinked(ctx, parentID, childID); err != nil {
		return ChildOverview{}, err
	}
	return s.repo.ChildOverview(ctx, childID)
}

func (s *Service) GetChildCourse(ctx context.Context, parentID, childID, courseID int64) (ChildCourseDetail, error) {
	if err := s.requireLinked(ctx, parentID, childID); err != nil {
		return ChildCourseDetail{}, err
	}
	return s.repo.ChildCourseDetail(ctx, childID, courseID)
}

func (s *Service) GetChildActivity(ctx context.Context, parentID, childID int64) (ActivitySummary, error) {
	if err := s.requireLinked(ctx, parentID, childID); err != nil {
		return ActivitySummary{}, err
	}
	return s.repo.Activity(ctx, childID)
}
