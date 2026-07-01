import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://192.168.102.14/Tugas%20Akhir/bank_sampah/modules/api/driver_api.php?action=get_active_task');
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer 1d232e9f2c1cc3fa1cb8ff52d590a8f5fccfb57f0dec5f3afdd9eb9d2b169982',
    }
  );
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
