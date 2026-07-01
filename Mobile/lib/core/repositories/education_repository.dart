import '../constants/api_config.dart';
import '../constants/app_images.dart';
import '../models/education_model.dart';
import '../services/api_service.dart';

/// Repository for education content — fetches from bank_sampah edukasi.php API.
class EducationRepository {
  final ApiService _api = ApiService.instance;

  /// Fetch articles from API (type=article — tanpa video_url).
  Future<List<ArticleModel>> getArticles({String search = ''}) async {
    try {
      final queryParams = <String, String>{'type': 'article'};
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await _api.get(ApiConfig.edukasi, queryParams: queryParams);
      if (response.success && response.data != null) {
        final items = response.data as List;
        return items.map<ArticleModel>((item) {
          return ArticleModel(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            imageAsset: AppImages.education1,
            imageUrl: item['image_url'],
            author: item['author'] ?? 'iTrashy',
            timeAgo: _formatTimeAgo(item['created_at'] ?? ''),
            description: item['excerpt'] ?? '',
            konten: item['konten'],
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Fetch videos from API (type=video — yang punya video_url).
  Future<List<VideoModel>> getVideos({String search = ''}) async {
    try {
      final queryParams = <String, String>{'type': 'video'};
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await _api.get(ApiConfig.edukasi, queryParams: queryParams);
      if (response.success && response.data != null) {
        final items = response.data as List;
        return items.map<VideoModel>((item) {
          return VideoModel(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            imageAsset: AppImages.education3,
            imageUrl: item['image_url'],
            author: item['author'] ?? 'iTrashy',
            timeAgo: _formatTimeAgo(item['created_at'] ?? ''),
            videoUrl: item['video_url'],
            konten: item['konten'],
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Fetch detail edukasi by ID.
  Future<Map<String, dynamic>?> getDetail(String id) async {
    try {
      final response = await _api.get(
        ApiConfig.edukasi,
        queryParams: {'id': id},
      );
      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<List<dynamic>> getLatestEducation({int limit = 4}) async {
    try {
      final response = await _api.get(ApiConfig.edukasi, queryParams: {'limit': limit.toString()});
      if (response.success && response.data != null) {
        final items = response.data as List;
        return items.map((item) {
          final isVideo = item['video_url'] != null && item['video_url'].toString().isNotEmpty;
          if (isVideo) {
            return VideoModel(
              id: item['id'].toString(),
              title: item['title'] ?? '',
              imageAsset: AppImages.education3,
              imageUrl: item['image_url'],
              author: item['author'] ?? 'iTrashy',
              timeAgo: _formatTimeAgo(item['created_at'] ?? ''),
              videoUrl: item['video_url'],
              konten: item['konten'],
            );
          } else {
            return ArticleModel(
              id: item['id'].toString(),
              title: item['title'] ?? '',
              imageAsset: AppImages.education1,
              imageUrl: item['image_url'],
              author: item['author'] ?? 'iTrashy',
              timeAgo: _formatTimeAgo(item['created_at'] ?? ''),
              description: item['excerpt'] ?? '',
              konten: item['konten'],
            );
          }
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  String _formatTimeAgo(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()} bulan lalu';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} hari lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam lalu';
      }
      return 'Baru saja';
    } catch (_) {
      return dateStr;
    }
  }
}
