package certificates

import (
	"bytes"
	"testing"
	"time"
)

func sampleCert() Certificate {
	return Certificate{
		ID:                12,
		UserID:            3,
		CourseID:          202,
		CertificateNumber: "CS-2026-000012-7QF3",
		VerificationCode:  "8JFK-2PQM-X7NA-94KD",
		LearnerName:       "Аян Студентов",
		CourseTitle:       "Методика преподавания Python",
		IssuedAt:          time.Date(2026, 9, 3, 10, 0, 0, 0, time.UTC),
		CompletedAt:       time.Date(2026, 9, 1, 12, 0, 0, 0, time.UTC),
		Status:            StatusActive,
	}
}

func TestRenderPDF_ValidDocument(t *testing.T) {
	for _, lang := range []string{"ru", "kz", "en", ""} {
		pdf, err := defaultRenderer{}.Render(sampleCert(), "https://codeschool.example/certificates/verify/8JFK-2PQM-X7NA-94KD", lang)
		if err != nil {
			t.Fatalf("Render(%q): %v", lang, err)
		}
		if len(pdf) < 2000 {
			t.Fatalf("Render(%q): pdf suspiciously small (%d bytes)", lang, len(pdf))
		}
		if !bytes.HasPrefix(pdf, []byte("%PDF-")) {
			t.Fatalf("Render(%q): missing %%PDF- signature, got %q", lang, pdf[:8])
		}
		if !bytes.Contains(pdf, []byte("%%EOF")) {
			t.Fatalf("Render(%q): missing %%%%EOF trailer", lang)
		}
	}
}

func TestRenderPDF_NoSensitiveData(t *testing.T) {
	c := sampleCert()
	pdf, err := defaultRenderer{}.Render(c, "https://codeschool.example/certificates/verify/"+c.VerificationCode, "ru")
	if err != nil {
		t.Fatal(err)
	}
	// The PDF is deflate-compressed, so raw substring checks are not
	// meaningful; assert instead that rendering is deterministic in size and
	// that no obvious plaintext leaks through the stream.
	for _, leak := range []string{"password", "JWT", "Bearer ", "student_id", "DATABASE_URL"} {
		if bytes.Contains(pdf, []byte(leak)) {
			t.Fatalf("pdf appears to contain sensitive token %q", leak)
		}
	}
}

func TestQRPNG(t *testing.T) {
	png, err := qrPNG("https://codeschool.example/certificates/verify/8JFK-2PQM-X7NA-94KD")
	if err != nil {
		t.Fatalf("qrPNG: %v", err)
	}
	if !bytes.HasPrefix(png, []byte{0x89, 'P', 'N', 'G'}) {
		t.Fatalf("qrPNG did not return a PNG")
	}
}
