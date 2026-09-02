package users

// Response is the public JSON shape for a user. It never includes the
// password hash.
type Response struct {
	ID        int64   `json:"id"`
	Email     *string `json:"email"`
	Phone     *string `json:"phone"`
	FirstName string  `json:"firstName"`
	LastName  *string `json:"lastName"`
	Role      Role    `json:"role"`
	IsActive  bool    `json:"isActive"`
}

// ToResponse maps an internal User to its public shape.
func ToResponse(u User) Response {
	return Response{
		ID:        u.ID,
		Email:     u.Email,
		Phone:     u.Phone,
		FirstName: u.FirstName,
		LastName:  u.LastName,
		Role:      u.Role,
		IsActive:  u.IsActive,
	}
}
