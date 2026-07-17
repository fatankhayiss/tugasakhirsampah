import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

void main() async {
  final url = Uri.parse('http://192.168.31.220/tugasakhirsampah/bank_sampah/modules/api/driver_api.php?action=get_active_task');
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer 1d232e9f2c1cc3fa1cb8ff52d590a8f5fccfb57f0dec5f3afdd9eb9d2b169982',
    }
  );
  debugPrint('Status: ${response.statusCode}');
  debugPrint('Body: ${response.body}');
}
