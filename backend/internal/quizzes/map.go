package quizzes

func toAttemptBrief(a Attempt) AttemptBrief {
	return AttemptBrief{
		ID:          a.ID,
		Status:      a.Status,
		StartedAt:   a.StartedAt,
		SubmittedAt: a.SubmittedAt,
	}
}

// toStudentQuiz strips every question/option down to what a student may see
// before submitting: no `isCorrect`, no `explanation` (spec §7, §22, §84).
func toStudentQuiz(meta assignmentMeta, settings Settings, questions []Question) StudentQuiz {
	out := StudentQuiz{
		AssignmentID: meta.AssignmentID,
		Title:        meta.Title,
		PassPercent:  settings.PassPercent,
		Questions:    make([]StudentQuestion, 0, len(questions)),
	}
	for _, q := range questions {
		sq := StudentQuestion{
			ID:           q.ID,
			QuestionText: q.Text,
			QuestionType: q.Type,
			Points:       q.Points,
			Position:     q.Position,
			Options:      make([]StudentOption, 0, len(q.Options)),
		}
		for _, o := range q.Options {
			if !o.IsActive {
				continue
			}
			sq.Options = append(sq.Options, StudentOption{
				ID:         o.ID,
				OptionText: o.Text,
				Position:   o.Position,
			})
		}
		out.Questions = append(out.Questions, sq)
	}
	return out
}

// buildResult assembles the post-submit review, honoring the settings that
// gate the answer key and explanations (spec §39, §40).
func buildResult(
	attempt Attempt,
	meta assignmentMeta,
	settings Settings,
	questions []Question,
	results map[int64]questionResult,
	selectedByQ map[int64][]int64,
) AttemptResult {
	score, maxScore, percent, passed := 0, 0, 0, false
	if attempt.Score != nil {
		score = *attempt.Score
	}
	if attempt.MaxScore != nil {
		maxScore = *attempt.MaxScore
	}
	if attempt.Percent != nil {
		percent = *attempt.Percent
	}
	if attempt.Passed != nil {
		passed = *attempt.Passed
	}

	out := AttemptResult{
		AttemptID:          attempt.ID,
		AssignmentID:       meta.AssignmentID,
		Status:             attempt.Status,
		Score:              score,
		MaxScore:           maxScore,
		Percent:            percent,
		Passed:             passed,
		PassPercent:        settings.PassPercent,
		SubmittedAt:        attempt.SubmittedAt,
		ShowCorrectAnswers: settings.ShowCorrectAnswers,
		Questions:          make([]ResultQuestion, 0, len(questions)),
	}

	for _, q := range questions {
		selected := toSet(selectedByQ[q.ID])
		r := results[q.ID]
		rq := ResultQuestion{
			QuestionID:    q.ID,
			QuestionText:  q.Text,
			QuestionType:  q.Type,
			Points:        q.Points,
			PointsAwarded: r.PointsAwarded,
			IsCorrect:     r.IsCorrect,
			Options:       make([]ResultOption, 0, len(q.Options)),
		}
		if settings.ShowExplanations {
			rq.Explanation = q.Explanation
		}
		for _, o := range q.Options {
			if !o.IsActive {
				continue
			}
			ro := ResultOption{
				ID:         o.ID,
				OptionText: o.Text,
				Position:   o.Position,
				Selected:   selected[o.ID],
			}
			if settings.ShowCorrectAnswers {
				v := o.IsCorrect
				ro.IsCorrect = &v
			}
			rq.Options = append(rq.Options, ro)
		}
		out.Questions = append(out.Questions, rq)
	}
	return out
}
