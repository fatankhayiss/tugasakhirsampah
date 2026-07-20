/// Konfigurasi API terpusat untuk koneksi ke backend bank_sampah.
///
/// Dukungan environment:
/// - Override langsung: `--dart-define=API_BASE_URL=https://.../`
/// - Flavor:
///   - `--dart-define=APP_FLAVOR=prod`
///   - `--dart-define=APP_FLAVOR=staging`
///   - `--dart-define=APP_FLAVOR=dev`
class ApiConfig {
  ApiConfig._();

  static const String _flavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod');
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Fallback default per-environment
  static const String _prodBaseUrl = 'https://itrashy.triki.cloud/bank_sampah/';
  static const String _stagingBaseUrl = 'https://staging.itrashy.triki.cloud/bank_sampah/';
  static const String _devBaseUrl = 'http://10.0.2.2/tugasakhirsampah/bank_sampah/';

  /// Base URL backend (selalu dipastikan memiliki trailing slash).
  static String get baseUrl {
    final candidate = _customBaseUrl.isNotEmpty ? _customBaseUrl : _baseUrlFromFlavor();
    return candidate.endsWith('/') ? candidate : '$candidate/';
  }

  static String _baseUrlFromFlavor() {
    switch (_flavor) {
      case 'dev':
        return _devBaseUrl;
      case 'staging':
        return _stagingBaseUrl;
      case 'prod':
      default:
        return _prodBaseUrl;
    }
  }

  // API Endpoints
  static String get authLogin => '${baseUrl}modules/api/auth_api.php?action=login';
  static String get authRegister => '${baseUrl}modules/api/auth_api.php?action=register';
  static String get authGoogleLogin => '${baseUrl}modules/api/auth_api.php?action=google_login';
  static String get profile => '${baseUrl}modules/api/profile_api.php';
  static String get transaksi => '${baseUrl}modules/api/transaksi_api.php';
  static String get jenisSampah => '${baseUrl}modules/api/jenis_sampah_api.php';
  static String get orders => '${baseUrl}modules/api/orders_api.php';
  static String get notifikasi => '${baseUrl}modules/api/notifikasi_api.php';
  static String get edukasi => '${baseUrl}modules/api/edukasi.php';
  static String get detect => '${baseUrl}modules/api/detect.php';
  static String get upload => '${baseUrl}modules/api/upload.php';
  static String get reward => '${baseUrl}modules/api/reward_api.php';
}
