import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/login_content.dart';
import '../models/register_content.dart';
import '../services/api_service.dart';

/// Repository for authentication — connects to bank_sampah auth_api.php.
class AuthRepository {
  final ApiService _api = ApiService.instance;

  // UI content (tetap statis — tidak dari API)
  LoginContent getLoginContent() {
    return LoginContent(
      headerImage: AppImages.loginBanner,
      welcomeText: 'Welcome!',
      emailPlaceholder: 'Email Address',
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
      emailPlaceholder: 'Email',
      passwordPlaceholder: 'Create a password',
      confirmPasswordPlaceholder: 'Confirm password',
      termsText: 'I\'ve read and agree to the',
      termsLinkText: 'Terms and Conditions',
      privacyLinkText: 'Privacy Policy',
      registerButtonText: 'Daftar',
      hasAccountText: 'Sudah punya akun?',
      loginLinkText: 'Login',
      continueWithText: 'Or continue with',
    );
  }

  /// Login via API — returns user data map on success. Throws Exception on failure.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await _api.post(
      ApiConfig.authLogin,
      body: {
        'username': username,
        'password': password,
      },
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

  /// Register via API — returns user data map on success. Throws Exception on failure.
  Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password, {
    String? noTelepon,
    String? alamat,
  }) async {
    final body = {
      'nama_lengkap': name,
      'email': email,
      'password': password,
    };
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

  /// Check if user is currently logged in.
  Future<bool> isLoggedIn() => _api.isLoggedIn();

  /// Get locally saved user data.
  Future<Map<String, dynamic>?> getSavedUser() => _api.getUserData();

  /// Logout — clear stored token and user data.
  Future<void> logout() => _api.clearAuth();

  // Social login stubs (not implemented on backend yet)
  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  Future<bool> loginWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  Future<bool> loginWithFacebook() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }
}
