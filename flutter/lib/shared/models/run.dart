import 'package:freezed_annotation/freezed_annotation.dart';

part 'run.freezed.dart';
part 'run.g.dart';

/// Mirrors backend/internal/runs/dto.go `RunResult` — status is one of
/// 'ok' | 'error' | 'timeout' | 'runner_error' (migration 00023 CHECK).
@freezed
abstract class RunResult with _$RunResult {
  const factory RunResult({
    required int runId,
    required String language,
    required String status,
    required String stdout,
    required String stderr,
    int? exitCode,
    required bool timedOut,
    required bool truncated,
    int? durationMs,
    required DateTime createdAt,
  }) = _RunResult;
  factory RunResult.fromJson(Map<String, dynamic> json) => _$RunResultFromJson(json);
}

@freezed
abstract class RunHistoryItem with _$RunHistoryItem {
  const factory RunHistoryItem({
    required int runId,
    required String kind,
    required String status,
    int? exitCode,
    int? durationMs,
    required String stdout,
    required String stderr,
    required DateTime createdAt,
  }) = _RunHistoryItem;
  factory RunHistoryItem.fromJson(Map<String, dynamic> json) => _$RunHistoryItemFromJson(json);
}

@freezed
abstract class VisibleTest with _$VisibleTest {
  const factory VisibleTest({
    required int id,
    required String name,
    required String stdin,
    required String expectedStdout,
  }) = _VisibleTest;
  factory VisibleTest.fromJson(Map<String, dynamic> json) => _$VisibleTestFromJson(json);
}

@freezed
abstract class TestsResponse with _$TestsResponse {
  const factory TestsResponse({
    required bool hasTests,
    required int total,
    @Default([]) List<VisibleTest> visible,
  }) = _TestsResponse;
  factory TestsResponse.fromJson(Map<String, dynamic> json) => _$TestsResponseFromJson(json);
}

@freezed
abstract class TestOutcome with _$TestOutcome {
  const factory TestOutcome({
    required int testId,
    required String name,
    required bool hidden,
    required bool passed,
    required bool timedOut,
    String? stdin,
    String? expected,
    String? got,
    String? stderr,
  }) = _TestOutcome;
  factory TestOutcome.fromJson(Map<String, dynamic> json) => _$TestOutcomeFromJson(json);
}

@freezed
abstract class GradeResult with _$GradeResult {
  const factory GradeResult({
    required int submissionId,
    required String status,
    required bool passed,
    int? score,
    required int points,
    required int percent,
    required int testsPassed,
    required int testsTotal,
    required String feedback,
    @Default([]) List<TestOutcome> outcomes,
  }) = _GradeResult;
  factory GradeResult.fromJson(Map<String, dynamic> json) => _$GradeResultFromJson(json);
}
