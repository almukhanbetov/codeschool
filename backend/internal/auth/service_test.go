package auth

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"codeschool/backend/internal/users"
)

// ---- fakes -------------------------------------------------------------

type fakeUsers struct {
	rows   []users.User
	nextID int64
}

func newFakeUsers() *fakeUsers { return &fakeUsers{nextID: 1} }

func (f *fakeUsers) Create(_ context.Context, in users.NewUser) (users.User, error) {
	for _, u := range f.rows {
		if in.Email != nil && u.Email != nil && strings.EqualFold(*u.Email, *in.Email) {
			return users.User{}, users.ErrDuplicateEmail
		}
		if in.Phone != nil && u.Phone != nil && *u.Phone == *in.Phone {
			return users.User{}, users.ErrDuplicatePhone
		}
	}
	u := users.User{
		ID: f.nextID, Email: in.Email, Phone: in.Phone, PasswordHash: in.PasswordHash,
		FirstName: in.FirstName, LastName: in.LastName, Role: in.Role, IsActive: true,
	}
	f.nextID++
	f.rows = append(f.rows, u)
	return u, nil
}

func (f *fakeUsers) FindByEmail(_ context.Context, email string) (users.User, error) {
	for _, u := range f.rows {
		if u.Email != nil && strings.EqualFold(*u.Email, email) {
			return u, nil
		}
	}
	return users.User{}, users.ErrNotFound
}

func (f *fakeUsers) FindByPhone(_ context.Context, phone string) (users.User, error) {
	for _, u := range f.rows {
		if u.Phone != nil && *u.Phone == phone {
			return u, nil
		}
	}
	return users.User{}, users.ErrNotFound
}

func (f *fakeUsers) FindByID(_ context.Context, id int64) (users.User, error) {
	for _, u := range f.rows {
		if u.ID == id {
			return u, nil
		}
	}
	return users.User{}, users.ErrNotFound
}

func (f *fakeUsers) setActive(id int64, active bool) {
	for i := range f.rows {
		if f.rows[i].ID == id {
			f.rows[i].IsActive = active
		}
	}
}

type fakeRefresh struct {
	rows   map[string]*RefreshToken
	nextID int64
}

func newFakeRefresh() *fakeRefresh {
	return &fakeRefresh{rows: map[string]*RefreshToken{}, nextID: 1}
}

func (f *fakeRefresh) CreateRefreshToken(_ context.Context, userID int64, hash string, exp time.Time) (RefreshToken, error) {
	rt := RefreshToken{ID: f.nextID, UserID: userID, TokenHash: hash, ExpiresAt: exp, CreatedAt: time.Now()}
	f.nextID++
	f.rows[hash] = &rt
	return rt, nil
}

func (f *fakeRefresh) GetRefreshTokenByHash(_ context.Context, hash string) (RefreshToken, error) {
	rt, ok := f.rows[hash]
	if !ok {
		return RefreshToken{}, ErrRefreshNotFound
	}
	return *rt, nil
}

func (f *fakeRefresh) RevokeRefreshToken(_ context.Context, hash string) error {
	if rt, ok := f.rows[hash]; ok && rt.RevokedAt == nil {
		now := time.Now()
		rt.RevokedAt = &now
	}
	return nil
}

func (f *fakeRefresh) RotateRefreshToken(_ context.Context, oldHash string, userID int64, newHash string, exp time.Time) (RefreshToken, error) {
	rt, ok := f.rows[oldHash]
	if !ok || rt.RevokedAt != nil {
		return RefreshToken{}, ErrInvalidRefreshToken
	}
	now := time.Now()
	rt.RevokedAt = &now
	return f.CreateRefreshToken(context.Background(), userID, newHash, exp)
}

// ---- helpers ---------------------------------------------------------

func newTestService() (*Service, *fakeUsers, *fakeRefresh) {
	fu := newFakeUsers()
	fr := newFakeRefresh()
	tm := NewTokenManager("test-secret", 15*time.Minute, 720*time.Hour)
	return NewService(fu, fr, tm), fu, fr
}

func strptr(s string) *string { return &s }

