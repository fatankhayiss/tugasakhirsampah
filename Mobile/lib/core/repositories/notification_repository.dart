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
      final response = await _api.get(ApiConfig.notifikasi);
      if (response.success && response.data != null) {
        _unreadCount = response.data['unread_count'] ?? 0;
        final items = response.data['items'] as List? ?? [];
        
        _notifications = items.map<NotificationModel>((item) {
          final dt = DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();
          return NotificationModel(
            id: item['id'].toString(),
            title: item['judul'] ?? '',
            message: item['pesan'] ?? '',
            time: _formatTimeAgo(item['created_at'] ?? ''),
            type: item['tipe'] ?? 'info',
            isRead: item['is_read'] == true,
            createdAt: dt,
            priority: item['priority'] ?? item['prioritas'], // Handling possible priority fields
            relatedId: item['related_id'] != null ? int.tryParse(item['related_id'].toString()) : null,
          );
        }).toList();

        // Sort descending by date
        _notifications.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

        notifyListeners();
        return _notifications;
      } else {
        throw Exception(response.message.isEmpty ? 'Gagal memuat notifikasi' : response.message);
      }
    } catch (e) {
      throw Exception('Gagal memuat notifikasi: $e');
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
    switch (status.toLowerCase()) {
      case 'pending':
        title = 'Menunggu Konfirmasi Admin';
        if (message.isEmpty) message = 'Permintaan setoran sampah #$orderId sedang menunggu verifikasi admin dan penugasan driver.';
        break;
      case 'accepted':
        title = 'Pesanan Diterima & Driver Ditugaskan';
        if (message.isEmpty) message = 'Driver telah ditugaskan untuk pesanan #$orderId dan bersiap menuju lokasi Anda.';
        break;
      case 'on_the_way':
        title = 'Driver Sedang Menuju Lokasi';
        if (message.isEmpty) message = 'Driver dalam perjalanan menuju alamat penjemputan pesanan #$orderId.';
        break;
      case 'picked_up':
        title = 'Sampah Berhasil Dijemput';
        if (message.isEmpty) message = 'Sampah pesanan #$orderId telah diangkut driver dan menuju gudang Bank Sampah.';
        break;
      case 'validating':
        title = 'Proses Penimbangan & Validasi';
        if (message.isEmpty) message = 'Sampah pesanan #$orderId sedang ditimbang dan divalidasi oleh petugas gudang.';
        break;
      case 'completed':
        title = 'Setoran Selesai! Poin Ditambahkan';
        if (message.isEmpty) message = 'Proses validasi pesanan #$orderId selesai. Poin reward telah masuk ke saldo Anda.';
        break;
      default:
        title = 'Pembaruan Status Pesanan';
        if (message.isEmpty) message = 'Pesanan #$orderId kini berstatus ${status.toUpperCase()}.';
    }

    addNotification(
      NotificationModel(
        id: '${status.toLowerCase()}_$orderId',
        title: title,
        message: message,
        time: 'Baru saja',
        type: status.toLowerCase(),
        isRead: false,
        createdAt: DateTime.now(),
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

  String _formatTimeAgo(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} bulan lalu';
      if (diff.inDays > 0) return '${diff.inDays} hari lalu';
      if (diff.inHours > 0) return '${diff.inHours} jam lalu';
      if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
      return 'Baru saja';
    } catch (_) {
      return dateStr;
    }
  }
}
