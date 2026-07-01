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
          );
        }).toList();
      }
    } catch (e) {
      print('WASTE REPO ERROR: $e');
    }

    // Fallback: data statis
    return _fallbackWaste();
  }

  /// Synchronous fallback for screens that can't await.
  List<WasteItem> getAvailableWasteSync() => _fallbackWaste();

  List<WasteItem> _fallbackWaste() {
    return [
      WasteItem(id: '1', name: 'Botol Plastik', imageAsset: AppImages.image1, pricePerKg: 3000),
      WasteItem(id: '2', name: 'Kardus', imageAsset: AppImages.image2, pricePerKg: 1500),
      WasteItem(id: '3', name: 'Kertas', imageAsset: AppImages.frame, pricePerKg: 1200),
      WasteItem(id: '4', name: 'Besi', imageAsset: AppImages.image1, pricePerKg: 2500),
    ];
  }

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
