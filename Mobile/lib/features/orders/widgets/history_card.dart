import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../shared/widgets/scale_tap.dart';
import '../models/history_item_model.dart';
import '../screens/order_detail_screen.dart';

class HistoryCard extends StatefulWidget {
  final HistoryItemModel item;

  const HistoryCard({super.key, required this.item});

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  Color _getBadgeBg(String? status) {
    if (status == null) return const Color(0xFFDDF8E7);
    final s = status.toLowerCase();
    if (s.contains('batal') || s.contains('gagal') || s.contains('cancel')) {
      return const Color(0xFFFEE2E2);
    } else if (s.contains('proses') || s.contains('processing')) {
      return const Color(0xFFDBEAFE);
    } else if (s.contains('tunggu') || s.contains('pending')) {
      return const Color(0xFFFEF3C7);
    }
    return const Color(0xFFDDF8E7);
  }

  Color _getBadgeText(String? status) {
    if (status == null) return const Color(0xFF2DAA63);
    final s = status.toLowerCase();
    if (s.contains('batal') || s.contains('gagal') || s.contains('cancel')) {
      return const Color(0xFFDC2626);
    } else if (s.contains('proses') || s.contains('processing')) {
      return const Color(0xFF1D4ED8);
    } else if (s.contains('tunggu') || s.contains('pending')) {
      return const Color(0xFFD97706);
    }
    return const Color(0xFF2DAA63);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: () {
        if (widget.item.type == HistoryType.setor) {
          Navigator.push(
            context,
            CustomPageRoute(
              page: OrderDetailScreen(orderId: widget.item.id),
            ),
          );
        }
      },
      scaleDown: 0.98,
      duration: const Duration(milliseconds: 160),
      enableHaptic: true,
      executeOnTap: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7F4), // Premium soft eco background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {
              if (widget.item.type == HistoryType.setor) {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    page: OrderDetailScreen(orderId: widget.item.id),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header Row: White rounded icon container + right-aligned capsule status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2DAA63).withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppImages.orderLogo,
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getBadgeBg(widget.item.statusLabel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.item.statusLabel ?? 'Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _getBadgeText(widget.item.statusLabel),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title and Date/Time Info
              Text(
                widget.item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.date,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B8190),
                ),
              ),
              const SizedBox(height: 18),

              // Subtle premium divider
              Container(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                height: 1.0,
                width: double.infinity,
              ),
              const SizedBox(height: 16),

              // Bottom details row with clear columns
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Berat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B8190),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.weight ?? '-',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Poin Didapat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B8190),
                          ),
                        ),
                        const SizedBox(height: 4),
                        PointAmountRow(
                          amount: widget.item.points,
                          logoSize: 16,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2DAA63),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

