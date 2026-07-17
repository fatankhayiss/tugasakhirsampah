class WasteItem {
  final String id;
  final String name;
  final String imageAsset;
  final double pricePerKg;
  int quantity;
  double weight;

  // Optional fields for AI Scanned Items
  final String? imageUrl;
  final String? category;
  final String? confidence;
  final bool isScanned;

  WasteItem({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.pricePerKg,
    this.quantity = 1,
    this.weight = 1.0,
    this.imageUrl,
    this.category,
    this.confidence,
    this.isScanned = false,
  });

  double get totalPrice => weight * pricePerKg;
}
