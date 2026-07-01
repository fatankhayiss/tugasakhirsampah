class WasteItem {
  final String id;
  final String name;
  final String imageAsset;
  final double pricePerKg;
  int quantity;
  double weight;

  WasteItem({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.pricePerKg,
    this.quantity = 1,
    this.weight = 1.0,
  });

  double get totalPrice => weight * pricePerKg;
}
