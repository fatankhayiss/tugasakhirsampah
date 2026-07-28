import 'package:flutter/material.dart';

class CameraButtonWidget extends StatefulWidget {
  final VoidCallback onTap;
  final bool isBlue;

  const CameraButtonWidget({super.key, required this.onTap, this.isBlue = false});

  @override
  State<CameraButtonWidget> createState() => _CameraButtonWidgetState();
}

class _CameraButtonWidgetState extends State<CameraButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sesuai tema warna dan komponen tombol scan:
    // Warna hijau: #22C55E dengan efek glow hijau lembut (pulse) & ikon scan/QR putih
    const primaryGreen = Color(0xFF22C55E);
    const secondaryGreen = Color(0xFF16A34A);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scaleByDouble(_isPressed ? 0.92 : 1.0, _isPressed ? 0.92 : 1.0, 1.0, 1.0),
        transformAlignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse glow
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryGreen.withValues(alpha: 0.18),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.28),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Main round scan button
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryGreen,
                    secondaryGreen,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
