import 'package:flutter/material.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = (constraints.maxWidth - 8) / 2;

        return Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: selectedIndex == 0 ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4FD17B),
                        Color(0xFF34B96B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34B96B).withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    _TabLabel(
                      label: 'Ongoing',
                      isActive: selectedIndex == 0,
                      onTap: () => onChanged(0),
                    ),
                    _TabLabel(
                      label: 'History',
                      isActive: selectedIndex == 1,
                      onTap: () => onChanged(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabLabel({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF7B8190),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: -0.2,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

