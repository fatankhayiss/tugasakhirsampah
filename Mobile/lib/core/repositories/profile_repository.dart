import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

/// Repository for user profile — fetches from bank_sampah profile_api.php.
class ProfileRepository {
  final ApiService _api = ApiService.instance;

  String? _formatAvatarUrl(dynamic fotoProfil) {
    if (fotoProfil == null) return null;
    final foto = fotoProfil.toString().trim();
    if (foto.isEmpty) return null;
    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return foto;
    }
    return '${ApiConfig.baseUrl}$foto';
  }

  /// Get profile from API. Falls back to local data if API fails.
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _api.get(ApiConfig.profile);
      if (response.success && response.data != null) {
        final d = response.data as Map<String, dynamic>;
        await _api.saveUserData(d);
        return ProfileModel(
          name: d['nama_lengkap'] ?? d['username'] ?? 'User',
          username: d['username']?.toString(),
          email: d['email'] ?? d['username'] ?? '',
          avatarAsset: AppImages.avatar,
          avatarUrl: _formatAvatarUrl(d['foto_profil']),
          address: d['alamat']?.toString(),
          phone: d['no_telepon']?.toString(),
          totalWaste: (d['total_waste_kg'] ?? 0).toDouble().round(),
          totalPoints: ((d['saldo'] ?? 0).toDouble()).round(),
          latitude: d['latitude'] != null ? (d['latitude'] as num).toDouble() : null,
          longitude: d['longitude'] != null ? (d['longitude'] as num).toDouble() : null,
        );
      }
    } catch (_) {
      // Fallback ke data lokal
    }

    // Fallback: coba dari data tersimpan
    final saved = await _api.getUserData();
    if (saved != null) {
      return ProfileModel(
        name: saved['nama_lengkap'] ?? saved['username'] ?? 'User',
        username: saved['username']?.toString(),
        email: saved['email'] ?? saved['username'] ?? '',
        avatarAsset: AppImages.avatar,
        avatarUrl: _formatAvatarUrl(saved['foto_profil']),
        address: saved['alamat']?.toString(),
        phone: saved['no_telepon']?.toString(),
        totalWaste: (saved['total_waste_kg'] ?? 0).toDouble().round(),
        totalPoints: ((saved['saldo'] ?? 0).toDouble()).round(),
        latitude: saved['latitude'] != null ? (saved['latitude'] as num).toDouble() : null,
        longitude: saved['longitude'] != null ? (saved['longitude'] as num).toDouble() : null,
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
  Future<({bool success, String message})> updateProfile({
    String? namaLengkap,
    String? username,
    String? alamat,
    String? noTelepon,
    String? email,
    double? latitude,
    double? longitude,
    bool? removeFoto,
  }) async {
    final body = <String, String>{};
    if (namaLengkap != null) body['nama_lengkap'] = namaLengkap;
    if (username != null) body['username'] = username;
    if (alamat != null) body['alamat'] = alamat;
    if (noTelepon != null) body['no_telepon'] = noTelepon;
    if (email != null) body['email'] = email;
    if (latitude != null) body['latitude'] = latitude.toString();
    if (longitude != null) body['longitude'] = longitude.toString();
    if (removeFoto == true) body['remove_foto'] = '1';

    final response = await _api.post(ApiConfig.profile, body: body);
    return (success: response.success, message: response.message);
  }

  /// Remove photo via API
  Future<bool> removeAvatar() async {
    final response = await _api.post(ApiConfig.profile, body: {'remove_foto': '1'});
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
