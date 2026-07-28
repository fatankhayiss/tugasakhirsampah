import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/education_model.dart';
import '../../../core/repositories/education_repository.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final EducationRepository _repository = EducationRepository();
  String? _fullKonten;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    // Jika konten sudah ada dari list (API menyertakan konten di list), gunakan langsung
    if (widget.article.konten != null && widget.article.konten!.isNotEmpty) {
      setState(() {
        _fullKonten = widget.article.konten;
        _isLoading = false;
      });
      return;
    }

    // Fetch detail dari API
    final detail = await _repository.getDetail(widget.article.id);
    if (mounted) {
      setState(() {
        _fullKonten = detail?['konten'] ?? _fallbackKonten();
        _isLoading = false;
      });
    }
  }

  String _fallbackKonten() {
    return '${widget.article.title}. Langkah ini merupakan gerbang awal yang penting dalam mengurangi dampak negatif penumpukan sampah terhadap ekosistem lingkungan sekitar.\n\n'
        'Mendaur ulang sampah secara mandiri adalah langkah penting dalam mengurangi dampak negatif sampah terhadap lingkungan. '
        'Proses ini tidak hanya membantu mengurangi jumlah sampah yang terbuang ke tempat pembuangan akhir, '
        'tetapi juga dapat memberikan manfaat ekonomi dan sosial bagi individu dan komunitas.';
  }

  /// Helper widget untuk menampilkan gambar — network jika ada URL, fallback ke asset.
  Widget _buildImage(String? imageUrl, String imageAsset,
      {double? width, double? height, BoxFit fit = BoxFit.cover, String? heroTag}) {
    Widget imageWidget;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(imageAsset, width: width, height: height, fit: fit);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryBlue,
              ),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.asset(imageAsset, width: width, height: height, fit: fit);
    }

    if (heroTag != null) {
      return Hero(tag: heroTag, child: imageWidget);
    }
    return imageWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: const Text(
          'Artikel Edukasi',
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Text Header Details
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      height: 1.3,
                      letterSpacing: -0.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Metadata Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.article.kategori.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.softGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.book_open,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'by ${widget.article.author}  •  ${widget.article.timeAgo}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 2. Main Premium Rounded Image Cover
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildImage(
                  widget.article.imageUrl,
                  widget.article.imageAsset,
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.width * 0.55).clamp(180.0, 300.0),
                  heroTag: 'article_image_${widget.article.id}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // 3. Article Content from Database
            Padding(
              padding: const EdgeInsets.all(24),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullKonten ?? _fallbackKonten(),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            height: 1.9,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
