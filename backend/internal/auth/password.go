package auth

import "golang.org/x/crypto/bcrypt"

// minPasswordLen is the only password policy for this MVP: at least 8
// characters. Anything shorter (or empty) is rejected before hashing.
const minPasswordLen = 8

// hashPassword returns the bcrypt hash of a plain password. The plain
// password is never stored or logged anywhere.
func hashPassword(plain string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// checkPassword reports whether plain matches the stored bcrypt hash.
func checkPassword(hash, plain string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(plain)) == nil
}
