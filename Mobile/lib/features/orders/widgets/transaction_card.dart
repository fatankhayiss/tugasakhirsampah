import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/point_badge.dart';
import '../models/history_item_model.dart';

class TransactionCard extends StatefulWidget {
  final HistoryItemModel item;

  const TransactionCard({super.key, required this.item});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(widget.item.type);
    final pointColor = widget.item.points.startsWith('+')
        ? const Color(0xFF2DAA63)
        : const Color(0xFFE53935);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
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
                      color: const Color(0xFFDDF8E7), // Completed status green background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2DAA63), // Completed status green text
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
                          'Metode',
                          style: TextStyle(
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
                        const Text(
                          'Poin',
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

