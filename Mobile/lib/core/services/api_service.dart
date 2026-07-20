import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized HTTP client for all API calls.
///
/// Handles token attachment, JSON parsing, and error standardization.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();
  factory ApiService() => instance;

  static const String _tokenKey = 'api_token';
  static const String _userKey = 'user_data';
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const Duration _multipartTimeout = Duration(seconds: 15);
  static const int _maxRetries = 1;

  final ValueNotifier<int> profileUpdateNotifier = ValueNotifier<int>(0);
  void notifyProfileChanged() => profileUpdateNotifier.value++;

  /// Save auth token after login.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get stored auth token.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save user data as JSON string and notify listeners.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
    notifyProfileChanged();
  }

  /// Get stored user data.
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_userKey);
    if (str == null) return null;
    return json.decode(str) as Map<String, dynamic>;
  }

  /// Check if user is logged in (has token).
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear token and user data (logout).
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Build headers with Authorization token.
  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET request — returns decoded JSON body.
  Future<ApiResponse> get(String url, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParams,
        });
      }
      final headers = await _headers();
      final response = await _requestWithRetry(
        () => http.get(uri, headers: headers).timeout(_defaultTimeout),
      );
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Koneksi timeout. Silakan coba lagi.');
    } on SocketException {
      return ApiResponse(success: false, message: 'Tidak dapat terhubung ke server.');
    } catch (e) {
      debugPrint('API Error (GET $url): $e');
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// POST request with form data.
  Future<ApiResponse> post(String url, {Map<String, String>? body}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _headers();
      final response = await _requestWithRetry(
        () => http.post(uri, headers: headers, body: body).timeout(_defaultTimeout),
      );
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Koneksi timeout. Silakan coba lagi.');
    } on SocketException {
      return ApiResponse(success: false, message: 'Tidak dapat terhubung ke server.');
    } catch (e) {
      debugPrint('API Error (POST $url): $e');
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// POST request with multipart (file upload).
  Future<ApiResponse> postMultipart(
    String url, {
    Map<String, String>? fields,
    Map<String, List<int>>? files,
    Map<String, String>? fileNames,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (fields != null) request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(http.MultipartFile.fromBytes(
            entry.key,
            entry.value,
            filename: fileNames?[entry.key] ?? 'file',
          ));
        }
      }
      final streamed = await request.send().timeout(_multipartTimeout);
      final response = await http.Response.fromStream(streamed).timeout(_multipartTimeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Upload timeout. Silakan coba lagi.');
    } on SocketException {
      return ApiResponse(success: false, message: 'Tidak dapat terhubung ke server.');
    } catch (e) {
      debugPrint('API Error (Multipart POST $url): $e');
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// PUT request with JSON body.
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _headers();
      headers['Content-Type'] = 'application/json';
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(_defaultTimeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Koneksi timeout. Silakan coba lagi.');
    } on SocketException {
      return ApiResponse(success: false, message: 'Tidak dapat terhubung ke server.');
    } catch (e) {
      debugPrint('API Error (PUT $url): $e');
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() requestFn,
  ) async {
    var lastError = const SocketException('Unknown request error');

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await requestFn();
        if (_isRetryableStatusCode(response.statusCode) && attempt < _maxRetries) {
          await Future.delayed(const Duration(milliseconds: 350));
          continue;
        }
        return response;
      } on TimeoutException catch (e) {
        lastError = SocketException(e.message ?? 'Request timeout');
        if (attempt >= _maxRetries) rethrow;
        await Future.delayed(const Duration(milliseconds: 350));
      } on SocketException catch (e) {
        lastError = e;
        if (attempt >= _maxRetries) rethrow;
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }

    throw lastError;
  }

  bool _isRetryableStatusCode(int statusCode) {
    return statusCode == 408 || statusCode == 429 || statusCode == 502 || statusCode == 503 || statusCode == 504;
  }

  ApiResponse _parseResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return ApiResponse(
        success: false,
        message: _defaultMessageFromStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final message = (data['message']?.toString().trim().isNotEmpty ?? false)
          ? data['message'].toString()
          : _defaultMessageFromStatus(response.statusCode);

      return ApiResponse(
        success: data['success'] == true || (response.statusCode >= 200 && response.statusCode < 300),
        message: message,
        data: data['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _defaultMessageFromStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }
  }

  String _defaultMessageFromStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return 'Permintaan berhasil';
    }
    if (statusCode == 401) return 'Sesi berakhir. Silakan login ulang.';
    if (statusCode == 403) return 'Akses ditolak.';
    if (statusCode == 404) return 'Endpoint tidak ditemukan.';
    if (statusCode == 408) return 'Permintaan timeout.';
    if (statusCode == 429) return 'Terlalu banyak permintaan. Coba lagi nanti.';
    if (statusCode >= 500) return 'Server sedang bermasalah. Coba lagi nanti.';
    return 'Terjadi kesalahan saat menghubungi server.';
  }
}

/// Standard API response wrapper.
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 0,
  });
}
