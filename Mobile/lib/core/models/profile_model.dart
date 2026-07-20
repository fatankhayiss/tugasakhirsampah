class ProfileModel {
  final String name;
  final String? username;
  final String email;
  final String avatarAsset;
  final String? avatarUrl;
  final String? address;
  final String? phone;
  final int totalWaste; // in kg
  final int totalPoints;
  final double? latitude;
  final double? longitude;

  ProfileModel({
    required this.name,
    this.username,
    required this.email,
    required this.avatarAsset,
    this.avatarUrl,
    this.address,
    this.phone,
    required this.totalWaste,
    required this.totalPoints,
    this.latitude,
    this.longitude,
  });
}
