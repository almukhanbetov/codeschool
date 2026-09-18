import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/certificate.dart';

/// Talks to the owner-scoped certificate endpoints — exact routes in
/// backend/internal/certificates/routes.go. Certificates are official PDF
/// documents generated server-side (`github.com/go-pdf/fpdf` + embedded
/// font + QR code) — this repository never builds or renders a certificate
/// itself, only fetches what the backend already issued (brief §3: "Не
/// создавай сертификаты самостоятельно на Flutter").
///
/// Access control: a certificate that belongs to another user comes back as
/// a plain 404 (certificates/service.go `GetMine`/`PDFForOwner` — "belongs
/// to someone else is reported as ErrNotFound, never ErrForbidden", so as
/// not to leak whether the id exists at all) — this repository doesn't add
/// its own ownership check, the backend is the real boundary.
class CertificateRepository {
  CertificateRepository(this._client);
  final ApiClient _client;

  Future<ApiResult<List<Certificate>>> listMine() => _client.get<List<Certificate>>(
        '/me/certificates',
        decode: (json) => (json as List).map((e) => Certificate.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<Certificate>> getMine(int id) => _client.get<Certificate>(
        '/me/certificates/$id',
        decode: (json) => Certificate.fromJson(json as Map<String, dynamic>),
      );

  /// POST /courses/:id/certificate — lazily idempotent on the backend: if a
  /// certificate already exists for this course it just returns it, so this
  /// same call safely doubles as both "issue" and "get-or-issue".
  /// Real eligibility (`ErrNotEligible`/`ErrNotEnrolled`) is enforced
  /// server-side, never assumed client-side.
  Future<ApiResult<Certificate>> issue(int courseId) => _client.post<Certificate>(
        '/courses/$courseId/certificate',
        decode: (json) => Certificate.fromJson(json as Map<String, dynamic>),
      );

  /// GET /me/certificates/:id/pdf — raw `application/pdf` bytes, not the
  /// JSON envelope, so this goes through [ApiClient.raw] directly rather
  /// than the generic `get<T>` helper (see its own doc comment).
  Future<ApiResult<List<int>>> downloadPdf(int id, {String? lang}) async {
    try {
      final response = await _client.raw.get<List<int>>(
        '/me/certificates/$id/pdf',
        queryParameters: {'lang': ?lang},
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        return ApiResult.ok(response.data!);
      }
      return ApiResult.err(ApiException.fromResponseBody(response.statusCode ?? 0, null));
    } on DioException catch (e) {
      if (e.response?.statusCode != null) {
        return ApiResult.err(ApiException.fromResponseBody(e.response!.statusCode!, null));
      }
      return ApiResult.err(ApiException.network());
    }
  }
}
