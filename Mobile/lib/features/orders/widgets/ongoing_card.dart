import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../shared/widgets/scale_tap.dart';
import '../models/ongoing_order_model.dart';
import '../screens/order_detail_screen.dart';
import '../screens/redemption_detail_screen.dart';

class OngoingCard extends StatefulWidget {
  final OngoingOrderModel order;
  final VoidCallback? onRefresh;

  const OngoingCard({super.key, required this.order, this.onRefresh});

  @override
  State<OngoingCard> createState() => _OngoingCardState();
}

class _OngoingCardState extends State<OngoingCard> {
  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: () async {
        if (widget.order.isRedemption) {
          await Navigator.push(
            context,
            CustomPageRoute(
              page: RedemptionDetailScreen(
                redemptionId: widget.order.id,
                ongoingItem: widget.order,
              ),
            ),
          );
          if (widget.onRefresh != null) widget.onRefresh!();
        } else {
          final result = await Navigator.push(
            context,
            CustomPageRoute(
              page: OrderDetailScreen(orderId: widget.order.id),
            ),
          );
          if (result == true && widget.onRefresh != null) {
            widget.onRefresh!();
          }
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
            onTap: () async {
              if (widget.order.isRedemption) {
                await Navigator.push(
                  context,
                  CustomPageRoute(
                    page: RedemptionDetailScreen(
                      redemptionId: widget.order.id,
                      ongoingItem: widget.order,
                    ),
                  ),
                );
                if (widget.onRefresh != null) widget.onRefresh!();
              } else {
                final result = await Navigator.push(
                  context,
                  CustomPageRoute(
                    page: OrderDetailScreen(orderId: widget.order.id),
                  ),
                );
                if (result == true && widget.onRefresh != null) {
                  widget.onRefresh!();
                }
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: White rounded icon container + right-aligned capsule status badge (Amber for Proses)
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
                      color: widget.order.status.badgeBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.order.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.order.status.badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title and Date/Time Info
              Text(
                widget.order.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.date,
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
                          'Keterangan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B8190),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.order.subtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.isRedemption ? 'Poin Ditukar' : 'Estimasi Poin',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B8190),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.order.estimatedPoints != null)
                          PointAmountRow(
                            amount: widget.order.estimatedPoints!,
                            logoSize: 16,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2DAA63),
                              letterSpacing: -0.2,
                            ),
                          )
                        else
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
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

