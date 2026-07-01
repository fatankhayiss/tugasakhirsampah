import 'package:flutter/material.dart';

/// Centralized premium slide-from-bottom + fade-in PageRoute builder.
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration? customDuration;

  CustomPageRoute({
    required this.page,
    super.settings,
    this.customDuration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: customDuration ?? const Duration(milliseconds: 350),
          reverseTransitionDuration: customDuration ?? const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.04), // Subtle 4% slide from bottom
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(position: slide, child: child),
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
