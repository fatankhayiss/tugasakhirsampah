import 'dart:convert';
import 'package:intl/intl.dart';
import '../../features/orders/models/history_item_model.dart';
import '../../features/orders/models/ongoing_order_model.dart';
import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/order_model.dart';
import 'notification_repository.dart';
import '../services/api_service.dart';

import 'package:flutter/foundation.dart';

/// Repository for orders — fetches from bank_sampah orders_api.php, transaksi_api.php, and reward_api.php.
class OrderRepository extends ChangeNotifier {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  final ApiService _api = ApiService.instance;

  void refresh() {
    notifyListeners();
  }

  /// Helper to format Pickup Schedule (tanggal_order + waktu_jemput_dari) as e.g. "23 Juli 2026, 08.00 WIB"
  static String formatPickupSchedule(String? rawDate, String? rawTimeFrom) {
    final dtStr = (rawDate != null && rawDate.isNotEmpty) ? rawDate : '';
    if (dtStr.isEmpty) return '-';

    final dt = DateTime.tryParse(dtStr) ?? DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateFormatted = '${dt.day} ${months[dt.month - 1]} ${dt.year}';

    final timeStr = (rawTimeFrom != null && rawTimeFrom.isNotEmpty) ? rawTimeFrom : '';
    if (timeStr.isEmpty) return dateFormatted;

    final cleanTime = timeStr.replaceAll(':', '.');
    final parts = cleanTime.split('.');
    final timeFormatted = parts.length >= 2 ? '${parts[0]}.${parts[1]} WIB' : '$cleanTime WIB';
    return '$dateFormatted, $timeFormatted';
  }

  /// Create a new pickup order via API.
  Future<int?> createOrder({
    required String alamatJemput,
    double? latitude,
    double? longitude,
    String? waktuDari,
    String? waktuSampai,
    String? estimasiBerat,
    int estimasiPoin = 0,
    String? catatan,
    required List<Map<String, dynamic>> items,
  }) async {
    final body = <String, String>{
      'alamat_jemput': alamatJemput,
      'estimasi_poin': estimasiPoin.toString(),
      'items': json.encode(items),
    };
    if (latitude != null) body['latitude'] = latitude.toString();
    if (longitude != null) body['longitude'] = longitude.toString();
    if (waktuDari != null) body['waktu_jemput_dari'] = waktuDari;
    if (waktuSampai != null) body['waktu_jemput_sampai'] = waktuSampai;
    if (estimasiBerat != null) body['estimasi_berat'] = estimasiBerat;
    if (catatan != null) body['catatan'] = catatan;

    final response = await _api.post(ApiConfig.orders, body: body);
    if (response.success && response.data != null) {
      return response.data['id_order'] as int?;
    }
    return null;
  }

  /// Fetch ongoing orders (both pickup and redemptions) from API.
  Future<List<OngoingOrderModel>> getOngoingOrders() async {
    final List<OngoingOrderModel> combined = [];
    try {
      final userData = await _api.getUserData();
      final userId = userData?['id']?.toString() ?? '';
      if (userId.isNotEmpty) {
        final response = await _api.get(ApiConfig.orders, queryParams: {
          'user_id': userId,
          'status': 'MENUNGGU_KONFIRMASI,DRIVER_DITUGASKAN,DRIVER_MENUJU_LOKASI,DRIVER_TIBA,PENIMBANGAN,SAMPAH_DIJEMPUT,MENUJU_BANK_SAMPAH,VALIDASI_BANK_SAMPAH,POIN_DIPROSES',
        });

        if (response.success && response.data != null) {
          final items = response.data['items'] as List? ?? [];
          final apiOrders = items.map<OngoingOrderModel>((item) {
            final status = _mapStatus(item['status'] ?? 'pending');
            final scheduleDateStr = formatPickupSchedule(
              item['tanggal_order']?.toString() ?? item['created_at']?.toString(),
              item['waktu_jemput_dari']?.toString(),
            );

            final rawBerat = item['estimasi_berat']?.toString() ?? '0';
            final cleanBerat = rawBerat.replaceAll(RegExp(r'[^\d.]'), '');
            final beratVal = double.tryParse(cleanBerat) ?? (double.tryParse(rawBerat) ?? 0.0);
            final beratStr = '${beratVal.toStringAsFixed(1)} Kg';
            final itemsCnt = item['items_count'] ?? 1;

            return OngoingOrderModel(
              id: item['id'].toString(),
              title: 'Jemput Sampah',
              date: scheduleDateStr,
              subtitle: '$beratStr · $itemsCnt Jenis',
              status: status,
              estimatedPoints: '+${item['estimasi_poin'] ?? 0} poin',
              driverName: item['nama_driver'],
              rawStatus: item['status']?.toString(),
            );
          }).toList();
          combined.addAll(apiOrders);
        }
      }
    } catch (_) {}

    try {
      final redemptions = await getOngoingRedemptions();
      combined.addAll(redemptions);
    } catch (_) {}

    return combined;
  }

