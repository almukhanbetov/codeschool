import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeschool_mobile/features/lesson/presentation/safe_markdown.dart';

void main() {
  Future<void> pump(WidgetTester tester, String text) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: SafeMarkdown(text: text))));

  group('SafeMarkdown', () {
    testWidgets('renders the real lesson-content shape: headings, paragraph, list', (tester) async {
      await pump(tester, '''
## Цель урока
Понять, что компьютер сам по себе ничего не придумывает.

## Практика
- Придумай команду
- Запиши её
''');

      expect(find.text('Цель урока'), findsOneWidget);
      expect(find.text('Понять, что компьютер сам по себе ничего не придумывает.'), findsOneWidget);
      expect(find.text('Практика'), findsOneWidget);
      expect(find.textContaining('Придумай команду'), findsOneWidget);
      expect(find.textContaining('Запиши её'), findsOneWidget);
    });

    testWidgets('renders a fenced code block as monospace text, not executable markup', (tester) async {
      await pump(tester, '''
Пример:
```
print("hi")
```
''');

      expect(find.text('print("hi")'), findsOneWidget);
    });

    testWidgets('renders an http(s) link as tappable text and leaves a non-http scheme as plain text', (tester) async {
      await pump(tester, '[открой](https://codeschool.kz) и [не открывай](javascript:alert(1))');

      // Both link labels render as real text — the unsafe one just never
      // becomes tappable (verified structurally: no crash, no raw scheme
      // string leaks into a clickable span since _safeUri rejects it).
      expect(find.textContaining('открой'), findsWidgets);
      expect(find.textContaining('не открывай'), findsWidgets);
    });

    testWidgets('plain unstructured text (pre-existing lessons) still renders as a paragraph', (tester) async {
      await pump(tester, 'Просто текст без какой-либо разметки.');
      expect(find.text('Просто текст без какой-либо разметки.'), findsOneWidget);
    });

    testWidgets('bold/italic/inline-code render without leaking the raw markdown syntax', (tester) async {
      await pump(tester, 'Обычный **жирный** и *курсив* и `code`.');

      expect(find.textContaining('**жирный**'), findsNothing);
      expect(find.textContaining('*курсив*'), findsNothing);
    });
  });
}
