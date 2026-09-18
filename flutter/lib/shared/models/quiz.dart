import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz.freezed.dart';
part 'quiz.g.dart';

/// Mirrors backend/internal/quizzes/dto.go `StudentOption` — never carries
/// `isCorrect` before submission (server-enforced, spec §7/§22/§84).
@freezed
abstract class StudentOption with _$StudentOption {
  const factory StudentOption({required int id, required String optionText, required int position}) = _StudentOption;
  factory StudentOption.fromJson(Map<String, dynamic> json) => _$StudentOptionFromJson(json);
}

@freezed
abstract class StudentQuestion with _$StudentQuestion {
  const factory StudentQuestion({
    required int id,
    required String questionText,
    required String questionType,
    required int points,
    required int position,
    @Default([]) List<StudentOption> options,
  }) = _StudentQuestion;
  factory StudentQuestion.fromJson(Map<String, dynamic> json) => _$StudentQuestionFromJson(json);
}

@freezed
abstract class StudentQuiz with _$StudentQuiz {
  const factory StudentQuiz({
    required int assignmentId,
    required String title,
    required int passPercent,
    @Default([]) List<StudentQuestion> questions,
  }) = _StudentQuiz;
  factory StudentQuiz.fromJson(Map<String, dynamic> json) => _$StudentQuizFromJson(json);
}

@freezed
abstract class AttemptBrief with _$AttemptBrief {
  const factory AttemptBrief({
    required int id,
    required String status,
    required DateTime startedAt,
    DateTime? submittedAt,
  }) = _AttemptBrief;
  factory AttemptBrief.fromJson(Map<String, dynamic> json) => _$AttemptBriefFromJson(json);
}

@freezed
abstract class StartAttemptResponse with _$StartAttemptResponse {
  const factory StartAttemptResponse({required AttemptBrief attempt, required StudentQuiz quiz}) = _StartAttemptResponse;
  factory StartAttemptResponse.fromJson(Map<String, dynamic> json) => _$StartAttemptResponseFromJson(json);
}

@freezed
abstract class ResultOption with _$ResultOption {
  const factory ResultOption({
    required int id,
    required String optionText,
    required int position,
    required bool selected,
    bool? isCorrect,
  }) = _ResultOption;
  factory ResultOption.fromJson(Map<String, dynamic> json) => _$ResultOptionFromJson(json);
}

@freezed
abstract class ResultQuestion with _$ResultQuestion {
  const factory ResultQuestion({
    required int questionId,
    required String questionText,
    required String questionType,
    required int points,
    required int pointsAwarded,
    required bool isCorrect,
    String? explanation,
    @Default([]) List<ResultOption> options,
  }) = _ResultQuestion;
  factory ResultQuestion.fromJson(Map<String, dynamic> json) => _$ResultQuestionFromJson(json);
}

@freezed
abstract class AttemptResult with _$AttemptResult {
  const factory AttemptResult({
    required int attemptId,
    required int assignmentId,
    required String status,
    required int score,
    required int maxScore,
    required int percent,
    required bool passed,
    required int passPercent,
    DateTime? submittedAt,
    required bool showCorrectAnswers,
    @Default([]) List<ResultQuestion> questions,
  }) = _AttemptResult;
  factory AttemptResult.fromJson(Map<String, dynamic> json) => _$AttemptResultFromJson(json);
}

@freezed
abstract class AttemptDetail with _$AttemptDetail {
  const factory AttemptDetail({
    required AttemptBrief attempt,
    StudentQuiz? quiz,
    AttemptResult? result,
  }) = _AttemptDetail;
  factory AttemptDetail.fromJson(Map<String, dynamic> json) => _$AttemptDetailFromJson(json);
}

@freezed
abstract class QuizHistoryItem with _$QuizHistoryItem {
  const factory QuizHistoryItem({
    required int attemptId,
    required int attemptNumber,
    required String status,
    int? score,
    int? maxScore,
    int? percent,
    bool? passed,
    required DateTime startedAt,
    DateTime? submittedAt,
  }) = _QuizHistoryItem;
  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) => _$QuizHistoryItemFromJson(json);
}

/// Mirrors `AttemptHistory` (GET /assignments/:id/quiz/attempts).
@freezed
abstract class QuizAttemptHistory with _$QuizAttemptHistory {
  const factory QuizAttemptHistory({
    required int assignmentId,
    required String title,
    required int passPercent,
    int? maxAttempts,
    required int attemptsUsed,
    int? attemptsLeft,
    required bool canStart,
    required bool passed,
    int? bestScore,
    int? bestMaxScore,
    int? bestPercent,
    int? inProgressId,
    @Default([]) List<QuizHistoryItem> attempts,
  }) = _QuizAttemptHistory;
  factory QuizAttemptHistory.fromJson(Map<String, dynamic> json) => _$QuizAttemptHistoryFromJson(json);
}
