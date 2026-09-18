import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression test for the real bug this fix addresses: a release APK only
/// merges `android/app/src/main/AndroidManifest.xml` — `debug`/`profile`
/// ship their own overlay manifests that already declare INTERNET (added
/// automatically by the Flutter tool for the debugger/VM service), which is
/// why a debug build could reach the API while a release build silently
/// couldn't reach *any* host at all. Without this permission every request
/// fails at the socket level before DNS/TLS, which `ApiClient` maps to
/// `ApiException.network()` ("Сервермен байланыс жоқ") regardless of how
/// correct `API_BASE_URL` is — so this has to be caught here, not by
/// asserting anything about the configured URL.
void main() {
  test('the main (release) AndroidManifest.xml declares android.permission.INTERNET', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(
      manifest.contains('android.permission.INTERNET'),
      isTrue,
      reason: 'Without this in the *main* manifest, only debug/profile builds (which have their own '
          'overlay manifest with this permission) can reach the network — a release APK would fail '
          'every request at the socket level, regardless of API_BASE_URL.',
    );
  });
}
