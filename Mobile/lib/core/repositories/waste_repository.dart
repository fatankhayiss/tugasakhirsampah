import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/waste_item.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Repository for waste types — fetches from bank_sampah jenis_sampah_api.php.
class WasteRepository {
  final ApiService _api = ApiService.instance;

  /// Fetch available waste types from API.
  Future<List<WasteItem>> getAvailableWaste() async {
    try {
      final response = await _api.get(ApiConfig.jenisSampah);
      if (response.success && response.data != null) {
        final items = response.data as List;
        return items.map<WasteItem>((item) {
          return WasteItem(
            id: item['id'].toString(),
            name: item['nama'] ?? '',
            imageAsset: _getImageForWaste(item['nama'] ?? ''),
            pricePerKg: (item['harga_per_kg'] as num?)?.toDouble() ?? 0,
            category: item['kategori'],
            description: item['deskripsi'],
            caraPengolahan: item['cara_pengolahan'],
            imageUrl: item['gambar'],
          );
        }).toList();
      } else {
        throw Exception(response.message.isNotEmpty ? response.message : 'Gagal memuat kategori sampah.');
      }
    } catch (e) {
      debugPrint('WASTE REPO ERROR: $e');
      throw Exception('Tidak dapat terhubung ke server. Pastikan Anda memiliki koneksi internet.');
    }
  }

  /// Synchronous fallback removed because data must be live.
  /// If you need sync data, provide an empty list or cached valid data.
  List<WasteItem> getAvailableWasteSync() => [];

  String _getImageForWaste(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('plastik') || lower.contains('botol')) return AppImages.image1;
    if (lower.contains('kardus')) return AppImages.image2;
    if (lower.contains('kertas')) return AppImages.frame;
    return AppImages.image1;
  }

  IconData getWasteIcon(String wasteName) {
    switch (wasteName.toLowerCase()) {
      case 'botol plastik':
      case 'plastik botol (pet)':
      case 'gelas plastik (pp)':
        return LucideIcons.recycle;
      case 'kardus':
        return LucideIcons.package;
      case 'kertas':
      case 'kertas hvs/buku':
        return LucideIcons.file_text;
      case 'besi':
      case 'logam (besi)':
      case 'logam (aluminium)':
        return LucideIcons.nut;
      default:
        return LucideIcons.package;
    }
  }
}
