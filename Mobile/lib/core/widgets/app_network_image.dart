import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = ImageUtils.getFullUrl(url);

    if (fullUrl.isEmpty) {
      return _buildError();
    }

    return Image.network(
      fullUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) => _buildError(),
    );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFF3F4F6),
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
        );
  }
}
