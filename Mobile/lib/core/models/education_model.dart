class ArticleModel {
  final String id;
  final String title;
  final String imageAsset;
  final String? imageUrl;
  final String author;
  final String timeAgo;
  final String description;
  final String? konten;
  final String kategori;

  ArticleModel({
    required this.id,
    required this.title,
    required this.imageAsset,
    this.imageUrl,
    required this.author,
    required this.timeAgo,
    this.description = 'Langkah penting dalam mengurangi dampak negatif sampah terhadap lingkungan sekitar.',
    this.konten,
    this.kategori = 'Umum',
  });
}

class EventModel {
  final String id;
  final String title;
  final String imageAsset;
  final String author;
  final String timeAgo;

  EventModel({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.author,
    required this.timeAgo,
  });
}

class VideoModel {
  final String id;
  final String title;
  final String imageAsset;
  final String? imageUrl;
  final String author;
  final String timeAgo;
  final String? videoUrl;
  final String? konten;
  final String kategori;

  VideoModel({
    required this.id,
    required this.title,
    required this.imageAsset,
    this.imageUrl,
    required this.author,
    required this.timeAgo,
    this.videoUrl,
    this.konten,
    this.kategori = 'Umum',
  });
}
