import 'package:flutter/foundation.dart';
import '../constants/api_config.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

/// Repository for notifications — fetches from bank_sampah notifikasi_api.php.
class NotificationRepository extends ChangeNotifier {
  // Stateful Singleton Pattern
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  final ApiService _api = ApiService.instance;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _loaded = false;

  int get unreadCount => _unreadCount;

  /// Fetch notifications from API.
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _api.get(ApiConfig.notifikasi);
      if (response.success && response.data != null) {
        _unreadCount = response.data['unread_count'] ?? 0;
        final items = response.data['items'] as List? ?? [];
        _notifications = items.map<NotificationModel>((item) {
          return NotificationModel(
            id: item['id'].toString(),
            title: item['judul'] ?? '',
            message: item['pesan'] ?? '',
            time: _formatTimeAgo(item['created_at'] ?? ''),
            type: item['tipe'] ?? 'info',
            isRead: item['is_read'] == true,
          );
        }).toList();
        _loaded = true;
        notifyListeners();
        return _notifications;
      }
    } catch (_) {}

    // Fallback if API fails and no data loaded yet
    if (!_loaded) {
      _notifications = _getFallbackNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _loaded = true;
      notifyListeners();
    }
    return _notifications;
  }

  List<NotificationModel> getNotifications() {
    if (!_loaded) {
      // Trigger async fetch but return fallback immediately
      fetchNotifications();
      return _getFallbackNotifications();
    }
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

  List<NotificationModel> _getFallbackNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Penjemputan sampah berhasil diselesaikan',
        message: 'Poin reward telah ditambahkan ke akun Anda.',
        time: '2 jam lalu',
        type: 'reward',
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Picker sedang menuju lokasi penjemputan Anda',
        message: 'Estimasi tiba 10–15 menit lagi.',
        time: '5 jam lalu',
        type: 'pickup',
        isRead: false,
      ),
    ];
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
