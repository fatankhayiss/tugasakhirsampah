import 'dart:convert';
import '../../features/orders/models/history_item_model.dart';
import '../../features/orders/models/ongoing_order_model.dart';
import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

/// Repository for orders — fetches from bank_sampah orders_api.php & transaksi_api.php.
class OrderRepository {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  final ApiService _api = ApiService.instance;

  /// In-memory ongoing orders (supplemented by API data).
  final List<OngoingOrderModel> _localOngoing = [];

  void addOrder(OrderModel order) {
    _localOngoing.insert(
      0,
      OngoingOrderModel(
        id: order.id,
        title: order.title,
        date: order.date,
        subtitle: '${order.estimatedWeight} · Est. ${order.estimatedPoints} poin',
        status: OngoingStatus.processing,
        estimatedPoints: '+${order.estimatedPoints} poin',
      ),
    );
  }

  void addOngoing(OngoingOrderModel order) {
    _localOngoing.insert(0, order);
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

  /// Fetch ongoing orders from API.
  Future<List<OngoingOrderModel>> getOngoingOrders() async {
    try {
      final userData = await _api.getUserData();
      final userId = userData?['id']?.toString() ?? '';
      if (userId.isEmpty) return List.unmodifiable(_localOngoing);

      final response = await _api.get(ApiConfig.orders, queryParams: {
        'user_id': userId,
        'status': 'pending,accepted,on_the_way,picked_up',
      });

      if (response.success && response.data != null) {
        final items = response.data['items'] as List? ?? [];
        final apiOrders = items.map<OngoingOrderModel>((item) {
          final status = _mapStatus(item['status'] ?? 'pending');
          return OngoingOrderModel(
            id: item['id'].toString(),
            title: 'Jemput Sampah',
            date: _formatDate(item['created_at'] ?? ''),
            subtitle: '${item['estimasi_berat'] ?? '-'} · ${item['items_count'] ?? 0} jenis',
            status: status,
            estimatedPoints: '+${item['estimasi_poin'] ?? 0} poin',
            driverName: item['nama_driver'],
          );
        }).toList();

        return [..._localOngoing, ...apiOrders];
      }
    } catch (_) {}
    return List.unmodifiable(_localOngoing);
  }

  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final response = await _api.get(ApiConfig.orders, queryParams: {
        'id': orderId,
      });
      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Cancel an order (set status to cancelled)
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _api.put(ApiConfig.orders, body: {
        'id_order': orderId,
        'status': 'cancelled',
      });
      return response.success;
    } catch (_) {
      return false;
    }
  }

  /// Fetch history (completed transactions) from API.
  Future<List<HistoryItemModel>> getHistoryItems() async {
    try {
      final response = await _api.get(ApiConfig.transaksi);
      if (response.success && response.data != null) {
        final items = response.data['items'] as List? ?? [];
        return items.map<HistoryItemModel>((item) {
          final isSetor = item['tipe'] == 'setor';
          final nilai = (item['total_nilai'] as num?)?.toDouble() ?? 0;
          final berat = isSetor ? (item['total_berat_kg'] as num?)?.toDouble() : null;

          return HistoryItemModel(
            id: item['id'].toString(),
            title: isSetor ? 'Setor Sampah' : 'Pencairan Saldo',
            date: _formatDate(item['tanggal'] ?? ''),
            points: isSetor ? '+${nilai.toInt()} POIN' : '-${nilai.toInt()} Poin',
            type: isSetor ? HistoryType.setor : HistoryType.pencairan,
            weight: berat != null ? '${berat.toStringAsFixed(2)} kg terkumpul' : null,
            statusLabel: 'Selesai',
          );
        }).toList();
      }
    } catch (_) {}

    // Fallback to empty
    return [];
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
      case 'pending':
        return OngoingStatus.processing;
      case 'accepted':
      case 'on_the_way':
        return OngoingStatus.processing;
      case 'picked_up':
        return OngoingStatus.processing;
      case 'completed':
        return OngoingStatus.processing;
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
