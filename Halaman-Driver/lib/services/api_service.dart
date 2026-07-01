import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: body,
      ).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Koneksi gagal: $e',
        statusCode: 500,
      );
    }
  }

  ApiResponse _processResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = json.decode(response.body);
      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? 'Unknown error',
        data: data['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memproses response dari server',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_userDataKey);
    if (dataString != null) {
      return json.decode(dataString);
    }
    return null;
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.put(
        Uri.parse(ApiConfig.ordersUpdateStatus),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_order': orderId,
          'status': status,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }
}
