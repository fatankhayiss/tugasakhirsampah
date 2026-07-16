import 'package:flutter/material.dart';
import 'scale_tap.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final Border? border;
  final bool enableHaptic;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.border,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 16;
    final decoration = BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
    );

    if (onTap != null) {
      return ScaleTap(
        onTap: onTap,
        enableHaptic: enableHaptic,
        executeOnTap: false,
        child: Container(
          margin: margin,
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}


