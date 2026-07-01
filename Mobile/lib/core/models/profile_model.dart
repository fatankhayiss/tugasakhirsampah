class ProfileModel {
  final String name;
  final String email;
  final String avatarAsset;
  final String? avatarUrl;
  final int totalWaste; // in kg
  final int totalPoints;

  ProfileModel({
    required this.name,
    required this.email,
    required this.avatarAsset,
    this.avatarUrl,
    required this.totalWaste,
    required this.totalPoints,
  });
}
