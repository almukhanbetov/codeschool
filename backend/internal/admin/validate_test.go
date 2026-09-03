package admin

import (
	"errors"
	"testing"
)

func TestCanRemoveAdminPrivilege(t *testing.T) {
	cases := []struct {
		name              string
		target, actor     int64
		targetActiveAdmin bool
		otherAdmins       int
		want              error
	}{
		{"self", 5, 5, false, 3, ErrSelfMutation},
		{"self even as admin", 5, 5, true, 3, ErrSelfMutation},
		{"last admin", 5, 1, true, 0, ErrLastAdmin},
		{"admin but others exist", 5, 1, true, 2, nil},
		{"not an admin", 5, 1, false, 0, nil},
	}
	for _, c := range cases {
		got := canRemoveAdminPrivilege(c.target, c.actor, c.targetActiveAdmin, c.otherAdmins)
		if !errors.Is(got, c.want) {
			t.Errorf("%s: got %v, want %v", c.name, got, c.want)
		}
	}
}

func TestValidateNewUser(t *testing.T) {
	e := func(s string) *string { return &s }
	base := CreateUserRequest{Password: "password123", FirstName: "A", Role: "student", Email: e("a@b.c")}

	if err := validateNewUser(base); err != nil {
		t.Fatalf("valid request rejected: %v", err)
	}
	bad := []CreateUserRequest{
		{Password: "short", FirstName: "A", Role: "student", Email: e("a@b.c")},
		{Password: "password123", FirstName: "  ", Role: "student", Email: e("a@b.c")},
		{Password: "password123", FirstName: "A", Role: "wizard", Email: e("a@b.c")},
		{Password: "password123", FirstName: "A", Role: "student"}, // no email or phone
	}
	for i, req := range bad {
		var ve *ValidationError
		if !errors.As(validateNewUser(req), &ve) {
			t.Errorf("case %d: expected a ValidationError", i)
		}
	}
	// admin role IS allowed for admin-created users
	if err := validateNewUser(CreateUserRequest{Password: "password123", FirstName: "Root", Role: "admin", Phone: e("+77000000000")}); err != nil {
		t.Errorf("admin role should be allowed: %v", err)
	}
}

func TestUpdateFieldsBuilders(t *testing.T) {
	s := func(v string) *string { return &v }
	i := func(v int) *int { return &v }
	b := func(v bool) *bool { return &v }

	// only provided fields land in the map; nullable "" collapses to nil
	f := UpdateCourseRequest{Title: s("  New  "), Description: s("  "), IsPublished: b(true), Position: i(3)}.fields()
	if f["title"] != "New" {
		t.Errorf("title not trimmed: %v", f["title"])
	}
	if v, ok := f["description"]; !ok || v != (*string)(nil) {
		t.Errorf("empty description should map to nil, got %#v (present=%v)", v, ok)
	}
	if f["is_published"] != true || f["position"] != 3 {
		t.Errorf("bool/int not carried: %#v", f)
	}
	if _, ok := f["slug"]; ok {
		t.Error("absent field must not be in the map")
	}

	// an empty patch produces only the implicit updated_at (empty map here)
	if len(UpdateProgramRequest{}.fields()) != 0 {
		t.Error("empty patch should yield an empty field map")
	}
}

func TestNormStr(t *testing.T) {
	s := func(v string) *string { return &v }
	if normStr(nil) != nil {
		t.Error("nil stays nil")
	}
	if normStr(s("   ")) != nil {
		t.Error("whitespace collapses to nil")
	}
	if v := normStr(s("  hi ")); v == nil || *v != "hi" {
		t.Errorf("expected trimmed 'hi', got %v", v)
	}
}
