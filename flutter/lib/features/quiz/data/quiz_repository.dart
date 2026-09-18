import '../../../core/network/api_client.dart';
import '../../../shared/models/quiz.dart';

/// Talks to the quiz endpoints — exact routes in
/// backend/internal/quizzes/routes.go. Correctness/scoring is always
/// computed server-side; the client only ever submits selected option ids
/// and renders whatever `AttemptResult` comes back (brief §4: never a
/// locally computed score).
class QuizRepository {
  QuizRepository(this._client);
  final ApiClient _client;

  /// POST /assignments/:id/quiz/attempts — starts a new attempt, or resumes
  /// the in-progress one if the student already has one (quizzes/service.go).
  Future<ApiResult<StartAttemptResponse>> startAttempt(int assignmentId) => _client.post<StartAttemptResponse>(
        '/assignments/$assignmentId/quiz/attempts',
        decode: (json) => StartAttemptResponse.fromJson(json as Map<String, dynamic>),
      );

  /// GET /assignments/:id/quiz/attempts — attempt history + retry
  /// eligibility (`canStart`/`attemptsLeft`), used to gate the retry button
  /// instead of guessing client-side.
  Future<ApiResult<QuizAttemptHistory>> listAttempts(int assignmentId) => _client.get<QuizAttemptHistory>(
        '/assignments/$assignmentId/quiz/attempts',
        decode: (json) => QuizAttemptHistory.fromJson(json as Map<String, dynamic>),
      );

  /// POST /quiz/attempts/:id/submit — `answers` maps questionId to the
  /// selected option ids (empty list for an unanswered question).
  Future<ApiResult<AttemptResult>> submitAttempt(int attemptId, Map<int, List<int>> answers) => _client.post<AttemptResult>(
        '/quiz/attempts/$attemptId/submit',
        data: {
          'answers': answers.entries
              .map((e) => {'questionId': e.key, 'selectedOptionIds': e.value})
              .toList(),
        },
        decode: (json) => AttemptResult.fromJson(json as Map<String, dynamic>),
      );

  /// GET /quiz/attempts/:id — a resumable quiz while in progress, or the
  /// graded result once submitted (`AttemptDetail.quiz` xor `.result`).
  Future<ApiResult<AttemptDetail>> getAttempt(int attemptId) => _client.get<AttemptDetail>(
        '/quiz/attempts/$attemptId',
        decode: (json) => AttemptDetail.fromJson(json as Map<String, dynamic>),
      );
}
