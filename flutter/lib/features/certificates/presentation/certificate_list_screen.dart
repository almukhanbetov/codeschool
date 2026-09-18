import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/certificate.dart';
import '../application/certificate_providers.dart';

/// GET /me/certificates — every certificate real, issued server-side.
class CertificateListScreen extends ConsumerWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final certsAsync = ref.watch(myCertificatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('certificates.title'))),
      body: certsAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(myCertificatesProvider),
        ),
        data: (certs) {
          if (certs.isEmpty) {
            return EmptyView(message: t('certificates.empty'), icon: LucideIcons.award);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myCertificatesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: certs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _CertificateCard(certificate: certs[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});
  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    final revoked = certificate.status == 'revoked';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.certificateDetailPath(certificate.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (revoked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.award, color: revoked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(certificate.course.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(certificate.certificateNumber, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
