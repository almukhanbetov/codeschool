package auth

import (
	"testing"
	"time"
)

func TestAccessToken_SignAndParse(t *testing.T) {
	tm := NewTokenManager("test-secret", 15*time.Minute, time.Hour)

	token, exp, err := tm.GenerateAccessToken(42, "student")
	if err != nil {
		t.Fatalf("GenerateAccessToken: %v", err)
	}
	if !exp.After(time.Now()) {
		t.Fatal("expiry should be in the future")
	}

	id, role, err := tm.ParseAccessToken(token)
	if err != nil {
		t.Fatalf("ParseAccessToken: %v", err)
	}
	if id != 42 || role != "student" {
		t.Errorf("got (%d, %q), want (42, student)", id, role)
	}
}

func TestAccessToken_ExpiredRejected(t *testing.T) {
	tm := NewTokenManager("test-secret", time.Minute, time.Hour)
	// Mint a token that was already expired when issued.
	tm.now = func() time.Time { return time.Now().Add(-2 * time.Hour) }
	token, _, err := tm.GenerateAccessToken(1, "student")
	if err != nil {
		t.Fatalf("GenerateAccessToken: %v", err)
	}

	tm.now = time.Now
	if _, _, err := tm.ParseAccessToken(token); err == nil {
		t.Fatal("expected an expired token to be rejected")
	}
}

func TestAccessToken_WrongSecretRejected(t *testing.T) {
	signer := NewTokenManager("secret-a", time.Minute, time.Hour)
	verifier := NewTokenManager("secret-b", time.Minute, time.Hour)

	token, _, _ := signer.GenerateAccessToken(1, "admin")
	if _, _, err := verifier.ParseAccessToken(token); err == nil {
		t.Fatal("expected a token signed with a different secret to be rejected")
	}
}

func TestAccessToken_GarbageRejected(t *testing.T) {
	tm := NewTokenManager("s", time.Minute, time.Hour)
	for _, bad := range []string{"", "not-a-jwt", "a.b.c"} {
		if _, _, err := tm.ParseAccessToken(bad); err == nil {
			t.Errorf("expected %q to be rejected", bad)
		}
	}
}

func TestRefreshToken_HashIsStableAndOpaque(t *testing.T) {
	plain, hash, err := generateRefreshToken()
	if err != nil {
		t.Fatalf("generateRefreshToken: %v", err)
	}
	if plain == "" || hash == "" || plain == hash {
		t.Fatalf("unexpected token/hash: %q / %q", plain, hash)
	}
	if hashRefreshToken(plain) != hash {
		t.Error("hashRefreshToken is not stable for the same input")
	}

	plain2, _, _ := generateRefreshToken()
	if plain2 == plain {
		t.Error("expected two generated refresh tokens to differ")
	}
}
