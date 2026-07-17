import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/login_content.dart';
import '../models/register_content.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';

/// Repository for authentication — connects to bank_sampah auth_api.php.
class AuthRepository {
  final ApiService _api = ApiService.instance;

  // UI content (tetap statis — tidak dari API)
  LoginContent getLoginContent() {
    return LoginContent(
      headerImage: AppImages.loginBanner,
      welcomeText: 'Welcome!',
      emailPlaceholder: 'Email / Username / Nomor Telepon',
      passwordPlaceholder: 'Password',
      forgotPasswordText: 'Lupa password?',
      loginButtonText: 'Login',
      noAccountText: 'Belum punya akun?',
      registerLinkText: 'Daftar Sekarang',
      continueWithText: 'Or continue with',
    );
  }

  RegisterContent getRegisterContent() {
    return RegisterContent(
      title: 'Daftar',
      subtitle: 'Buat akumu sekarang dan mulai langkah kecil untuk bumi kita!',
      namePlaceholder: 'Nama',
      emailPlaceholder: 'Email Address',
      passwordPlaceholder: 'Password',
      confirmPasswordPlaceholder: 'Confirm Password',
      termsText: 'Saya setuju dengan ',
      termsLinkText: 'Ketentuan Layanan',
      privacyLinkText: ' & Kebijakan Privasi.',
      registerButtonText: 'Daftar',
      hasAccountText: 'Sudah punya akun?',
      loginLinkText: 'Masuk di sini',
      continueWithText: 'Atau lanjutkan dengan',
    );
  }

  /// Login via API — returns user data map on success. Throws Exception on failure.
  Future<Map<String, dynamic>?> login(String username, String password, {String? loginType}) async {
    final body = {'username': username, 'password': password};
    if (loginType != null) {
      body['login_type'] = loginType;
    }
    final response = await _api.post(
      ApiConfig.authLogin,
      body: body,
    );

    if (response.success && response.data != null) {
      final userData = response.data as Map<String, dynamic>;
      // Save token & user data locally
      if (userData['token'] != null) {
        await _api.saveToken(userData['token']);
      }
      await _api.saveUserData(userData);
      return userData;
    }

    throw Exception(response.message);
  }

  /// Request password reset OTP via API — returns ApiResponse directly for status inspection.
  Future<ApiResponse> forgotPassword(String email) async {
    return await _api.post(
      ApiConfig.authForgotPassword,
      body: {'email': email},
    );
  }

  /// Verify 6-digit OTP code sent to email.
  Future<ApiResponse> verifyOtp(String email, String otpCode) async {
    return await _api.post(
      ApiConfig.authVerifyOtp,
      body: {'email': email, 'otp_code': otpCode},
    );
  }

  /// Reset password securely after verifying OTP token.
  Future<ApiResponse> resetPassword(String email, String resetToken, String newPassword) async {
    return await _api.post(
      ApiConfig.authResetPassword,
      body: {'email': email, 'reset_token': resetToken, 'new_password': newPassword},
    );
  }


  /// Register via API — returns user data map on success. Throws Exception on failure.
  Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password, {
    String? username,
    String? noTelepon,
    String? alamat,
  }) async {
    final body = {
      'nama_lengkap': name,
      'email': email,
      'password': password,
    };
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }
    if (noTelepon != null && noTelepon.isNotEmpty) {
      body['no_telepon'] = noTelepon;
    }
    if (alamat != null && alamat.isNotEmpty) {
      body['alamat'] = alamat;
    }

    final response = await _api.post(ApiConfig.authRegister, body: body);

    if (response.success && response.data != null) {
      final userData = response.data as Map<String, dynamic>;
      if (userData['token'] != null) {
        await _api.saveToken(userData['token']);
      }
      await _api.saveUserData(userData);
      return userData;
    }

    throw Exception(response.message);
  }

  /// Login Google via API backend MySQL
  Future<Map<String, dynamic>?> loginWithGoogleBackend(
    String googleUid,
    String email,
    String name,
    String? photoUrl,
  ) async {
    final response = await _api.post(
      ApiConfig.authGoogleLogin,
      body: {
        'google_uid': googleUid,
        'email': email,
        'nama_lengkap': name,
        'photo_url': photoUrl ?? '',
      },
    );

    if (response.success && response.data != null) {
      final userData = response.data as Map<String, dynamic>;
      if (userData['token'] != null) {
        await _api.saveToken(userData['token']);
      }
      await _api.saveUserData(userData);
      return userData;
    }

    throw Exception(response.message);
  }

  /// Check if user is currently logged in.
  Future<bool> isLoggedIn() => _api.isLoggedIn();

  /// Get locally saved user data.
  Future<Map<String, dynamic>?> getSavedUser() => _api.getUserData();

  /// Logout — clear stored token, user data, Firebase session, and Google account session.
  Future<void> logout() async {
    await _api.clearAuth();
    await GoogleAuthService.instance.signOut();
  }

  /// Alur Google Sign-In terintegrasi ke MySQL
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    return await GoogleAuthService.instance.signInWithGoogle();
  }
}
