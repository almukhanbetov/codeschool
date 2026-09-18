import 'package:flutter_test/flutter_test.dart';

import 'package:codeschool_mobile/core/config/app_env.dart';

/// `API_BASE_URL`/`APP_FLAVOR` are `String.fromEnvironment` — baked in at
/// *compile* time of whatever binary reads them, so a plain `flutter test`
/// run (no `--dart-define`) can only observe the no-define path here. The
/// `prod` flavor's default and an explicit `API_BASE_URL` override are
/// exercised for real by the actual release build command (see the report)
/// rather than faked in-process.
void main() {
  test('with no --dart-define, AppEnv resolves to the dev-emulator default, never production', () {
    final env = AppEnv.resolve();
    expect(env.flavorName, 'dev');
    expect(env.isProd, isFalse);
    expect(env.apiBaseUrl, 'http://10.0.2.2:8080/api/v1');
  });
}
