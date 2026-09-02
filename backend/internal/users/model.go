package users

import "time"

// Role is one of the four fixed account roles.
type Role string

const (
	RoleStudent Role = "student"
	RoleTeacher Role = "teacher"
	RoleParent  Role = "parent"
	RoleAdmin   Role = "admin"
)

// AllRoles lists every valid role.
var AllRoles = []Role{RoleStudent, RoleTeacher, RoleParent, RoleAdmin}

// PublicRoles are the roles a visitor may pick during public registration —
// admin is deliberately excluded and can only be created by a seed or a
// future admin action.
var PublicRoles = []Role{RoleStudent, RoleTeacher, RoleParent}

func IsValidRole(r Role) bool {
	for _, v := range AllRoles {
		if v == r {
			return true
		}
	}
	return false
}

func IsPublicRole(r Role) bool {
	for _, v := range PublicRoles {
		if v == r {
			return true
		}
	}
	return false
}

// User is the internal representation of a row in the users table. Email and
// phone are pointers because either (but not both) may be absent; the app
// never stores an empty string in place of NULL.
type User struct {
	ID           int64
	Email        *string
	Phone        *string
	PasswordHash string
	FirstName    string
	LastName     *string
	Role         Role
	IsActive     bool
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

// NewUser holds the fields needed to insert a user. The password is already
// hashed by the caller — this struct never carries a plain password.
type NewUser struct {
	Email        *string
	Phone        *string
	PasswordHash string
	FirstName    string
	LastName     *string
	Role         Role
}
