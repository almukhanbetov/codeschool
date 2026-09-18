import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/features/certificates/data/certificate_repository.dart';
import 'package:codeschool_mobile/shared/models/certificate.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

/// Mock only [ApiClient] (and, for the PDF path, the raw [Dio] it exposes)
/// and check [CertificateRepository] calls the exact real routes in
/// backend/internal/certificates/routes.go.
void main() {
  late MockApiClient client;
  late CertificateRepository repo;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    client = MockApiClient();
    repo = CertificateRepository(client);
  });

  test('listMine hits GET /me/certificates and decodes the real Response shape', () async {
    when(() => client.get<List<Certificate>>('/me/certificates', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<Certificate> Function(dynamic);
      return ApiResult.ok(decode([
        {
          'id': 25,
          'certificateNumber': 'CS-2026-000003-CHZ3',
          'verificationCode': 'C1E2-19XE-0DBP-0XB4',
          'course': {'id': 304, 'title': 'Python с нуля'},
          'learnerName': 'E2EQA',
          'issuedAt': '2026-09-17T17:38:15Z',
          'completedAt': '2026-09-17T17:38:10Z',
          'status': 'active',
          'verifyUrl': 'https://codeschool.kz/certificates/verify/C1E2-19XE-0DBP-0XB4',
        },
      ]));
    });

    final result = await repo.listMine();
    final certs = (result as ApiOk<List<Certificate>>).data;
    expect(certs.single.certificateNumber, 'CS-2026-000003-CHZ3');
  });

  test('issue POSTs to /courses/:id/certificate (idempotent get-or-issue on the backend)', () async {
    when(() => client.post<Certificate>('/courses/304/certificate', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as Certificate Function(dynamic);
      return ApiResult.ok(decode({
        'id': 25,
        'certificateNumber': 'CS-2026-000003-CHZ3',
        'verificationCode': 'C1E2-19XE-0DBP-0XB4',
        'course': {'id': 304, 'title': 'Python с нуля'},
        'learnerName': 'E2EQA',
        'issuedAt': '2026-09-17T17:38:15Z',
        'completedAt': '2026-09-17T17:38:10Z',
        'status': 'active',
        'verifyUrl': 'https://codeschool.kz/certificates/verify/C1E2-19XE-0DBP-0XB4',
      }));
    });

    final result = await repo.issue(304);
    expect((result as ApiOk<Certificate>).data.id, 25);
    verify(() => client.post<Certificate>('/courses/304/certificate', decode: any(named: 'decode'))).called(1);
  });

  test('downloadPdf hits GET /me/certificates/:id/pdf with ?lang= and returns raw bytes', () async {
    final dio = MockDio();
    when(() => client.raw).thenReturn(dio);
    when(() => dio.get<List<int>>(
          '/me/certificates/25/pdf',
          queryParameters: {'lang': 'ru'},
          options: any(named: 'options'),
        )).thenAnswer(
      (_) async => Response(
        data: [37, 80, 68, 70], // "%PDF" magic bytes
        statusCode: 200,
        requestOptions: RequestOptions(path: '/me/certificates/25/pdf'),
      ),
    );

    final result = await repo.downloadPdf(25, lang: 'ru');
    final bytes = (result as ApiOk<List<int>>).data;
    expect(bytes, [37, 80, 68, 70]);
  });

  test('downloadPdf on someone else\'s certificate surfaces the real 404 (no ownership leak)', () async {
    final dio = MockDio();
    when(() => client.raw).thenReturn(dio);
    when(() => dio.get<List<int>>(
          '/me/certificates/99/pdf',
          queryParameters: {'lang': 'ru'},
          options: any(named: 'options'),
        )).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/me/certificates/99/pdf'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/me/certificates/99/pdf'),
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    final result = await repo.downloadPdf(99, lang: 'ru');
    expect(result, isA<ApiErr<List<int>>>());
  });
}
