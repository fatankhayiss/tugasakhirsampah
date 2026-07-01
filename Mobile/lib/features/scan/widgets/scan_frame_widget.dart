import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'scan_overlay_widget.dart';

class ScanFrameWidget extends StatefulWidget {
  final Widget child;

  const ScanFrameWidget({super.key, required this.child});

  @override
  State<ScanFrameWidget> createState() => _ScanFrameWidgetState();
}

class _ScanFrameWidgetState extends State<ScanFrameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          children: [
            // Camera or Empty State child
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: widget.child,
              ),
            ),
            
            // Frame borders and corner overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.04),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.04),
                      blurRadius: 18,
                      spreadRadius: -5,
                    ),
                  ],
                ),
              ),
            ),
            
            // Reusable overlay texts
            const Positioned.fill(
              child: ScanOverlayWidget(),
            ),

            // Animated Scanner Line
            AnimatedBuilder(
              animation: _lineAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _lineAnimation.value * (MediaQuery.of(context).size.width * 4 / 3 - 80), // Approx height calc
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120, // Gradual fade
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.neonGreen.withValues(alpha: 0.04),
                          AppColors.neonGreen.withValues(alpha: 0.04),
                          AppColors.neonGreen.withValues(alpha: 0.04),
                        ],
                        stops: const [0.0, 0.9, 1.0],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 2,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.neonGreen,
                          boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen,
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}




