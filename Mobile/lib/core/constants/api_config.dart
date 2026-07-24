/// Konfigurasi API terpusat untuk koneksi ke backend bank_sampah.
///
/// Ubah [baseUrl] sesuai environment:
/// - Android Emulator: `http://10.0.2.2/tugasakhirsampah/bank_sampah/`
/// - iOS Simulator: `http://localhost/tugasakhirsampah/bank_sampah/`
/// - Production Cloud: `https://itrashy.triki.cloud/`
class ApiConfig {
  ApiConfig._();

  /// Base URL backend. Trailing slash wajib.
  static const String baseUrl = 'http://192.168.110.61/tugasakhirsampah/bank_sampah/';

  // API Endpoints
  static const String authLogin = '${baseUrl}modules/api/auth_api.php?action=login';
  static const String authRegister = '${baseUrl}modules/api/auth_api.php?action=register';
  static const String authGoogleLogin = '${baseUrl}modules/api/auth_api.php?action=google_login';
  static const String authForgotPassword = '${baseUrl}modules/api/auth_api.php?action=forgot_password';
  static const String authVerifyOtp = '${baseUrl}modules/api/auth_api.php?action=verify_otp';
  static const String authResetPassword = '${baseUrl}modules/api/auth_api.php?action=reset_password';

  static const String profile = '${baseUrl}modules/api/profile_api.php';
  static const String transaksi = '${baseUrl}modules/api/transaksi_api.php';
  static const String jenisSampah = '${baseUrl}modules/api/jenis_sampah_api.php';
  static const String orders = '${baseUrl}modules/api/orders_api.php';
  static const String notifikasi = '${baseUrl}modules/api/notifikasi_api.php';
  static const String edukasi = '${baseUrl}modules/api/edukasi.php';
  static const String detect = '${baseUrl}modules/api/detect.php';
  static const String upload = '${baseUrl}modules/api/upload.php';
  static const String reward = '${baseUrl}modules/api/reward_api.php';
}
