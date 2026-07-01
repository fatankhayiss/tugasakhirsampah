class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // 'order', 'promo', 'info', 'achievement'
  final bool isRead;
  final String? imageAsset;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.imageAsset,
  });
}
