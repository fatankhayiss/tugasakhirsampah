import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../services/api_service.dart';

/// Simple repository to upload an asset image to the bank_sampah detect API.
///
/// Default `baseUrl` targets `ApiConfig.detect` (from centralized ApiConfig).
class DetectRepository {
  final String endpoint;

  DetectRepository({String? baseUrl})
    : endpoint =
          baseUrl ?? ApiConfig.detect;

  /// Uploads an image bundled as a Flutter asset (e.g. `assets/botol plastik.jpg`).
  /// Returns the HTTP response from the server.
  Future<http.Response> uploadAsset(String assetPath) async {
    // Load bytes from asset bundle
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final uri = Uri.parse(endpoint);
    final request = http.MultipartRequest('POST', uri);

    // Create multipart file from bytes. Field name expected by server is `image`.
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: assetPath.split('/').last,
      ),
    );

    // Fetch user_id and attach if available
    final userData = await ApiService.instance.getUserData();
    if (userData != null && userData['id_pengguna'] != null) {
      request.fields['user_id'] = userData['id_pengguna'].toString();
    }

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  /// Uploads an image from a local file path (e.g. from camera capture).
  Future<http.Response> uploadFile(String filePath) async {
    final uri = Uri.parse(endpoint);
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        filePath,
      ),
    );

    final userData = await ApiService.instance.getUserData();
    if (userData != null && userData['id_pengguna'] != null) {
      request.fields['user_id'] = userData['id_pengguna'].toString();
    }

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }
}
