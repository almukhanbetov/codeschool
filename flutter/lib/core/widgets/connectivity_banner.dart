import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/connectivity_provider.dart';
import '../providers/core_providers.dart';

/// A thin banner that appears when the device loses connectivity and
/// auto-dismisses (with a brief "restored" flash) when it comes back —
/// test scenario 18 ("работа без интернета и восстановление подключения").
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool? _wasOffline;
  bool _showRestored = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final connectivity = ref.watch(connectivityStreamProvider);

    return connectivity.when(
      data: (isOnline) {
        if (_wasOffline == true && isOnline && !_showRestored) {
          _showRestored = true;
          Future.microtask(() {
            if (!mounted) return;
            setState(() {});
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _showRestored = false);
            });
          });
        }
        _wasOffline = !isOnline;

        return Column(
          children: [
            if (!isOnline)
              _Banner(icon: LucideIcons.wifiOff, text: t('common.noInternet'), color: Theme.of(context).colorScheme.error)
            else if (_showRestored)
              _Banner(icon: LucideIcons.wifi, text: t('common.connectionRestored'), color: Colors.green),
            Expanded(child: widget.child),
          ],
        );
      },
      loading: () => widget.child,
      error: (_, _) => widget.child,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
