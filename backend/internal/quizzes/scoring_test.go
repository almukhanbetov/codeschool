package quizzes

import "testing"

func TestGradeQuestion_SingleChoice(t *testing.T) {
	q := gradedQuestion{QuestionID: 1, Points: 10, Type: QuestionSingleChoice, CorrectIDs: []int64{2}}

	// correct
	if r := gradeQuestion(mut(q, []int64{2})); !r.IsCorrect || r.PointsAwarded != 10 {
		t.Fatalf("single correct: %+v", r)
	}
	// wrong
	if r := gradeQuestion(mut(q, []int64{3})); r.IsCorrect || r.PointsAwarded != 0 {
		t.Fatalf("single wrong: %+v", r)
	}
	// unanswered
	if r := gradeQuestion(mut(q, nil)); r.IsCorrect || r.PointsAwarded != 0 {
		t.Fatalf("single unanswered: %+v", r)
	}
}

func TestGradeQuestion_TrueFalse(t *testing.T) {
	q := gradedQuestion{QuestionID: 1, Points: 5, Type: QuestionTrueFalse, CorrectIDs: []int64{9}}
	if r := gradeQuestion(mut(q, []int64{9})); !r.IsCorrect || r.PointsAwarded != 5 {
		t.Fatalf("true/false correct: %+v", r)
	}
	if r := gradeQuestion(mut(q, []int64{8})); r.IsCorrect {
		t.Fatalf("true/false wrong: %+v", r)
	}
}

func TestGradeQuestion_MultipleChoiceStrict(t *testing.T) {
	q := gradedQuestion{QuestionID: 1, Points: 10, Type: QuestionMultipleChoice, CorrectIDs: []int64{2, 4}}

	cases := []struct {
		name     string
		selected []int64
		want     bool
	}{
		{"exact match", []int64{2, 4}, true},
		{"exact match reordered", []int64{4, 2}, true},
		{"partial", []int64{2}, false},
		{"extra wrong", []int64{2, 4, 5}, false},
		{"all wrong", []int64{5, 6}, false},
		{"empty", nil, false},
		{"dupes still exact", []int64{2, 4, 4}, true},
	}
	for _, c := range cases {
		if r := gradeQuestion(mut(q, c.selected)); r.IsCorrect != c.want {
			t.Errorf("%s: got %v want %v", c.name, r.IsCorrect, c.want)
		}
	}
}

func TestGradeQuestion_NoAnswerKeyNeverEarned(t *testing.T) {
	q := gradedQuestion{QuestionID: 1, Points: 10, Type: QuestionMultipleChoice, CorrectIDs: nil, SelectedIDs: []int64{1}}
	if r := gradeQuestion(q); r.IsCorrect || r.PointsAwarded != 0 {
		t.Fatalf("no key: %+v", r)
	}
}

func TestGradeQuiz_TotalsAndPercent(t *testing.T) {
	qs := []gradedQuestion{
		{QuestionID: 1, Points: 4, Type: QuestionSingleChoice, CorrectIDs: []int64{1}, SelectedIDs: []int64{1}},         // +4
		{QuestionID: 2, Points: 4, Type: QuestionSingleChoice, CorrectIDs: []int64{2}, SelectedIDs: []int64{9}},         // +0
		{QuestionID: 3, Points: 2, Type: QuestionMultipleChoice, CorrectIDs: []int64{3, 4}, SelectedIDs: []int64{3, 4}}, // +2
	}
	got := gradeQuiz(qs)
	if got.Score != 6 || got.MaxScore != 10 || got.Percent != 60 {
		t.Fatalf("got score=%d max=%d pct=%d", got.Score, got.MaxScore, got.Percent)
	}
}

func TestPercentOf_ZeroMaxScore(t *testing.T) {
	if p := percentOf(0, 0); p != 0 {
		t.Fatalf("zero max should be 0%%, got %d", p)
	}
	if p := percentOf(8, 10); p != 80 {
		t.Fatalf("8/10 should be 80, got %d", p)
	}
}

func TestIsPass_Threshold(t *testing.T) {
	if !isPass(70, 70) {
		t.Fatal("70 >= 70 must pass")
	}
	if isPass(69, 70) {
		t.Fatal("69 < 70 must fail")
	}
	if !isPass(100, 0) {
		t.Fatal("any percent passes a 0 threshold")
	}
}

func mut(q gradedQuestion, selected []int64) gradedQuestion {
	q.SelectedIDs = selected
	return q
}
