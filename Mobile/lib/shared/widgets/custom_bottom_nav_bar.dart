import 'package:flutter/material.dart';
import 'custom_nav_item.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BottomAppBar(
          shape: const AutomaticNotchedShape(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            CircleBorder(),
          ),
          notchMargin: 8,
          color: Colors.white,
          elevation: 0,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              CustomNavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Orders',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 48), // Space for FAB
              CustomNavItem(
                icon: Icons.notifications_rounded,
                label: 'Notifs',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              CustomNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