func validRegister() RegisterRequest {
	return RegisterRequest{
		Email:     strptr("student@example.com"),
		Password:  "password123",
		FirstName: "Ayan",
		LastName:  strptr("Test"),
		Role:      "student",
	}
}

// ---- register ------------------------------------------------------

func TestRegister_Success(t *testing.T) {
	svc, _, _ := newTestService()
	u, err := svc.Register(context.Background(), validRegister())
	if err != nil {
		t.Fatalf("Register: %v", err)
	}
	if u.ID == 0 || u.Role != users.RoleStudent || *u.Email != "student@example.com" {
		t.Fatalf("unexpected user: %+v", u)
	}
	if u.PasswordHash == "password123" || u.PasswordHash == "" {
		t.Error("password was not hashed")
	}
}

func TestRegister_WithPhoneOnly(t *testing.T) {
	svc, _, _ := newTestService()
	u, err := svc.Register(context.Background(), RegisterRequest{
		Phone: strptr("+77001234567"), Password: "password123", FirstName: "Ayan", Role: "parent",
	})
	if err != nil {
		t.Fatalf("Register: %v", err)
	}
	if u.Email != nil || u.Phone == nil {
		t.Fatalf("expected phone-only user, got %+v", u)
	}
}

func TestRegister_RequiresEmailOrPhone(t *testing.T) {
	svc, _, _ := newTestService()
	req := validRegister()
	req.Email = strptr("   ") // whitespace collapses to nil
	_, err := svc.Register(context.Background(), req)
	assertValidation(t, err)
}

func TestRegister_ShortPassword(t *testing.T) {
	svc, _, _ := newTestService()
	req := validRegister()
	req.Password = "short"
	_, err := svc.Register(context.Background(), req)
	assertValidation(t, err)
}

func TestRegister_EmptyPassword(t *testing.T) {
	svc, _, _ := newTestService()
	req := validRegister()
	req.Password = ""
	_, err := svc.Register(context.Background(), req)
	assertValidation(t, err)
}

func TestRegister_CannotBeAdmin(t *testing.T) {
	svc, _, _ := newTestService()
	req := validRegister()
	req.Role = "admin"
	_, err := svc.Register(context.Background(), req)
	assertValidation(t, err)
}

func TestRegister_InvalidRole(t *testing.T) {
	svc, _, _ := newTestService()
	req := validRegister()
	req.Role = "wizard"
	_, err := svc.Register(context.Background(), req)
	assertValidation(t, err)
}

func TestRegister_DuplicateEmail(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatalf("first register: %v", err)
	}
	dup := validRegister()
	dup.Email = strptr("STUDENT@example.com") // case-insensitive match
	_, err := svc.Register(context.Background(), dup)
	if !errors.Is(err, ErrDuplicateEmail) {
		t.Fatalf("expected ErrDuplicateEmail, got %v", err)
	}
}

func TestRegister_DuplicatePhone(t *testing.T) {
	svc, _, _ := newTestService()
	base := RegisterRequest{Phone: strptr("+77001234567"), Password: "password123", FirstName: "A", Role: "student"}
	if _, err := svc.Register(context.Background(), base); err != nil {
		t.Fatalf("first register: %v", err)
	}
	_, err := svc.Register(context.Background(), base)
	if !errors.Is(err, ErrDuplicatePhone) {
		t.Fatalf("expected ErrDuplicatePhone, got %v", err)
	}
}

// ---- login --------------------------------------------------------

func TestLogin_Success(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatal(err)
	}
	res, err := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})
	if err != nil {
		t.Fatalf("Login: %v", err)
	}
	if res.AccessToken == "" || res.RefreshToken == "" {
		t.Fatal("expected both tokens to be issued")
	}
	if res.ExpiresInSecs <= 0 {
		t.Errorf("expiresIn should be positive, got %d", res.ExpiresInSecs)
	}
}

