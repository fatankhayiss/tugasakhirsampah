import 'package:flutter/material.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';

enum OrdersEmptyVariant { ongoing, filter, generic }

class EmptyStateWidget extends StatelessWidget {
  final OrdersEmptyVariant variant;
  final String? title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.variant = OrdersEmptyVariant.generic,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
    this.icon = Icons.recycling_rounded,
  });

  const EmptyStateWidget.ongoing({
    super.key,
    required VoidCallback onStartDeposit,
  }) : variant = OrdersEmptyVariant.ongoing,
       title = 'Belum Ada Proses Aktif',
       subtitle =
           'Setoran sampah yang sedang diproses akan muncul di halaman ini.',
       buttonLabel = 'Mulai Setor Sampah',
       onButtonPressed = onStartDeposit,
       icon = Icons.inventory_2_outlined;

  const EmptyStateWidget.filter({
    super.key,
  }) : variant = OrdersEmptyVariant.filter,
       title = 'Belum ada transaksi',
       subtitle = null,
       buttonLabel = null,
       onButtonPressed = null,
       icon = Icons.receipt_long_outlined;

  @override
  Widget build(BuildContext context) {
    final isCompact = variant == OrdersEmptyVariant.filter;
    final iconSize = isCompact ? 48.0 : 64.0;
    final padding = isCompact ? 16.0 : 24.0;

    return FadeInAnimation(
      duration: const Duration(milliseconds: 500),
      child: SlideUpAnimation(
        duration: const Duration(milliseconds: 500),
        startOffset: 0.06,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 32 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: isCompact ? 16 : 24),
                Text(
                  title ?? 'Belum ada riwayat transaksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isCompact ? 15 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                ],
                if (buttonLabel != null && onButtonPressed != null) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        buttonLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
