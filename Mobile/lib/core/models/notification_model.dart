class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // 'pickup', 'reward', 'info', 'transfer'
  final bool isRead;
  final String? imageAsset;
  final DateTime? createdAt;
  final String? priority;
  final int? relatedId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.imageAsset,
    this.createdAt,
    this.priority,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['id_notifikasi']?.toString() ?? '0';
    String rawTitle = json['judul']?.toString() ?? json['title']?.toString() ?? '';
    String rawMessage = json['pesan']?.toString() ?? json['message']?.toString() ?? '';
    final rawType = json['tipe']?.toString() ?? json['type']?.toString() ?? 'info';
    final isReadVal = json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1';
    final dt = DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now();

    final cleaned = _sanitizeTitleAndMessage(rawTitle, rawMessage, rawType);

    return NotificationModel(
      id: rawId,
      title: cleaned['title']!,
      message: cleaned['message']!,
      time: formatTimeAgo(json['created_at']?.toString() ?? ''),
      type: rawType.toLowerCase(),
      isRead: isReadVal,
      createdAt: dt,
      priority: json['priority']?.toString() ?? json['prioritas']?.toString(),
      relatedId: json['related_id'] != null ? int.tryParse(json['related_id'].toString()) : null,
    );
  }

  static Map<String, String> _sanitizeTitleAndMessage(String rawTitle, String rawMessage, String type) {
    String title = rawTitle.trim();
    String message = rawMessage.trim();

    title = title.replaceAll(RegExp(r'<[^>]*>'), '');
    message = message.replaceAll(RegExp(r'<[^>]*>'), '');

    if (message.startsWith('{') || message.startsWith('[') || message.contains('function()') || message.contains('var ') || message.contains('console.')) {
      message = '';
    }

    final upperMsg = message.toUpperCase();
    final upperTitle = title.toUpperCase();

    if (upperMsg == 'ORDER CREATED' || upperMsg == 'SUBMITTED' || upperTitle == 'ORDER CREATED') {
      title = 'Permintaan Dikirim';
      message = 'Permintaan penjemputan berhasil dibuat.';
    } else if (upperMsg == 'ADMIN APPROVED' || upperMsg == 'MENUNGGU_KONFIRMASI' || upperTitle == 'ADMIN APPROVED') {
      title = 'Permintaan Dikonfirmasi';
      message = 'Permintaan Anda telah dikonfirmasi.';
    } else if (upperMsg == 'PICKER ASSIGNED' || upperMsg == 'DRIVER_DITUGASKAN' || upperTitle == 'PICKER ASSIGNED') {
      title = 'Picker Ditugaskan';
      message = 'Picker telah ditugaskan.';
    } else if (upperMsg == 'PICKER ON THE WAY' || upperMsg == 'DRIVER_MENUJU_LOKASI' || upperTitle == 'PICKER ON THE WAY') {
      title = 'Picker Menuju Lokasi';
      message = 'Picker sedang menuju lokasi Anda.';
    } else if (upperMsg == 'PICKER NEARBY' || upperMsg == 'DRIVER_TIBA' || upperTitle == 'PICKER NEARBY' || upperMsg.contains('TIBADI SEKITAR') || upperMsg.contains('TELAH TIBA') || upperTitle.contains('DEKAT')) {
      title = '📍 Picker Sudah Dekat';
      message = 'Picker Anda telah tiba di sekitar lokasi penjemputan. Silakan siapkan sampah yang akan diserahkan.';
    } else if (upperMsg == 'WEIGHT VALIDATION' || upperMsg == 'PENIMBANGAN' || upperTitle == 'WEIGHT VALIDATION') {
      title = 'Penimbangan Berat';
      message = 'Picker sedang melakukan penimbangan.';
    } else if (upperMsg == 'WASTE PICKED UP' || upperMsg == 'SAMPAH_DIJEMPUT' || upperTitle == 'WASTE PICKED UP') {
      title = 'Sampah Dijemput';
      message = 'Sampah berhasil dijemput.';
    } else if (upperMsg == 'HEADING TO WASTE BANK' || upperMsg == 'MENUJU_BANK_SAMPAH' || upperTitle == 'HEADING TO WASTE BANK') {
      title = 'Menuju Bank Sampah';
      message = 'Sampah sedang dibawa ke Bank Sampah.';
    } else if (upperMsg == 'ADMIN VALIDATION' || upperMsg == 'VALIDASI_BANK_SAMPAH' || upperTitle == 'ADMIN VALIDATION') {
      title = 'Waiting Validation';
      message = 'Sedang divalidasi oleh Admin.';
    } else if (upperMsg == 'POINT CALCULATION' || upperMsg == 'POIN_DIPROSES' || upperTitle == 'POINT CALCULATION') {
      title = 'Poin Diproses';
      message = 'Poin sedang dihitung.';
    } else if (upperMsg == 'COMPLETED' || upperMsg == 'SELESAI' || upperTitle == 'COMPLETED') {
      title = 'Completed';
      message = 'Penjemputan selesai. Poin telah ditambahkan ke akun Anda.';
    } else if (upperMsg == 'CANCELLED' || upperMsg == 'DIBATALKAN' || upperTitle == 'CANCELLED') {
      title = 'Penjemputan Dibatalkan';
      message = 'Permintaan penjemputan berhasil dibatalkan.';
    }

    if (title.isEmpty) title = 'Notifikasi Sistem';
    if (message.isEmpty) message = 'Aktivitas Anda telah diperbarui.';

    return {'title': title, 'message': message};
  }

  static String formatTimeAgo(String dateStr) {
    if (dateStr.isEmpty) return 'Baru saja';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';

      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (date == yesterday) return 'Kemarin';

      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Baru saja';
    }
  }
}
