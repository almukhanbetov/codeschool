import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/certificate.dart';
import '../application/certificate_providers.dart';

/// GET /me/certificates/:id + GET /me/certificates/:id/pdf. The PDF itself
/// is the backend's own official document (fpdf + embedded font + QR code)
/// — this screen only downloads, saves, opens with the system viewer, and
/// shares it; it never renders or fabricates a certificate locally (brief
/// §3). A certificate belonging to another user comes back as a real 404
/// from the backend (never a client-side guess at ownership).
class CertificateDetailScreen extends ConsumerStatefulWidget {
  const CertificateDetailScreen({super.key, required this.certificateId});
  final int certificateId;

  @override
  ConsumerState<CertificateDetailScreen> createState() => _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends ConsumerState<CertificateDetailScreen> {
  bool _working = false;
  String? _localPath;

  Future<String?> _ensureLocalFile(Certificate cert) async {
    if (_localPath != null && File(_localPath!).existsSync()) return _localPath;

    final t = ref.read(appStringsProvider);
    setState(() => _working = true);
    final lang = ref.read(localeProvider).code;
    final result = await ref.read(certificateRepositoryProvider).downloadPdf(cert.id, lang: lang);
    if (!mounted) return null;
    setState(() => _working = false);

    switch (result) {
      case ApiOk(:final data):
        final dir = await getApplicationDocumentsDirectory();
        final safeNumber = cert.certificateNumber.toLowerCase().replaceAll(' ', '-');
        final file = File('${dir.path}/certificate-$safeNumber.pdf');
        await file.writeAsBytes(Uint8List.fromList(data), flush: true);
        _localPath = file.path;
        return _localPath;
      case ApiErr(:final error):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, error))));
        }
        return null;
    }
  }

  Future<void> _openPdf(Certificate cert) async {
    final t = ref.read(appStringsProvider);
    final path = await _ensureLocalFile(cert);
    if (path == null) return;
    final result = await OpenFilex.open(path);
    if (result.type.name != 'done' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('certificates.openPdfError'))));
    }
  }

  Future<void> _sharePdf(Certificate cert) async {
    final path = await _ensureLocalFile(cert);
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], subject: cert.certificateNumber);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final certAsync = ref.watch(certificateByIdProvider(widget.certificateId));

    return Scaffold(
      appBar: AppBar(title: Text(t('certificates.title'))),
      body: certAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(certificateByIdProvider(widget.certificateId)),
        ),
        data: (cert) {
          final revoked = cert.status == 'revoked';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: (revoked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.award, size: 48, color: revoked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(cert.course.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(cert.learnerName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              if (revoked) ...[
                const SizedBox(height: 12),
                Center(child: Chip(label: Text(t('certificates.revoked')), backgroundColor: Theme.of(context).colorScheme.errorContainer)),
              ],
              const SizedBox(height: 24),
              _InfoRow(label: t('certificates.certificateNumber'), value: cert.certificateNumber),
              _InfoRow(label: t('certificates.verificationCode'), value: cert.verificationCode),
              _InfoRow(label: t('certificates.issuedAt'), value: _formatDate(cert.issuedAt)),
              _InfoRow(label: t('certificates.completedAt'), value: _formatDate(cert.completedAt)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _working ? null : () => _openPdf(cert),
                      icon: const Icon(LucideIcons.fileText),
                      label: Text(_working ? t('certificates.downloading') : t('certificates.viewPdf')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _working ? null : () => _sharePdf(cert),
                      icon: const Icon(LucideIcons.share2),
                      label: Text(t('certificates.share')),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  return '$d.$m.${local.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
