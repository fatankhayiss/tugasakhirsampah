import 'package:flutter/foundation.dart';
import '../constants/api_config.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

/// Repository for notifications — fetches from bank_sampah notifikasi_api.php.
class NotificationRepository extends ChangeNotifier {
  // Stateful Singleton Pattern
  static final NotificationRepository _instance = NotificationRepository._internal();
  static NotificationRepository get instance => _instance;
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  final ApiService _api = ApiService.instance;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  /// Fetch notifications from API.
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      debugPrint('==================================================');
      debugPrint('Fetching Notifications');
      final userData = await _api.getUserData();
      final userId = userData?['id']?.toString() ?? 'N/A';
      debugPrint('User ID: $userId');
      debugPrint('Request URL: ${ApiConfig.notifikasi}');
      debugPrint('Request Body: N/A (GET)');

      final response = await _api.get(ApiConfig.notifikasi);

      debugPrint('Response Success: ${response.success}');
      debugPrint('Response Message: ${response.message}');
      debugPrint('Decoded JSON: ${response.data}');
      debugPrint('==================================================');

      if (response.success && response.data != null) {
        _unreadCount = response.data['unread_count'] ?? 0;
        final items = response.data['items'] as List? ?? [];
        
        _notifications = items
            .map<NotificationModel>((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        // Sort descending by date
        _notifications.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

        notifyListeners();
        return _notifications;
      } else {
        throw Exception(response.message.isEmpty ? 'Gagal memuat notifikasi' : response.message);
      }
    } catch (e) {
      debugPrint('NotificationRepository.fetchNotifications Exception: $e');
      throw Exception('HTTP Status / Error: $e');
    }
  }

  List<NotificationModel> getNotifications() {
    return _notifications;
  }

  /// Mark all notifications as read via API.
  Future<void> markAllAsRead() async {
    try {
      await _api.put(ApiConfig.notifikasi, body: {'mark_all': true});
    } catch (_) {}

    _notifications = _notifications.map((notif) {
      return NotificationModel(
        id: notif.id,
        title: notif.title,
        message: notif.message,
        time: notif.time,
        type: notif.type,
        isRead: true,
        imageAsset: notif.imageAsset,
        createdAt: notif.createdAt,
        priority: notif.priority,
        relatedId: notif.relatedId,
      );
    }).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  /// Mark single notification as read via API.
  Future<void> markAsRead(String id) async {
    try {
      await _api.put(ApiConfig.notifikasi, body: {'id_notifikasi': int.parse(id)});
    } catch (_) {}

    bool changed = false;
    _notifications = _notifications.map((notif) {
      if (notif.id == id && !notif.isRead) {
        changed = true;
        return NotificationModel(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          time: notif.time,
          type: notif.type,
          isRead: true,
          imageAsset: notif.imageAsset,
          createdAt: notif.createdAt,
          priority: notif.priority,
          relatedId: notif.relatedId,
        );
      }
      return notif;
    }).toList();

    if (changed) {
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
    notifyListeners();
  }

  /// Update or generate a notification when order status changes.
  void notifyOrderStatusChange({
    required String orderId,
    required String status,
    String? customMessage,
  }) {
    String title = '';
    String message = customMessage ?? '';
    final cleanStatus = status.toLowerCase();

    switch (cleanStatus) {
      case 'submitted':
      case 'order_created':
        title = 'Permintaan Dikirim';
        message = 'Permintaan penjemputan berhasil dibuat.';
        break;
      case 'pending':
      case 'menunggu_konfirmasi':
        title = 'Permintaan Dikonfirmasi';
        message = 'Permintaan Anda telah dikonfirmasi.';
        break;
      case 'accepted':
      case 'driver_ditugaskan':
      case 'picker_assigned':
        title = 'Picker Ditugaskan';
        message = 'Picker telah ditugaskan.';
        break;
      case 'on_the_way':
      case 'driver_menuju_lokasi':
      case 'picker_on_the_way':
        title = 'Picker Menuju Lokasi';
        message = 'Picker sedang menuju lokasi Anda.';
        break;
      case 'arrived':
      case 'driver_tiba':
      case 'picker_nearby':
        title = '📍 Picker Sudah Dekat';
        message = 'Picker Anda telah tiba di sekitar lokasi penjemputan. Silakan siapkan sampah yang akan diserahkan.';
        break;
      case 'penimbangan':
      case 'weight_validation':
        title = 'Penimbangan Berat';
        message = 'Picker sedang melakukan penimbangan.';
        break;
      case 'picked_up':
      case 'sampah_dijemput':
      case 'waste_picked_up':
        title = 'Sampah Dijemput';
        message = 'Sampah berhasil dijemput.';
        break;
      case 'heading_to_waste_bank':
      case 'menuju_bank_sampah':
        title = 'Menuju Bank Sampah';
        message = 'Sampah sedang dibawa ke Bank Sampah.';
        break;
      case 'validating':
      case 'validasi_bank_sampah':
      case 'admin_validation':
        title = 'Waiting Validation';
        message = 'Sedang divalidasi oleh Admin.';
        break;
      case 'poin_diproses':
      case 'point_calculation':
        title = 'Poin Diproses';
        message = 'Poin sedang dihitung.';
        break;
      case 'completed':
      case 'selesai':
        title = 'Completed';
        message = "Penjemputan selesai. Poin telah ditambahkan ke akun Anda.";
        break;
      case 'cancelled':
      case 'dibatalkan':
        title = 'Penjemputan Dibatalkan';
        message = 'Permintaan penjemputan berhasil dibatalkan.';
        break;
      default:
        title = 'Permintaan Dikonfirmasi';
        if (message.isEmpty) message = 'Permintaan Anda telah dikonfirmasi.';
    }

    addNotification(
      NotificationModel(
        id: '${cleanStatus}_$orderId',
        title: title,
        message: message,
        time: 'Baru saja',
        type: 'pickup',
        isRead: false,
        createdAt: DateTime.now(),
        relatedId: int.tryParse(orderId),
      ),
    );
  }

  /// Notify citizen when Tukar Poin redemption status changes
  void notifyRedemptionStatusChange({
    required String redemptionId,
    required String status,
    String? title,
    String? message,
  }) {
    final cleanStatus = status.toLowerCase();
    String defaultTitle;
    String defaultMessage;

    switch (cleanStatus) {
      case 'pending':
        defaultTitle = 'Tukar Poin Diterima';
        defaultMessage = 'Tukar poin Anda telah diterima.';
        break;
      case 'processing':
        defaultTitle = 'Tukar Poin Diproses';
        defaultMessage = 'Admin sedang memproses penukaran poin Anda.';
        break;
      case 'completed':
        defaultTitle = 'Tukar Poin Berhasil';
        defaultMessage = 'Penukaran poin berhasil.';
        break;
      case 'rejected':
      case 'cancelled':
        defaultTitle = 'Tukar Poin Ditolak';
        defaultMessage = 'Penukaran poin ditolak.';
        break;
      default:
        defaultTitle = 'Pembaruan Tukar Poin';
        defaultMessage = 'Status penukaran poin #$redemptionId kini $status.';
    }

    addNotification(
      NotificationModel(
        id: 'redemption_${cleanStatus}_$redemptionId',
        title: title ?? defaultTitle,
        message: message ?? defaultMessage,
        time: 'Baru saja',
        type: 'transfer',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
  }
}
