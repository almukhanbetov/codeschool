import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../core/providers/core_providers.dart';

const _fileExtensions = ['.mp4', '.webm', '.ogg', '.ogv', '.mov'];
const _externalHosts = ['youtube.com', 'www.youtube.com', 'youtu.be', 'vimeo.com', 'www.vimeo.com'];

/// Safe lesson video player — mirrors the web app's `LessonVideo.tsx`
/// contract (only 2 shapes ever embed) but ported to native widgets instead
/// of an iframe, since this is a native app, not a WebView wrapper (brief
/// §3/§7: no WebView, no arbitrary HTML):
///  - a direct https file (.mp4/.webm/.ogg/.ogv/.mov) → played in-app with
///    `video_player` (native decoder, no embedded browser).
///  - youtube.com/youtu.be/vimeo.com → opened in the system browser/app via
///    `url_launcher` (`LaunchMode.externalApplication`) rather than
///    embedded, since Flutter has no built-in iframe equivalent and adding
///    a WebView just to embed one would be the exact thing the brief rules
///    out.
/// Anything else (unknown host, non-https, unparsable) → a safe fallback
/// message, no player, no link.
class LessonVideoPlayer extends ConsumerWidget {
  const LessonVideoPlayer({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final uri = Uri.tryParse(videoUrl);

    if (uri == null || uri.scheme != 'https') {
      return _Fallback(message: t('lesson.video.unsupported'));
    }

    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    if (_fileExtensions.any(path.endsWith)) {
      return _DirectVideoPlayer(uri: uri);
    }

    if (_externalHosts.contains(host)) {
      return _ExternalVideoLink(uri: uri);
    }

    return _Fallback(message: t('lesson.video.unsupported'));
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.videoOff),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ExternalVideoLink extends ConsumerWidget {
  const _ExternalVideoLink({required this.uri});
  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    return OutlinedButton.icon(
      onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
      icon: const Icon(LucideIcons.externalLink),
      label: Text(t('lesson.video.open')),
    );
  }
}

class _DirectVideoPlayer extends StatefulWidget {
  const _DirectVideoPlayer({required this.uri});
  final Uri uri;

  @override
  State<_DirectVideoPlayer> createState() => _DirectVideoPlayerState();
}

class _DirectVideoPlayerState extends State<_DirectVideoPlayer> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(widget.uri);
    _controller = controller;
    controller.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Consumer(builder: (context, ref, _) => _Fallback(message: ref.watch(appStringsProvider)('lesson.video.loadError')));
    }

    final controller = _controller!;
    if (!controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            _PlayPauseOverlay(controller: controller),
            VideoProgressIndicator(controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  const _PlayPauseOverlay({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
      }),
      child: AnimatedOpacity(
        opacity: widget.controller.value.isPlaying ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black26,
          child: const Center(
            child: Icon(Icons.play_arrow, color: Colors.white, size: 56),
          ),
        ),
      ),
    );
  }
}
