import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'http://192.168.196.14/tugasakhirsampah/bank_sampah/modules/api/';
  
  // 1. Test Jenis Sampah (GET)
  final jenisSampahUrl = baseUrl + 'jenis_sampah_api.php';
  print('Testing GET \$jenisSampahUrl');
  try {
    final response = await http.get(Uri.parse(jenisSampahUrl));
    print('Status Code: \${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: \${data['success']}');
      print('Item count: \${(data['data'] as List).length}');
    } else {
      print('Failed with body: \${response.body}');
    }
  } catch (e) {
    print('Error: \$e');
  }

  print('\n-----------------------\n');

  // 2. Test Login (POST)
  final loginUrl = baseUrl + 'auth_api.php?action=login';
  print('Testing POST \$loginUrl');
  try {
    final response = await http.post(
      Uri.parse(loginUrl),
      body: {
        'email': 'invalid@test.com',
        'password': 'wrong'
      }
    );
    print('Status Code: \${response.statusCode}');
    final data = json.decode(response.body);
    print('Response: \$data');
  } catch (e) {
    print('Error: \$e');
  }
}
