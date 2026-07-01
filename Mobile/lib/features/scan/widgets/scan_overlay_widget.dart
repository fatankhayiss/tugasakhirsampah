import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ScanOverlayWidget extends StatelessWidget {
  const ScanOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 24,
          left: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.04)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen,
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI ACTIVE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'LAT: 6.2088° S\nLON: 106.8456° E',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white60,
                  fontSize: 10,
                  height: 1.5,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          bottom: 24,
          right: 24,
          child: Text(
            'SCAN_READY.EXE',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}


