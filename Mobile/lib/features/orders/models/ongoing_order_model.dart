enum OngoingStatus {
  pending,
  processing,
  pickup,
  verifying,
}

extension OngoingStatusExtension on OngoingStatus {
  String get label {
    switch (this) {
      case OngoingStatus.pending:
        return 'Menunggu';
      case OngoingStatus.processing:
        return 'Diproses';
      case OngoingStatus.pickup:
        return 'Pickup';
      case OngoingStatus.verifying:
        return 'Verifikasi';
    }
  }
}

class OngoingOrderModel {
  final String id;
  final String title;
  final String date;
  final String subtitle;
  final OngoingStatus status;
  final String? estimatedPoints;
  final String? driverName;

  const OngoingOrderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.status,
    this.estimatedPoints,
    this.driverName,
  });
}
