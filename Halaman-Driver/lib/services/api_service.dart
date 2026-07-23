import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

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
  factory ApiService() => instance;

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

  Future<ApiResponse> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
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

  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status, {String? beratAktual}) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    final requestUrl = ApiConfig.ordersUpdateStatus;
    final requestBody = jsonEncode({
      'id_order': orderId,
      'status': status,
      if (beratAktual != null) 'berat_aktual': beratAktual,
    });

    debugPrint('Request URL: $requestUrl');
    debugPrint('HTTP Method: PUT');
    debugPrint('Request Body: $requestBody');

    try {
      final response = await http.put(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      debugPrint('HTTP Status Code: ${response.statusCode}');
      debugPrint('Raw Response Body: "${response.body}"');

      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Gagal memperbarui status: Respons dari server kosong (HTTP ${response.statusCode}).',
        };
      }

      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {
          'success': false,
          'message': 'Respons server tidak berformat JSON valid.',
        };
      } catch (e) {
        debugPrint('JSON Decode Error: $e');
        return {
          'success': false,
          'message': 'Gagal memproses respons server (Format JSON tidak valid).',
        };
      }
    } catch (e) {
      debugPrint('HTTP Exception: $e');
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  Future<Map<String, dynamic>> getDailyVehicle() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.driverGetDailyVehicle),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.body.trim().isEmpty) {
        return {'success': false, 'message': 'Respons kosong'};
      }
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> saveDailyVehicle({
    required String vehicleName,
    required String vehicleType,
    required String licensePlate,
    String? capacity,
    String? notes,
  }) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.driverSaveDailyVehicle),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vehicle_name': vehicleName,
          'vehicle_type': vehicleType,
          'license_plate': licensePlate,
          'capacity': capacity ?? '',
          'notes': notes ?? '',
        }),
      );
      if (response.body.trim().isEmpty) {
        return {'success': false, 'message': 'Respons kosong'};
      }
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
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
