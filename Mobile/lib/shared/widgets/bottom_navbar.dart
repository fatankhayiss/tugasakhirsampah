import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/scan/widgets/deposit_method_modal.dart';

/// Premium floating capsule-style Bottom Navigation Bar with elevated center FAB.
class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double safeBottom = bottomPadding > 0 ? bottomPadding + 4 : 16;

    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      height: 74 + safeBottom + 8, // fits the container + bottom safety + top height expansion
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, safeBottom),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. Main Capsule Navbar Container
            Container(
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36), // modern premium capsule style
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8), // depth shadow
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NavbarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  NavbarItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Orders',
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  // Symmetrical placeholder empty spacer to balance the elevated center FAB
                  const SizedBox(width: 68),
                  NavbarItem(
                    icon: Icons.notifications_rounded,
                    label: 'Alerts',
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                    badgeCount: unreadCount,
                  ),
                  NavbarItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
            // 2. Elevated Floating Center Scan Button (protrudes cleanly by 30px)
            Positioned(
              top: -30, // elevated position
              child: FloatingScanButton(
                onTap: () => DepositMethodModal.show(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable individual NavItem with scale micro-animations and unread badges.
class NavbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const NavbarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.softGreen // eco green accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: isSelected ? AppColors.primary : AppColors.textSoft,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: 4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.secondary : AppColors.textSoft,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Symmetrical floating Center elevated FAB scan button with breathing and scale micro-animations.
class FloatingScanButton extends StatefulWidget {
  final VoidCallback onTap;

  const FloatingScanButton({super.key, required this.onTap});

  @override
  State<FloatingScanButton> createState() => _FloatingScanButtonState();
}

class _FloatingScanButtonState extends State<FloatingScanButton>
    with TickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    // Tap interaction scale animation
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    // Continuous floating breathing animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatOffset = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _tapController.forward();
    await _tapController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tapScale, _floatOffset]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatOffset.value),
            child: Transform.scale(
              scale: _tapScale.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const Offset(0, 10), // floating depth shadow
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 32, // enlarged spacious icon size
          ),
        ),
      ),
    );
  }
}
