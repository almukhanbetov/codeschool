package certificates

import (
	"bytes"
	_ "embed"
	"fmt"
	"time"

	"github.com/go-pdf/fpdf"
	"rsc.io/qr"
)

//go:embed assets/DejaVuSerif.ttf
var fontSerifRegular []byte

//go:embed assets/DejaVuSerif-Bold.ttf
var fontSerifBold []byte

// defaultRenderer draws the certificate with go-pdf/fpdf — a pure-Go,
// dependency-free PDF generator. Cyrillic is handled by the embedded
// DejaVu Serif TrueType font (no system fonts required at runtime).
type defaultRenderer struct{}

type pdfStrings struct {
	title       string
	certifies   string
	completed   string
	completedOn string
	issuedOn    string
	numberLabel string
	codeLabel   string
	verifyLabel string
}

func stringsFor(lang string) pdfStrings {
	switch lang {
	case "kz":
		return pdfStrings{
			title:       "СЕРТИФИКАТ",
			certifies:   "Осы сертификат мынаны растайды:",
			completed:   "оқу курсын толық аяқтады",
			completedOn: "Аяқталған күні",
			issuedOn:    "Берілген күні",
			numberLabel: "Сертификат нөмірі",
			codeLabel:   "Растау коды",
			verifyLabel: "Тексеру",
		}
	case "en":
		return pdfStrings{
			title:       "CERTIFICATE OF COMPLETION",
			certifies:   "This is to certify that",
			completed:   "has successfully completed the course",
			completedOn: "Completed on",
			issuedOn:    "Issued on",
			numberLabel: "Certificate No.",
			codeLabel:   "Verification code",
			verifyLabel: "Verify at",
		}
	default: // ru
		return pdfStrings{
			title:       "СЕРТИФИКАТ",
			certifies:   "Настоящим подтверждается, что",
			completed:   "успешно завершил(а) курс",
			completedOn: "Дата завершения",
			issuedOn:    "Дата выдачи",
			numberLabel: "Номер сертификата",
			codeLabel:   "Код проверки",
			verifyLabel: "Проверка",
		}
	}
}

func fmtDate(t time.Time) string {
	return t.UTC().Format("02.01.2006")
}

// Render produces an application/pdf byte slice for the certificate.
func (defaultRenderer) Render(c Certificate, verifyURL, lang string) ([]byte, error) {
	s := stringsFor(lang)

	pdf := fpdf.New("L", "mm", "A4", "")
	pdf.SetAutoPageBreak(false, 0)
	pdf.AddUTF8FontFromBytes("DejaVu", "", fontSerifRegular)
	pdf.AddUTF8FontFromBytes("DejaVu", "B", fontSerifBold)
	pdf.SetTitle("Certificate "+c.CertificateNumber, true)
	pdf.SetSubject(c.CourseTitle, true)
	pdf.SetCreator("CODESCHOOL", true)
	pdf.AddPage()

	const pageW = 297.0

	// decorative double border
	pdf.SetDrawColor(38, 70, 140)
	pdf.SetLineWidth(1.2)
	pdf.Rect(10, 10, pageW-20, 210-20, "D")
	pdf.SetLineWidth(0.3)
	pdf.Rect(13, 13, pageW-26, 210-26, "D")

	centered := func(y, h float64, family, style string, size float64, txt string) {
		pdf.SetFont(family, style, size)
		pdf.SetXY(0, y)
		pdf.CellFormat(pageW, h, txt, "", 0, "C", false, 0, "")
	}

	pdf.SetTextColor(38, 70, 140)
	centered(24, 12, "DejaVu", "B", 30, "CODESCHOOL")

	pdf.SetTextColor(40, 40, 40)
	centered(44, 10, "DejaVu", "B", 20, s.title)

	pdf.SetDrawColor(200, 200, 200)
	pdf.SetLineWidth(0.4)
	pdf.Line(pageW/2-40, 60, pageW/2+40, 60)

	centered(70, 8, "DejaVu", "", 13, s.certifies)
	centered(82, 14, "DejaVu", "B", 30, c.LearnerName)
	centered(100, 8, "DejaVu", "", 13, s.completed)

	// course title — wrap if long
	pdf.SetFont("DejaVu", "B", 18)
	pdf.SetTextColor(38, 70, 140)
	pdf.SetXY(30, 112)
	pdf.MultiCell(pageW-60, 9, c.CourseTitle, "", "C", false)

	pdf.SetTextColor(60, 60, 60)
	centered(138, 7, "DejaVu", "", 12, fmt.Sprintf("%s: %s", s.completedOn, fmtDate(c.CompletedAt)))

	// footer block: identifiers on the left, QR on the right
	footerY := 165.0
	pdf.SetFont("DejaVu", "", 10)
	pdf.SetTextColor(70, 70, 70)
	left := 24.0
	line := func(i float64, txt string) {
		pdf.SetXY(left, footerY+i*6)
		pdf.CellFormat(150, 6, txt, "", 0, "L", false, 0, "")
	}
	line(0, fmt.Sprintf("%s: %s", s.numberLabel, c.CertificateNumber))
	line(1, fmt.Sprintf("%s: %s", s.codeLabel, c.VerificationCode))
	line(2, fmt.Sprintf("%s: %s", s.verifyLabel, verifyURL))
	line(3, fmt.Sprintf("%s: %s", s.issuedOn, fmtDate(c.IssuedAt)))

	if png, err := qrPNG(verifyURL); err == nil {
		opt := fpdf.ImageOptions{ImageType: "PNG", ReadDpi: false}
		pdf.RegisterImageOptionsReader("qr", opt, bytes.NewReader(png))
		pdf.ImageOptions("qr", pageW-24-30, footerY-4, 30, 30, false, opt, 0, "")
	}

	var buf bytes.Buffer
	if err := pdf.Output(&buf); err != nil {
		return nil, fmt.Errorf("render certificate pdf: %w", err)
	}
	return buf.Bytes(), nil
}

// qrPNG encodes the public verification URL as a QR-code PNG. Only the URL
// is encoded — never any private data.
func qrPNG(url string) ([]byte, error) {
	code, err := qr.Encode(url, qr.M)
	if err != nil {
		return nil, err
	}
	return code.PNG(), nil
}
