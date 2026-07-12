import 'package:flutter/material.dart';

/// Centralized premium slide-from-bottom + fade-in PageRoute builder with M3 SharedAxis outgoing motion.
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration? customDuration;

  CustomPageRoute({
    required this.page,
    super.settings,
    this.customDuration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: customDuration ?? const Duration(milliseconds: 300),
          reverseTransitionDuration: customDuration ?? const Duration(milliseconds: 260),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedIn = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final curvedOut = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOut,
            );

            // Incoming animation: Fade + Slide Up
            final slideIn = Tween<Offset>(
              begin: const Offset(0, 0.05), // Subtle 5% slide from bottom
              end: Offset.zero,
            ).animate(curvedIn);

            Widget incoming = FadeTransition(
              opacity: curvedIn,
              child: SlideTransition(position: slideIn, child: child),
            );

            // Outgoing animation: when another page is pushed on top of this page
            return AnimatedBuilder(
              animation: secondaryAnimation,
              builder: (context, _) {
                final scale = 1.0 - (0.04 * curvedOut.value);
                final opacity = (1.0 - (0.25 * curvedOut.value)).clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: incoming,
                  ),
                );
              },
            );
          },
        );
}

/// Premium transitions helper for eco fintech navigation.
class AppPageTransitions {
  AppPageTransitions._();

  static const Duration duration = Duration(milliseconds: 350);

  /// Consistent global page slide from bottom + fade
  static Route<T> fadeSlide<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return CustomPageRoute<T>(
      page: page,
      settings: settings,
      customDuration: duration,
    );
  }

  /// Fade scale for transparent overlay panels / cards
  static Route<T> modalSheet<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      opaque: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
