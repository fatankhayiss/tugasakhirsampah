class OrderModel {
  final String id;
  final String title;
  final String date;
  final String timeRange;
  final String estimatedWeight;
  final int estimatedPoints;
  final String? totalWeight;
  final int? totalPoints;
  final String status; // 'ongoing', 'selesai'
  final String imageAsset;

  OrderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.timeRange,
    required this.estimatedWeight,
    required this.estimatedPoints,
    this.totalWeight,
    this.totalPoints,
    required this.status,
    required this.imageAsset,
  });
}
