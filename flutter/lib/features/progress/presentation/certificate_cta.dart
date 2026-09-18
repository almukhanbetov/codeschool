import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../certificates/application/certificate_providers.dart';

/// Course-completion certificate call to action — mirrors the web app's
/// `CertificateCTA.tsx` (same eligibility contract: shown once the course
/// is complete, `POST /courses/:id/certificate` is lazily idempotent so this
/// button doubles as "issue" and "get already-issued"). Only rendered by
/// the caller once `enrollmentStatus == 'completed'`; real eligibility is
/// still re-checked by the backend on every call.
class CertificateCta extends ConsumerStatefulWidget {
  const CertificateCta({super.key, required this.courseId});
  final int courseId;

  @override
  ConsumerState<CertificateCta> createState() => _CertificateCtaState();
}

class _CertificateCtaState extends ConsumerState<CertificateCta> {
  bool _issuing = false;

  Future<void> _issue() async {
    final t = ref.read(appStringsProvider);
    setState(() => _issuing = true);
    final result = await ref.read(certificateRepositoryProvider).issue(widget.courseId);
    if (!mounted) return;
    setState(() => _issuing = false);
    switch (result) {
      case ApiOk(:final data):
        ref.invalidate(myCertificatesProvider);
        if (mounted) context.push(AppRoutes.certificateDetailPath(data.id));
      case ApiErr(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final certsAsync = ref.watch(myCertificatesProvider);

    return certsAsync.when(
      loading: () => const SizedBox(height: 52, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, _) => OutlinedButton.icon(
        onPressed: _issuing ? null : _issue,
        icon: const Icon(LucideIcons.award),
        label: Text(_issuing ? t('certificates.issuing') : t('certificates.issue')),
      ),
      data: (certs) {
        int? existingId;
        for (final c in certs) {
          if (c.course.id == widget.courseId) {
            existingId = c.id;
            break;
          }
        }
        if (existingId != null) {
          return OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.certificateDetailPath(existingId!)),
            icon: const Icon(LucideIcons.award),
            label: Text(t('certificates.issued')),
          );
        }
        return ElevatedButton.icon(
          onPressed: _issuing ? null : _issue,
          icon: const Icon(LucideIcons.award),
          label: Text(_issuing ? t('certificates.issuing') : t('certificates.issue')),
        );
      },
    );
  }
}
