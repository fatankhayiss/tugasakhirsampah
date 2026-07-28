import '../constants/api_config.dart';

class ImageUtils {
  /// Safely resolves the full image URL.
  /// Handles null, empty, http/https, and paths that need the baseUrl appended.
  static String getFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final baseUrl = ApiConfig.baseUrl.endsWith('/') 
        ? ApiConfig.baseUrl 
        : '${ApiConfig.baseUrl}/';
        
    return '${baseUrl}bank_sampah/$cleanPath';
  }
}
