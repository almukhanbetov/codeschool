package certificates

import (
	"crypto/rand"
	"fmt"
	"strings"
)

// codeAlphabet is Crockford base32 with the visually ambiguous letters
// (I, L, O, U) removed — safe to print on a certificate and read back.
const codeAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

// randomString returns n characters drawn uniformly from codeAlphabet using
// crypto/rand with rejection sampling (no modulo bias). Never math/rand.
func randomString(n int) (string, error) {
	// 248 = 31 * 8, the largest multiple of len(codeAlphabet) that fits in a
	// byte; bytes >= 248 are rejected so every character is equiprobable.
	const limit = 248
	out := make([]byte, 0, n)
	buf := make([]byte, 1)
	for len(out) < n {
		if _, err := rand.Read(buf); err != nil {
			return "", err
		}
		if buf[0] >= limit {
			continue
		}
		out = append(out, codeAlphabet[int(buf[0])%len(codeAlphabet)])
	}
	return string(out), nil
}

// newVerificationCode returns a cryptographically random public code such as
// "8JFK-2PQM-X7NA-94KD" — 16 characters (~79 bits of entropy). It is the
// sole security boundary for public verification.
func newVerificationCode() (string, error) {
	raw, err := randomString(16)
	if err != nil {
		return "", err
	}
	return raw[0:4] + "-" + raw[4:8] + "-" + raw[8:12] + "-" + raw[12:16], nil
}

// newCertificateNumber returns a human-readable identifier such as
// "CS-2026-000042-7QF3". The sequential middle segment is scoped to the
// year; the 4-character random suffix stops the number from being a
// trivially enumerable running counter. Verification never trusts this
// value alone — see newVerificationCode.
func newCertificateNumber(year, yearSeq int) (string, error) {
	suffix, err := randomString(4)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("CS-%d-%06d-%s", year, yearSeq, suffix), nil
}

// normalizeCode upper-cases and trims a verification code coming from a URL
// or form so lookups are case-insensitive.
func normalizeCode(s string) string {
	return strings.ToUpper(strings.TrimSpace(s))
}
