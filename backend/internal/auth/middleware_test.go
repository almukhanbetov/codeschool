package auth

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/users"
)

func init() { gin.SetMode(gin.TestMode) }

func testRouter(tm *TokenManager, checker activeChecker) *gin.Engine {
	r := gin.New()
	authed := r.Group("")
	authed.Use(Middleware(tm, checker))
	authed.GET("/me", func(c *gin.Context) {
		id, _ := authctx.UserID(c)
		role, _ := authctx.Role(c)
		c.JSON(http.StatusOK, gin.H{"id": id, "role": role})
	})
	authed.GET("/admin/ping", RequireRole("admin"), func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	authed.GET("/staff/ping", RequireAnyRole("teacher", "admin"), func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	return r
}

func seedActiveUser(role users.Role) (*fakeUsers, int64) {
	fu := newFakeUsers()
	u, _ := fu.Create(context.Background(), users.NewUser{
		Email: strptr("u@example.com"), PasswordHash: "x", FirstName: "U", Role: role,
	})
	return fu, u.ID
}

func TestMiddleware_ValidTokenPasses(t *testing.T) {
	tm := NewTokenManager("s", 15*time.Minute, time.Hour)
	fu, id := seedActiveUser(users.RoleStudent)
	token, _, _ := tm.GenerateAccessToken(id, "student")

	req := httptest.NewRequest(http.MethodGet, "/me", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("want 200, got %d: %s", w.Code, w.Body)
	}
}

func TestMiddleware_MissingHeaderRejected(t *testing.T) {
	tm := NewTokenManager("s", 15*time.Minute, time.Hour)
	fu, _ := seedActiveUser(users.RoleStudent)

	req := httptest.NewRequest(http.MethodGet, "/me", nil)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("want 401, got %d", w.Code)
	}
}

func TestMiddleware_ExpiredTokenRejected(t *testing.T) {
	tm := NewTokenManager("s", time.Minute, time.Hour)
	fu, id := seedActiveUser(users.RoleStudent)
	tm.now = func() time.Time { return time.Now().Add(-time.Hour) }
	token, _, _ := tm.GenerateAccessToken(id, "student")
	tm.now = time.Now

	req := httptest.NewRequest(http.MethodGet, "/me", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("want 401 for expired token, got %d", w.Code)
	}
}

func TestMiddleware_InactiveUserRejected(t *testing.T) {
	tm := NewTokenManager("s", 15*time.Minute, time.Hour)
	fu, id := seedActiveUser(users.RoleStudent)
	fu.setActive(id, false)
	token, _, _ := tm.GenerateAccessToken(id, "student")

	req := httptest.NewRequest(http.MethodGet, "/me", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("want 401 for inactive user, got %d", w.Code)
	}
}

func TestRequireRole_StudentCannotReachAdminPing(t *testing.T) {
	tm := NewTokenManager("s", 15*time.Minute, time.Hour)
	fu, id := seedActiveUser(users.RoleStudent)
	token, _, _ := tm.GenerateAccessToken(id, "student")

	req := httptest.NewRequest(http.MethodGet, "/admin/ping", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Fatalf("want 403 for student on /admin/ping, got %d: %s", w.Code, w.Body)
	}
}

func TestRequireRole_AdminReachesAdminPing(t *testing.T) {
	tm := NewTokenManager("s", 15*time.Minute, time.Hour)
	fu, id := seedActiveUser(users.RoleAdmin)
	token, _, _ := tm.GenerateAccessToken(id, "admin")

	req := httptest.NewRequest(http.MethodGet, "/admin/ping", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("want 200 for admin on /admin/ping, got %d", w.Code)
	}
}

func TestRequireAnyRole_TeacherReachesStaffPing(t *testing.T) {
	tm := NewTokenManager("s", 15*time.Minute, time.Hour)
	fu, id := seedActiveUser(users.RoleTeacher)
	token, _, _ := tm.GenerateAccessToken(id, "teacher")

	req := httptest.NewRequest(http.MethodGet, "/staff/ping", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	testRouter(tm, fu).ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("want 200 for teacher on /staff/ping, got %d", w.Code)
	}
}