  /// Fetch reward balance from API
  Future<Map<String, dynamic>> getRewardBalance() async {
    try {
      final response = await _api.get(ApiConfig.reward, queryParams: {'action': 'balance'});
      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return {
      'current_point': 0,
      'conversion_rate': 1,
      'current_money_conversion': 0.0,
    };
  }

  /// Create a reward redemption request (Tukar Poin)
  Future<ApiResponse> createRedemptionRequest({
    required String destinationType,
    required String provider,
    required String accountName,
    required String accountNumber,
    required int redeemPoint,
  }) async {
    try {
      final response = await _api.post(
        '${ApiConfig.reward}?action=request',
        body: {
          'destination_type': destinationType,
          'provider': provider,
          'account_name': accountName,
          'account_number': accountNumber,
          'redeem_point': redeemPoint.toString(),
        },
      );
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        NotificationRepository.instance.notifyRedemptionStatusChange(
          redemptionId: data['id']?.toString() ?? 'NEW',
          status: 'pending',
        );
      }
      return response;
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  /// Fetch ongoing redemptions (status pending or processing)
  Future<List<OngoingOrderModel>> getOngoingRedemptions() async {
    try {
      final response = await _api.get(ApiConfig.reward, queryParams: {
        'action': 'history',
        'status': 'pending,processing',
      });
      if (response.success && response.data != null) {
        final items = response.data['items'] as List? ?? [];
        return items.map<OngoingOrderModel>((item) {
          final rawStatus = item['status']?.toString() ?? 'processing';
          // Force both pending and processing to 'Diproses' in the new workflow
          final OngoingStatus mappedStatus = OngoingStatus.processing;
          final pts = (item['redeem_point'] as num?)?.toInt() ?? 0;
          final amt = (item['estimated_amount'] as num?)?.toDouble() ?? 0.0;

          return OngoingOrderModel(
            id: item['id'].toString(),
            title: 'Tukar Poin · ${item['provider'] ?? ''}',
            date: _formatDate(item['created_at'] ?? ''),
            subtitle: '${item['destination_type'] ?? 'E-Wallet'} · Rp ${amt.toStringAsFixed(0)}',
            status: mappedStatus,
            estimatedPoints: '-${NumberFormat.decimalPattern('id').format(pts)} Poin',
            isRedemption: true,
            destination: item['destination_type']?.toString(),
            provider: item['provider']?.toString(),
            accountNumber: item['account_number']?.toString(),
            accountName: item['account_name']?.toString(),
            estimatedAmount: amt,
            rawStatus: rawStatus,
            transactionCode: item['transaction_code']?.toString() ?? item['transaction_number']?.toString(),
            adminNote: item['admin_note']?.toString(),
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetch single redemption detail
  Future<Map<String, dynamic>?> getRedemptionDetail(String id) async {
    try {
      final response = await _api.get(ApiConfig.reward, queryParams: {
        'action': 'detail',
        'id': id,
      });
      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final cleanId = orderId.replaceAll(RegExp(r'[^\d]'), '');
      debugPrint('==================================================');
      debugPrint('Opening Detail Order');
      debugPrint('Order ID: $orderId (Cleaned: $cleanId)');
      
      final userData = await _api.getUserData();
      final userId = userData?['id']?.toString() ?? 'N/A';
      debugPrint('User ID: $userId');

      if (cleanId.isEmpty) {
        debugPrint('ERROR: Cleaned Order ID is empty!');
        debugPrint('==================================================');
        return null;
      }

      final url = '${ApiConfig.orders}?id=$cleanId';
      debugPrint('Request URL: $url');
      debugPrint('Request Body: N/A (GET)');

      final response = await _api.get(ApiConfig.orders, queryParams: {
        'id': cleanId,
      });

      debugPrint('Response Success: ${response.success}');
      debugPrint('Response Message: ${response.message}');
      debugPrint('Decoded JSON: ${response.data}');
      debugPrint('==================================================');

      if (response.success && response.data != null && response.data is Map<String, dynamic>) {
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap.containsKey('id_order') || dataMap.containsKey('status')) {
          return dataMap;
        }
      }
    } catch (e) {
      debugPrint('OrderRepository.getOrderById Exception: $e');
    }
    return null;
  }

  /// Cancel an order (set status to cancelled)
  Future<ApiResponse> cancelOrder(String orderId) async {
    try {
      final cleanId = orderId.replaceAll(RegExp(r'[^\d]'), '');
      final response = await _api.put(ApiConfig.orders, body: {
        'id_order': cleanId,
        'status': 'DIBATALKAN',
      });
      return response;
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  /// Fetch history (completed transactions, cancelled orders & redemptions) from API.
  Future<List<HistoryItemModel>> getHistoryItems() async {
    final List<HistoryItemModel> allItems = [];

    // 1. Fetch completed & cancelled orders from orders_api.php
    try {
      final userData = await _api.getUserData();
      final userId = userData?['id']?.toString() ?? '';
      if (userId.isNotEmpty) {
        final response = await _api.get(ApiConfig.orders, queryParams: {
          'user_id': userId,
          'status': 'SELESAI,DIBATALKAN',
        });
        if (response.success && response.data != null) {
          final items = response.data['items'] as List? ?? [];
          for (final item in items) {
            final rawStatus = item['status']?.toString().toUpperCase() ?? 'SELESAI';
            final isCancelled = rawStatus == 'DIBATALKAN';
            final scheduleStr = formatPickupSchedule(
              item['tanggal_order']?.toString() ?? item['created_at']?.toString(),
              item['waktu_jemput_dari']?.toString(),
            );
            final rawBerat = item['berat_aktual']?.toString() ?? item['estimasi_berat']?.toString() ?? '0';
            final cleanBerat = rawBerat.replaceAll(RegExp(r'[^\d.]'), '');
            final beratVal = double.tryParse(cleanBerat) ?? (double.tryParse(rawBerat) ?? 0.0);
            final beratStr = '${beratVal.toStringAsFixed(1)} Kg';
            final itemsCnt = item['items_count'] ?? 1;
            final pts = (item['estimasi_poin'] as num?)?.toInt() ?? 0;

            allItems.add(
              HistoryItemModel(
                id: item['id'].toString(),
                title: 'Jemput Sampah',
                date: scheduleStr,
                points: isCancelled ? '0 Poin' : '+${NumberFormat.decimalPattern('id').format(pts)} Poin',
                type: HistoryType.setor,
                weight: '$beratStr · $itemsCnt Jenis',
                statusLabel: isCancelled ? 'Dibatalkan' : 'Selesai',
                rawStatus: rawStatus,
              ),
            );
          }
        }
      }
    } catch (_) {}

    try {
      final response = await _api.get(ApiConfig.transaksi);
      if (response.success && response.data != null) {
        final items = response.data['items'] as List? ?? [];
        for (final item in items) {
          final isSetor = item['tipe'] == 'setor';
          final nilai = (item['total_nilai'] as num?)?.toDouble() ?? 0;
          final berat = isSetor ? (item['total_berat_kg'] as num?)?.toDouble() : null;

          allItems.add(
            HistoryItemModel(
              id: item['id'].toString(),
              title: isSetor ? 'Penjemputan' : 'Tukar Poin',
              date: formatPickupSchedule(item['tanggal'] ?? '', null),
              points: isSetor ? '+${NumberFormat.decimalPattern('id').format(nilai.toInt())} Poin' : '-${NumberFormat.decimalPattern('id').format(nilai.toInt())} Poin',
              type: isSetor ? HistoryType.setor : HistoryType.pencairan,
              weight: berat != null ? '${berat.toStringAsFixed(1)} Kg terkumpul' : null,
              statusLabel: 'Selesai',
            ),
          );
        }
      }
    } catch (_) {}

    try {
      final response = await _api.get(ApiConfig.reward, queryParams: {'action': 'history', 'status': 'completed,rejected'});
      if (response.success && response.data != null) {
        final items = response.data['items'] as List? ?? [];
        for (final item in items) {
          final rawStatus = item['status']?.toString().toLowerCase() ?? 'completed';
          String statusLabel;
          if (rawStatus == 'rejected') {
            statusLabel = 'Ditolak';
          } else {
            statusLabel = 'Selesai';
          }
          final pts = (item['redeem_point'] as num?)?.toInt() ?? 0;
          final amt = (item['estimated_amount'] as num?)?.toDouble() ?? 0.0;

          allItems.add(
            HistoryItemModel(
              id: item['id'].toString(),
              title: 'Tukar Poin (${item['provider'] ?? '-'})',
              date: _formatDate(item['created_at'] ?? ''),
              points: '-${NumberFormat.decimalPattern('id').format(pts)} Poin',
              type: HistoryType.pencairan,
              weight: 'Rp ${amt.toStringAsFixed(0)}',
              statusLabel: statusLabel,
              destination: item['destination_type']?.toString(),
              provider: item['provider']?.toString(),
              accountNumber: item['account_number']?.toString(),
              accountName: item['account_name']?.toString(),
              estimatedAmount: amt,
              adminNote: item['admin_note']?.toString(),
              rawStatus: rawStatus,
              transactionCode: item['transaction_code']?.toString() ?? item['transaction_number']?.toString(),
              transferProof: item['transfer_proof']?.toString(),
              rejectionReason: item['rejection_reason']?.toString(),
            ),
          );
        }
      }
    } catch (_) {}

    return allItems;
  }

  /// Legacy history as [OrderModel] for screens still using deposit flow.
  Future<List<OrderModel>> getHistoryOrders() async {
    try {
      final response = await _api.get(ApiConfig.transaksi, queryParams: {'tipe': 'setor'});
      if (response.success && response.data != null) {
        final items = response.data['items'] as List? ?? [];
        return items.map<OrderModel>((item) {
          final nilai = (item['total_nilai'] as num?)?.toDouble() ?? 0;
          final berat = (item['total_berat_kg'] as num?)?.toDouble() ?? 0;
          return OrderModel(
            id: item['id'].toString(),
            title: 'Setor Sampah',
            date: _formatDate(item['tanggal'] ?? ''),
            timeRange: '',
            estimatedWeight: '${berat.toStringAsFixed(1)} Kg',
            estimatedPoints: nilai.toInt(),
            totalWeight: '${berat.toStringAsFixed(1)} Kg',
            totalPoints: nilai.toInt(),
            status: 'selesai',
            imageAsset: AppImages.image5,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  OngoingStatus _mapStatus(String status) {
    switch (status) {
      case 'MENUNGGU_KONFIRMASI':
        return OngoingStatus.pending;
      case 'DRIVER_DITUGASKAN':
      case 'DRIVER_MENUJU_LOKASI':
        return OngoingStatus.processing;
      case 'SAMPAH_DIJEMPUT':
        return OngoingStatus.pickup;
      case 'VALIDASI_BANK_SAMPAH':
        return OngoingStatus.verifying;
      default:
        return OngoingStatus.processing;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
