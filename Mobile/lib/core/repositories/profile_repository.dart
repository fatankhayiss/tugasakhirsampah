import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

/// Repository for user profile — fetches from bank_sampah profile_api.php.
class ProfileRepository {
  final ApiService _api = ApiService.instance;

  /// Get profile from API. Falls back to local data if API fails.
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _api.get(ApiConfig.profile);
      if (response.success && response.data != null) {
        final d = response.data as Map<String, dynamic>;
        return ProfileModel(
          name: d['nama_lengkap'] ?? 'User',
          email: d['email'] ?? d['username'] ?? '',
          avatarAsset: AppImages.avatar,
          avatarUrl: d['foto_profil'] != null ? '${ApiConfig.baseUrl}${d['foto_profil']}' : null,
          totalWaste: (d['total_waste_kg'] ?? 0).toDouble().round(),
          totalPoints: ((d['saldo'] ?? 0).toDouble()).round(),
        );
      }
    } catch (_) {
      // Fallback ke data lokal
    }

    // Fallback: coba dari data tersimpan
    final saved = await _api.getUserData();
    if (saved != null) {
      return ProfileModel(
        name: saved['nama_lengkap'] ?? 'User',
        email: saved['email'] ?? saved['username'] ?? '',
        avatarAsset: AppImages.avatar,
        avatarUrl: saved['foto_profil'] != null ? '${ApiConfig.baseUrl}${saved['foto_profil']}' : null,
        totalWaste: (saved['total_waste_kg'] ?? 0).toDouble().round(),
        totalPoints: ((saved['saldo'] ?? 0).toDouble()).round(),
      );
    }

    // Final fallback
    return ProfileModel(
      name: 'User',
      email: '-',
      avatarAsset: AppImages.avatar,
      totalWaste: 0,
      totalPoints: 0,
    );
  }

  /// Update profile via API.
  Future<bool> updateProfile({
    String? namaLengkap,
    String? alamat,
    String? noTelepon,
    String? email,
  }) async {
    final body = <String, String>{};
    if (namaLengkap != null) body['nama_lengkap'] = namaLengkap;
    if (alamat != null) body['alamat'] = alamat;
    if (noTelepon != null) body['no_telepon'] = noTelepon;
    if (email != null) body['email'] = email;

    final response = await _api.post(ApiConfig.profile, body: body);
    return response.success;
  }

  /// Upload photo via API
  Future<bool> uploadAvatar(List<int> fileBytes, String filename) async {
    final response = await _api.postMultipart(
      ApiConfig.profile,
      files: {'foto_profil': fileBytes},
      fileNames: {'foto_profil': filename},
    );
    return response.success;
  }
}
