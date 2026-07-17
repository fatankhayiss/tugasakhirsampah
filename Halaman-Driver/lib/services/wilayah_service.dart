import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WilayahService {
  static const String baseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/api';

  Future<List<Map<String, String>>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/provinces.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'].toString(),
          'name': item['name'].toString(),
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getProvinces: $e');
    }
    return [];
  }

  Future<List<Map<String, String>>> getRegencies(String provinceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/regencies/$provinceId.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'].toString(),
          'name': item['name'].toString(),
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getRegencies: $e');
    }
    return [];
  }

  Future<List<Map<String, String>>> getDistricts(String regencyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/districts/$regencyId.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'].toString(),
          'name': item['name'].toString(),
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getDistricts: $e');
    }
    return [];
  }
}
