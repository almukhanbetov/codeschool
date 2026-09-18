import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders `lessons.content` safely. The column is plain TEXT on the
/// backend (no schema change) — this is a small, hand-written parser for a
/// safe Markdown-like *subset*, not a general Markdown/HTML engine: only the
/// constructs below are recognized, everything else (including any literal
/// HTML tag) is shown as plain text. There is no HTML parsing anywhere in
/// this file — every node is a real Flutter widget built from parsed,
/// escaped text, mirroring the web app's `LessonContent.tsx` (same
/// supported-subset contract, ported rather than reinvented).
///
/// Supported per line/block:
///   `#` / `##` / `###` heading
///   `-` or `*` bullet list item (consecutive lines group into one list)
///   `1.` `2.` … ordered list item (consecutive lines group into one list)
///   ` ``` ` fenced code block
///   blank-line-separated paragraphs, with inline `**bold**`, `*italic*`,
///     `` `code` ``, and `[text](https://…)` links
/// Links: only http(s) URLs are ever turned into a real tappable link —
/// anything else renders as plain text (brief §7: "no arbitrary HTML/unsafe
/// URLs").
class SafeMarkdown extends StatelessWidget {
  const SafeMarkdown({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    final blocks = <Widget>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        i++;
        continue;
      }

      if (line.trim().startsWith('```')) {
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        i++; // skip closing fence
        blocks.add(_CodeBlock(code: codeLines.join('\n')));
        continue;
      }

      final heading = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(line);
      if (heading != null) {
        final level = heading.group(1)!.length;
        final content = heading.group(2)!;
        blocks.add(_Heading(text: content, level: level));
        i++;
        continue;
      }

      if (RegExp(r'^[-*]\s+').hasMatch(line)) {
        final items = <String>[];
        while (i < lines.length && RegExp(r'^[-*]\s+').hasMatch(lines[i])) {
          items.add(lines[i].replaceFirst(RegExp(r'^[-*]\s+'), ''));
          i++;
        }
        blocks.add(_BulletList(items: items));
        continue;
      }

      if (RegExp(r'^\d+\.\s+').hasMatch(line)) {
        final items = <String>[];
        while (i < lines.length && RegExp(r'^\d+\.\s+').hasMatch(lines[i])) {
          items.add(lines[i].replaceFirst(RegExp(r'^\d+\.\s+'), ''));
          i++;
        }
        blocks.add(_OrderedList(items: items));
        continue;
      }

      // Paragraph: consecutive non-blank, non-special lines join into one.
      final paraLines = <String>[];
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !lines[i].trim().startsWith('```') &&
          !RegExp(r'^(#{1,3})\s+').hasMatch(lines[i]) &&
          !RegExp(r'^[-*]\s+').hasMatch(lines[i]) &&
          !RegExp(r'^\d+\.\s+').hasMatch(lines[i])) {
        paraLines.add(lines[i]);
        i++;
      }
      blocks.add(_Paragraph(text: paraLines.join(' ')));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }
}

Uri? _safeUri(String raw) {
  final uri = Uri.tryParse(raw);
  if (uri == null) return null;
  return (uri.scheme == 'https' || uri.scheme == 'http') ? uri : null;
}

/// `**bold**`, `*italic*`, `` `code` ``, `[text](url)` within one line.
List<InlineSpan> _renderInline(BuildContext context, String text, TextStyle base) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'\[([^\]]*)\]\(([^)]+)\)|`([^`]+)`|\*\*([^*]+)\*\*|\*([^*]+)\*');
  var last = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    if (m.group(1) != null) {
      final uri = _safeUri(m.group(2)!);
      spans.add(
        TextSpan(
          text: m.group(1)!.isEmpty ? m.group(2)! : m.group(1)!,
          style: uri != null
              ? base.copyWith(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline)
              : base,
          recognizer: uri != null ? (TapGestureRecognizer()..onTap = () => _openExternal(uri)) : null,
        ),
      );
    } else if (m.group(3) != null) {
      spans.add(
        TextSpan(
          text: m.group(3)!,
          style: base.copyWith(fontFamily: 'monospace', backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
        ),
      );
    } else if (m.group(4) != null) {
      spans.add(TextSpan(text: m.group(4)!, style: base.copyWith(fontWeight: FontWeight.w700)));
    } else if (m.group(5) != null) {
      spans.add(TextSpan(text: m.group(5)!, style: base.copyWith(fontStyle: FontStyle.italic)));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last), style: base));
  return spans;
}

void _openExternal(Uri uri) {
  // ignore: discarded_futures
  launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text, required this.level});
  final String text;
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final style = switch (level) {
      1 => theme.titleLarge,
      2 => theme.titleMedium,
      _ => theme.titleSmall,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: style?.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(TextSpan(children: _renderInline(context, text, base))),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (it) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: base),
                    Expanded(child: Text.rich(TextSpan(children: _renderInline(context, it, base)))),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _OrderedList extends StatelessWidget {
  const _OrderedList({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var idx = 0; idx < items.length; idx++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${idx + 1}.  ', style: base),
                  Expanded(child: Text.rich(TextSpan(children: _renderInline(context, items[idx], base)))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
      ),
    );
  }
}
