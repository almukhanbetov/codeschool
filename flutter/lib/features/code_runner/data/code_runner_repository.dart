import '../../../core/network/api_client.dart';
import '../../../shared/models/run.dart';

/// Talks to the Code Runner endpoints — exact routes in
/// backend/internal/runs/routes.go. Every execution happens on the
/// existing isolated server-side runner (backend/internal/sandbox +
/// cmd/runner, on an internal-only Docker network per
/// docker-compose.prod.yml); this repository only ever POSTs source code to
/// the backend and renders whatever it sends back — no code ever executes
/// on the device, and no client-side timeout/limit substitutes for the
/// server's own (brief §2: "не отключай ограничения безопасности").
class CodeRunnerRepository {
  CodeRunnerRepository(this._client);
  final ApiClient _client;

  /// POST /assignments/:id/run — a free "Run" (not graded).
  Future<ApiResult<RunResult>> run(int assignmentId, {required String code, String stdin = ''}) => _client.post<RunResult>(
        '/assignments/$assignmentId/run',
        data: {'code': code, 'stdin': stdin},
        decode: (json) => RunResult.fromJson(json as Map<String, dynamic>),
      );

  /// GET /assignments/:id/runs.
  Future<ApiResult<List<RunHistoryItem>>> runHistory(int assignmentId) => _client.get<List<RunHistoryItem>>(
        '/assignments/$assignmentId/runs',
        decode: (json) => (json as List).map((e) => RunHistoryItem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  /// GET /assignments/:id/tests — visible sample tests only; hidden ones
  /// stay server-side (`TestsResponse.hasTests`/`total` still count them).
  Future<ApiResult<TestsResponse>> getTests(int assignmentId) => _client.get<TestsResponse>(
        '/assignments/$assignmentId/tests',
        decode: (json) => TestsResponse.fromJson(json as Map<String, dynamic>),
      );

  /// POST /assignments/:id/code/submit — grades against every test
  /// (visible + hidden) server-side; the client only ever displays
  /// `GradeResult`, never computes pass/fail itself.
  Future<ApiResult<GradeResult>> submitCode(int assignmentId, {required String code}) => _client.post<GradeResult>(
        '/assignments/$assignmentId/code/submit',
        data: {'code': code},
        decode: (json) => GradeResult.fromJson(json as Map<String, dynamic>),
      );
}