func TestLogin_WrongPassword(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatal(err)
	}
	_, err := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "nope-nope"})
	if !errors.Is(err, ErrInvalidCredentials) {
		t.Fatalf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestLogin_UnknownAccount_SameError(t *testing.T) {
	svc, _, _ := newTestService()
	_, err := svc.Login(context.Background(), LoginRequest{Email: strptr("ghost@example.com"), Password: "password123"})
	if !errors.Is(err, ErrInvalidCredentials) {
		t.Fatalf("expected ErrInvalidCredentials (no user enumeration), got %v", err)
	}
}

func TestLogin_InactiveRejected(t *testing.T) {
	svc, fu, _ := newTestService()
	u, _ := svc.Register(context.Background(), validRegister())
	fu.setActive(u.ID, false)
	_, err := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})
	if !errors.Is(err, ErrUserInactive) {
		t.Fatalf("expected ErrUserInactive, got %v", err)
	}
}

// ---- refresh -----------------------------------------------------

func TestRefresh_RotatesAndInvalidatesOldToken(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatal(err)
	}
	login, _ := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})

	next, err := svc.Refresh(context.Background(), login.RefreshToken)
	if err != nil {
		t.Fatalf("Refresh: %v", err)
	}
	if next.RefreshToken == "" || next.RefreshToken == login.RefreshToken {
		t.Fatal("expected a new, different refresh token")
	}
	if next.AccessToken == "" {
		t.Fatal("expected a new access token")
	}

	// The original token must no longer work (rotation).
	if _, err := svc.Refresh(context.Background(), login.RefreshToken); !errors.Is(err, ErrInvalidRefreshToken) {
		t.Fatalf("expected the rotated-out token to be rejected, got %v", err)
	}
	// The new token works.
	if _, err := svc.Refresh(context.Background(), next.RefreshToken); err != nil {
		t.Fatalf("new token should still refresh: %v", err)
	}
}

func TestRefresh_RevokedRejected(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatal(err)
	}
	login, _ := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})

	if err := svc.Logout(context.Background(), login.RefreshToken); err != nil {
		t.Fatalf("Logout: %v", err)
	}
	if _, err := svc.Refresh(context.Background(), login.RefreshToken); !errors.Is(err, ErrInvalidRefreshToken) {
		t.Fatalf("expected revoked token to be rejected, got %v", err)
	}
}

func TestRefresh_ExpiredRejected(t *testing.T) {
	fu := newFakeUsers()
	fr := newFakeRefresh()
	tm := NewTokenManager("s", time.Minute, time.Millisecond)
	svc := NewService(fu, fr, tm)
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatal(err)
	}
	login, _ := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})
	time.Sleep(5 * time.Millisecond)
	if _, err := svc.Refresh(context.Background(), login.RefreshToken); !errors.Is(err, ErrInvalidRefreshToken) {
		t.Fatalf("expected expired token to be rejected, got %v", err)
	}
}

func TestRefresh_UnknownRejected(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Refresh(context.Background(), "totally-made-up"); !errors.Is(err, ErrInvalidRefreshToken) {
		t.Fatalf("expected ErrInvalidRefreshToken, got %v", err)
	}
}

func TestRefresh_InactiveUserRejected(t *testing.T) {
	svc, fu, _ := newTestService()
	u, _ := svc.Register(context.Background(), validRegister())
	login, _ := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})
	fu.setActive(u.ID, false)
	if _, err := svc.Refresh(context.Background(), login.RefreshToken); !errors.Is(err, ErrUserInactive) {
		t.Fatalf("expected ErrUserInactive, got %v", err)
	}
}

// ---- logout ------------------------------------------------------

func TestLogout_Idempotent(t *testing.T) {
	svc, _, _ := newTestService()
	if _, err := svc.Register(context.Background(), validRegister()); err != nil {
		t.Fatal(err)
	}
	login, _ := svc.Login(context.Background(), LoginRequest{Email: strptr("student@example.com"), Password: "password123"})

	for i := 0; i < 3; i++ {
		if err := svc.Logout(context.Background(), login.RefreshToken); err != nil {
			t.Fatalf("logout #%d returned error: %v", i, err)
		}
	}
	// Logout with no token is also fine.
	if err := svc.Logout(context.Background(), ""); err != nil {
		t.Fatalf("empty logout: %v", err)
	}
}

func assertValidation(t *testing.T, err error) {
	t.Helper()
	var ve *ValidationError
	if !errors.As(err, &ve) {
		t.Fatalf("expected *ValidationError, got %T: %v", err, err)
	}
}
