import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../shared/widgets/scale_tap.dart';
import '../models/history_item_model.dart';
import '../screens/order_detail_screen.dart';
import '../screens/redemption_detail_screen.dart';

class TransactionCard extends StatefulWidget {
  final HistoryItemModel item;

  const TransactionCard({super.key, required this.item});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  Color _getBadgeBg(String? status) {
    if (status == null) return const Color(0xFFDDF8E7);
    final s = status.toLowerCase();
    if (s.contains('batal') || s.contains('gagal') || s.contains('cancel') || s.contains('tolak') || s.contains('reject')) {
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
    if (s.contains('batal') || s.contains('gagal') || s.contains('cancel') || s.contains('tolak') || s.contains('reject')) {
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
    final style = _styleFor(widget.item.type);
    final pointColor = widget.item.points.startsWith('+')
        ? const Color(0xFF2DAA63)
        : const Color(0xFFE53935);

    return ScaleTap(
      onTap: () {
        if (widget.item.type == HistoryType.setor) {
          Navigator.push(
            context,
            CustomPageRoute(
              page: OrderDetailScreen(orderId: widget.item.id),
            ),
          );
        } else if (widget.item.type == HistoryType.pencairan || widget.item.destination != null) {
          Navigator.push(
            context,
            CustomPageRoute(
              page: RedemptionDetailScreen(
                redemptionId: widget.item.id,
                historyItem: widget.item,
              ),
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
          color: Colors.white, // Clean white background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
              } else if (widget.item.type == HistoryType.pencairan || widget.item.destination != null) {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    page: RedemptionDetailScreen(
                      redemptionId: widget.item.id,
                      historyItem: widget.item,
                    ),
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
                          color: style.iconColor.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      style.icon,
                      color: style.iconColor,
                      size: 26,
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
                        Text(
                          widget.item.type == HistoryType.pencairan ? 'Nominal' : 'Metode',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B8190),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.weight ?? 'E-Wallet',
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
                        Text(
                          widget.item.type == HistoryType.pencairan ? 'Poin Ditukar' : 'Poin',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B8190),
                          ),
                        ),
                        const SizedBox(height: 4),
                        PointAmountRow(
                          amount: widget.item.points,
                          logoSize: 16,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: pointColor,
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

  _TransactionStyle _styleFor(HistoryType type) {
    switch (type) {
      case HistoryType.pencairan:
        return const _TransactionStyle(
          icon: Icons.payments_rounded,
          iconColor: Color(0xFFE65100),
          backgroundColor: Color(0xFFFFF3E0),
        );
      case HistoryType.bonus:
        return const _TransactionStyle(
          icon: Icons.card_giftcard_rounded,
          iconColor: Color(0xFF2DAA63),
          backgroundColor: Color(0xFFDDF8E7),
        );
      case HistoryType.penukaran:
        return const _TransactionStyle(
          icon: Icons.local_activity_rounded,
          iconColor: Color(0xFF1565C0),
          backgroundColor: Color(0xFFE3F2FD),
        );
      case HistoryType.setor:
        return const _TransactionStyle(
          icon: Icons.recycling_rounded,
          iconColor: Color(0xFF2DAA63),
          backgroundColor: Color(0xFFDDF8E7),
        );
    }
  }
}

class _TransactionStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _TransactionStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

