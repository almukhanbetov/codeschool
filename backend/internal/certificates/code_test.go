package certificates

import (
	"regexp"
	"testing"
)

var (
	reCode   = regexp.MustCompile(`^[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$`)
	reNumber = regexp.MustCompile(`^CS-20\d\d-\d{6}-[0-9A-HJKMNP-TV-Z]{4}$`)
)

func TestVerificationCode_FormatAndUniqueness(t *testing.T) {
	seen := map[string]bool{}
	for i := 0; i < 5000; i++ {
		code, err := newVerificationCode()
		if err != nil {
			t.Fatalf("newVerificationCode: %v", err)
		}
		if !reCode.MatchString(code) {
			t.Fatalf("code %q does not match expected format", code)
		}
		if seen[code] {
			t.Fatalf("duplicate verification code generated: %q", code)
		}
		seen[code] = true
	}
}

func TestCertificateNumber_Format(t *testing.T) {
	seen := map[string]bool{}
	for seq := 1; seq <= 2000; seq++ {
		n, err := newCertificateNumber(2026, seq)
		if err != nil {
			t.Fatalf("newCertificateNumber: %v", err)
		}
		if !reNumber.MatchString(n) {
			t.Fatalf("number %q does not match expected format", n)
		}
		if seen[n] {
			t.Fatalf("duplicate certificate number: %q", n)
		}
		seen[n] = true
	}
}

func TestNormalizeCode(t *testing.T) {
	if got := normalizeCode("  8jfk-2pqm-x7na-94kd \n"); got != "8JFK-2PQM-X7NA-94KD" {
		t.Fatalf("normalizeCode = %q", got)
	}
}

func TestCodeAlphabet_NoAmbiguousChars(t *testing.T) {
	for _, bad := range []rune{'I', 'L', 'O', 'U'} {
		for _, c := range codeAlphabet {
			if c == bad {
				t.Fatalf("alphabet contains ambiguous character %q", bad)
			}
		}
	}
}
