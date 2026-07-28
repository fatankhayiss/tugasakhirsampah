import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';

/// Reusable poin currency badge — custom logo + amount label.
///
/// Premium eco-fintech identity system.
/// Supports responsive layout via [Flexible] wrapping.
class PointBadge extends StatelessWidget {
  final String amount;
  final double logoSize;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final String? suffix;
  final bool showLogoContainer;

  const PointBadge({
    super.key,
    required this.amount,
    this.logoSize = 18,
    this.textColor = Colors.white,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.suffix,
    this.showLogoContainer = false,
  });

  /// Large balance amount e.g. `[logo] 7.500 Poin`.
  const PointBadge.balanceAmount({
    super.key,
    required this.amount,
    this.logoSize = 24,
    this.textColor = Colors.white,
    this.fontSize = 36,
    this.suffix = 'Poin',
  }) : fontWeight = FontWeight.w700,
       showLogoContainer = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PointLogo(
          size: logoSize,
          inContainer: showLogoContainer,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: Text(
                    amount,
                    key: ValueKey<String>(amount),
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      letterSpacing: -1.0,
                      height: 1,
                    ),
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    suffix!,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: fontSize * 0.45,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// POINT LOGO IMAGE
// FILE:
// assets/icons/point_logo.png
//
// Ganti logo poin di sini
// =====================================================

/// Custom point logo — eco fintech identity.
class _PointLogo extends StatelessWidget {
  final double size;
  final bool inContainer;

  const _PointLogo({
    required this.size,
    this.inContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppImages.pointLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!inContainer) return image;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: 0.95,
        child: image,
      ),
    );
  }
}

/// Compact row: [logo] amount (for cards, lists, profile).
class PointAmountRow extends StatelessWidget {
  final String amount;
  final double logoSize;
  final TextStyle? textStyle;
  final Color? pointColor;

  const PointAmountRow({
    super.key,
    required this.amount,
    this.logoSize = 18,
    this.textStyle,
    this.pointColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = pointColor ?? AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppImages.pointLogo,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            amount,
            style: textStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.3,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
