import 'package:flutter/material.dart';
import 'scan_overlay_widget.dart';

class ScanFrameWidget extends StatefulWidget {
  final Widget child;
  final bool isBlue;

  const ScanFrameWidget({super.key, required this.child, this.isBlue = false});

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
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
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
    // Sesuai tema warna instruksi:
    // Primary (Hijau Utama): #22C55E
    // Border / Outline: #86EFAC
    const primaryGreen = Color(0xFF22C55E);
    const borderGreen = Color(0xFF86EFAC);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderGreen,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22), // 24 - 2 px border
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview / child
            widget.child,

            // Reusable overlay (empty / no text)
            ScanOverlayWidget(isBlue: widget.isBlue),

            // Animated Scanner Line (Garis scan hijau dengan animasi bergerak & glow)
            LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final scanBarHeight = 80.0;
                return AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    final topPosition = _lineAnimation.value * (height - scanBarHeight);
                    return Positioned(
                      top: topPosition.clamp(0.0, height > scanBarHeight ? height - scanBarHeight : 0.0),
                      left: 0,
                      right: 0,
                      child: Container(
                        height: scanBarHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              primaryGreen.withValues(alpha: 0.0),
                              primaryGreen.withValues(alpha: 0.12),
                              primaryGreen.withValues(alpha: 0.38),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 3.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGreen.withValues(alpha: 0.85),
                                  blurRadius: 14,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
