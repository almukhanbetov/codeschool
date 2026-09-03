package quizzes

// Pure scoring — no DB, no HTTP — so the rules are unit-tested in isolation
// (spec §31, §81, §82). The service feeds it question point values, the
// correct option set and the student's selected option set.

// gradedQuestion is the scoring input for one question.
type gradedQuestion struct {
	QuestionID  int64
	Points      int
	Type        string
	CorrectIDs  []int64
	SelectedIDs []int64
}

// questionResult is the scoring output for one question.
type questionResult struct {
	QuestionID    int64
	IsCorrect     bool
	PointsAwarded int
}

// quizScore is the whole-attempt scoring output.
type quizScore struct {
	Score    int
	MaxScore int
	Percent  int
	Results  map[int64]questionResult
}

// gradeQuestion applies strict scoring (spec §32–§34): the student earns the
// question's points only if their selected option set exactly equals the
// correct option set. No partial credit. A question with no correct answer
// key can never be earned.
func gradeQuestion(q gradedQuestion) questionResult {
	res := questionResult{QuestionID: q.QuestionID}
	if len(q.CorrectIDs) == 0 {
		return res
	}
	if sameSet(q.CorrectIDs, q.SelectedIDs) {
		res.IsCorrect = true
		res.PointsAwarded = q.Points
	}
	return res
}

// gradeQuiz scores every question and totals it up.
func gradeQuiz(questions []gradedQuestion) quizScore {
	out := quizScore{Results: make(map[int64]questionResult, len(questions))}
	for _, q := range questions {
		r := gradeQuestion(q)
		out.Results[q.QuestionID] = r
		out.Score += r.PointsAwarded
		out.MaxScore += q.Points
	}
	out.Percent = percentOf(out.Score, out.MaxScore)
	return out
}

// percentOf is score/max as a 0–100 int, guarding division by zero (spec §35).
func percentOf(score, max int) int {
	if max <= 0 {
		return 0
	}
	return score * 100 / max
}

// isPass is percent >= passPercent (spec §36).
func isPass(percent, passPercent int) bool {
	return percent >= passPercent
}

func toSet(in []int64) map[int64]bool {
	out := make(map[int64]bool, len(in))
	for _, v := range in {
		out[v] = true
	}
	return out
}

// sameSet compares two id slices as sets (order- and duplicate-insensitive).
func sameSet(a, b []int64) bool {
	sa, sb := toSet(a), toSet(b)
	if len(sa) != len(sb) {
		return false
	}
	for k := range sa {
		if !sb[k] {
			return false
		}
	}
	return true
}
