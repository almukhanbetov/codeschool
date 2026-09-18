import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/certificate.dart';
import '../data/certificate_repository.dart';

final certificateRepositoryProvider =
    Provider<CertificateRepository>((ref) => CertificateRepository(ref.watch(apiClientProvider)));

final myCertificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  final repo = ref.watch(certificateRepositoryProvider);
  final result = await repo.listMine();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final certificateByIdProvider = FutureProvider.family<Certificate, int>((ref, id) async {
  final repo = ref.watch(certificateRepositoryProvider);
  final result = await repo.getMine(id);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
