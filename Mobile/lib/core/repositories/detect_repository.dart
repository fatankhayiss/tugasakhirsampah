import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Simple repository to upload an asset image to the bank_sampah detect API.
///
/// Default `baseUrl` targets Android emulator host mapping `10.0.2.2`.
class DetectRepository {
  final String endpoint;

  DetectRepository({String? baseUrl})
    : endpoint =
          baseUrl ?? 'http://10.0.2.2/bank_sampah/modules/api/detect.php';

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

    // If you need to send a user id: request.fields['user_id'] = '1';

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }
}
