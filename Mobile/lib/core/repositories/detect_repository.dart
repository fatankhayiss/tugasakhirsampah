import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/detect_result.dart';
import '../services/api_service.dart';

/// Repository for uploading waste images and receiving YOLO detection results.
///
/// Uses the detect.php endpoint which communicates with the persistent
/// detect_worker.py socket server (best.onnx loaded once).
class DetectRepository {
  final String endpoint;

  /// Timeout for the full upload + detection round-trip.
  static const Duration _timeout = Duration(seconds: 20);

  DetectRepository({String? baseUrl})
      : endpoint = baseUrl ?? ApiConfig.detect;

  // ─────────────────────────────────────────────
  // Main entry point — upload a camera/gallery file
  // ─────────────────────────────────────────────

  /// Uploads an image from a local file path (camera capture).
  /// Returns a [DetectResult] with labels and detection details.
  Future<DetectResult> detectImage(String filePath) async {
    try {
      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('image', filePath),
      );

      // Attach user_id if logged in
      final userData = await ApiService.instance.getUserData();
      if (userData != null && userData['id_pengguna'] != null) {
        request.fields['user_id'] = userData['id_pengguna'].toString();
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return DetectResult(
          success: false,
          labels: [],
          detections: [],
          errorMessage: 'HTTP ${response.statusCode}',
        );
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        return DetectResult(
          success: false,
          labels: [],
          detections: [],
          errorMessage: 'Respons server kosong',
        );
      }

      final parsed = jsonDecode(body) as Map<String, dynamic>;
      return DetectResult.fromJson(parsed);
    } catch (e) {
      debugPrint('[DetectRepository] Error: $e');
      return DetectResult(
        success: false,
        labels: [],
        detections: [],
        errorMessage: 'Koneksi gagal: $e',
      );
    }
  }

  // ─────────────────────────────────────────────
  // Legacy: upload from Flutter asset bundle
  // ─────────────────────────────────────────────

  /// Uploads an image bundled as a Flutter asset (e.g. `assets/botol plastik.jpg`).
  Future<DetectResult> detectAsset(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: assetPath.split('/').last,
        ),
      );

      final userData = await ApiService.instance.getUserData();
      if (userData != null && userData['id_pengguna'] != null) {
        request.fields['user_id'] = userData['id_pengguna'].toString();
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final parsed = jsonDecode(response.body.trim()) as Map<String, dynamic>;
      return DetectResult.fromJson(parsed);
    } catch (e) {
      debugPrint('[DetectRepository] detectAsset error: $e');
      return DetectResult(
        success: false,
        labels: [],
        detections: [],
        errorMessage: 'Error: $e',
      );
    }
  }

  // ─────────────────────────────────────────────
  // Legacy compatibility — raw HTTP response
  // ─────────────────────────────────────────────

  /// [Deprecated] Returns raw http.Response. Use [detectImage] instead.
  Future<http.Response> uploadFile(String filePath) async {
    final uri = Uri.parse(endpoint);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    final userData = await ApiService.instance.getUserData();
    if (userData != null && userData['id_pengguna'] != null) {
      request.fields['user_id'] = userData['id_pengguna'].toString();
    }
    final streamed = await request.send().timeout(_timeout);
    return await http.Response.fromStream(streamed);
  }

  /// [Deprecated] Returns raw http.Response for asset upload.
  Future<http.Response> uploadAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final uri = Uri.parse(endpoint);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: assetPath.split('/').last),
    );
    final userData = await ApiService.instance.getUserData();
    if (userData != null && userData['id_pengguna'] != null) {
      request.fields['user_id'] = userData['id_pengguna'].toString();
    }
    final streamed = await request.send().timeout(_timeout);
    return await http.Response.fromStream(streamed);
  }
}
