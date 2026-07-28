/// Konfigurasi API terpusat untuk koneksi ke backend bank_sampah.
///
/// Ubah [baseUrl] sesuai environment:
/// - Production Cloud: `http://172.20.10.13/tugasakhirsampah/bank_sampah/`
library;
import 'environment.dart';

class ApiConfig {
  ApiConfig._();

  /// Base URL backend. Trailing slash wajib.
  static String get baseUrl => Environment.baseUrl;

  // API Endpoints
  static String get authLogin => '${baseUrl}modules/api/auth_api.php?action=login';
  static String get authRegister => '${baseUrl}modules/api/auth_api.php?action=register';
  static String get authGoogleLogin => '${baseUrl}modules/api/auth_api.php?action=google_login';
  static String get authForgotPassword => '${baseUrl}modules/api/auth_api.php?action=forgot_password';
  static String get authVerifyOtp => '${baseUrl}modules/api/auth_api.php?action=verify_otp';
  static String get authResetPassword => '${baseUrl}modules/api/auth_api.php?action=reset_password';

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
