import '../constants/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService.instance;

  Future<ApiResponse> login(String username, String password) async {
    final response = await _api.post(
      ApiConfig.authLogin,
      body: {'username': username, 'password': password},
    );

    if (response.success && response.data != null) {
      final userData = response.data as Map<String, dynamic>;

      if (userData['level'] != 'driver') {
        return ApiResponse(
          success: false,
          message: 'Akun ini bukan akun Driver. Silakan gunakan aplikasi Warga atau hubungi Admin.',
          statusCode: 403,
        );
      }

      if (userData['token'] != null) {
        await _api.saveToken(userData['token']);
      }
      await _api.saveUserData(userData);
      return response;
    }
    return response;
  }

  Future<ApiResponse> register(Map<String, dynamic> registerData) async {
    registerData['level'] = 'driver'; // ensure level is driver
    
    final response = await _api.post(
      ApiConfig.authRegister,
      body: registerData,
    );

    // Do not save token or user data here, so the user must login manually
    // if (response.success && response.data != null) { ... }
    
    return response;
  }

  Future<bool> isLoggedIn() => _api.isLoggedIn();

  Future<Map<String, dynamic>?> getSavedUser() => _api.getUserData();

  Future<Map<String, dynamic>?> readUser() => _api.getUserData();

  Future<void> saveUser(Map<String, dynamic> userData) => _api.saveUserData(userData);

  Future<void> updateUser(Map<String, dynamic> userData) => _api.saveUserData(userData);

  Future<void> deleteUser() => _api.clearAuth();

  Future<void> logout() => _api.clearAuth();
}
