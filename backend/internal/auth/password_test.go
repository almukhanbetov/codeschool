package auth

import "testing"

func TestHashPassword_RoundTrips(t *testing.T) {
	hash, err := hashPassword("password123")
	if err != nil {
		t.Fatalf("hashPassword: %v", err)
	}
	if hash == "password123" || hash == "" {
		t.Fatalf("hash looks like plain text or empty: %q", hash)
	}
	if !checkPassword(hash, "password123") {
		t.Error("checkPassword rejected the correct password")
	}
	if checkPassword(hash, "wrong-password") {
		t.Error("checkPassword accepted an incorrect password")
	}
}

func TestHashPassword_DistinctSalts(t *testing.T) {
	h1, _ := hashPassword("password123")
	h2, _ := hashPassword("password123")
	if h1 == h2 {
		t.Error("expected different hashes for the same password (per-hash salt)")
	}
}
