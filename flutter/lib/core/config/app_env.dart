/// Build-time environment configuration.
///
/// The API base is never hardcoded to a single value — it is passed via
/// `--dart-define=API_BASE_URL=...` at build time, exactly like the web
/// frontend's `NEXT_PUBLIC_BROWSER_API_URL` is an env var, not a literal in
/// source. Defaults to the local dev backend (`docker-compose.yml`, port
/// 8080) reachable from an Android emulator via the special loopback alias
/// `10.0.2.2`; a real device on the same network must instead use the host
/// machine's LAN IP (pass it via --dart-define at build/run time).
///
/// `https://api.codeschool.kz/api/v1` is the production API per the Stage 35
/// brief — confirmed live and reachable as of Stage 35D (`GET /courses` and
/// `GET /courses/:id/content` verified read-only against it), so it is
/// wired in as the `prod` flavor's default. This stage's actual test runs
/// still target the local dev backend (`docker-compose`, port 8080) so
/// nothing writes to production data (registration, enrollment, etc.).
class AppEnv {
  const AppEnv._({required this.apiBaseUrl, required this.flavorName});

  final String apiBaseUrl;
  final String flavorName;

  static const _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _envFlavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');

  /// Android emulator loopback to the host machine's docker-compose backend.
  static const _devDefault = 'http://10.0.2.2:8080/api/v1';
  static const _prodDefault = 'https://api.codeschool.kz/api/v1';

  static AppEnv resolve() {
    final flavor = _envFlavor;
    final base = _envApiBaseUrl.isNotEmpty
        ? _envApiBaseUrl
        : (flavor == 'prod' ? _prodDefault : _devDefault);
    return AppEnv._(apiBaseUrl: base, flavorName: flavor);
  }

  bool get isProd => flavorName == 'prod';
}
