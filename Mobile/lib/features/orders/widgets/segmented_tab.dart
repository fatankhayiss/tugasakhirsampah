import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/scale_tap.dart';

class SegmentedTabWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabWidget({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ScaleTap(
              onTap: () {
                if (selectedIndex != 0) {
                  HapticFeedback.lightImpact();
                  onChanged(0);
                }
              },
              scaleDown: 0.96,
              duration: const Duration(milliseconds: 160),
              executeOnTap: true,
              child: GestureDetector(
                onTap: () {
                  if (selectedIndex != 0) {
                    HapticFeedback.lightImpact();
                    onChanged(0);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  height: (MediaQuery.of(context).size.height * 0.055).clamp(42.0, 54.0),
                  decoration: BoxDecoration(
                    color: selectedIndex == 0 ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: selectedIndex == 0
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      'Ongoing',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: selectedIndex == 0 ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13.5,
                        color: selectedIndex == 0 ? Colors.white : AppColors.textSoft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ScaleTap(
            onTap: () {
              if (selectedIndex != 1) {
                HapticFeedback.lightImpact();
                onChanged(1);
              }
            },
            scaleDown: 0.96,
            duration: const Duration(milliseconds: 160),
            executeOnTap: true,
            child: GestureDetector(
              onTap: () {
                if (selectedIndex != 1) {
                  HapticFeedback.lightImpact();
                  onChanged(1);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                height: (MediaQuery.of(context).size.height * 0.055).clamp(42.0, 54.0),
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: selectedIndex == 1 ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13.5,
                      color: selectedIndex == 1 ? Colors.white : AppColors.textSoft,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

