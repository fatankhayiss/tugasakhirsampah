import 'package:flutter/material.dart';

/// Centralized Material 3 Shimmer Skeleton Loading component.
/// Replaces blank loading pages or spinning indicators with smooth shimmer placeholders.
class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1.0, 0.0),
              end: Alignment(_animation.value + 1.0, 0.0),
              colors: [
                Colors.grey.withValues(alpha: 0.12),
                Colors.grey.withValues(alpha: 0.24),
                Colors.grey.withValues(alpha: 0.12),
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}

/// Helper skeleton layouts for Dashboard, Orders, Education, Notifications.
class SkeletonLayouts {
  SkeletonLayouts._();

  static Widget cardSkeleton({double height = 120, double borderRadius = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ShimmerSkeleton(
        width: double.infinity,
        height: height,
        borderRadius: borderRadius,
      ),
    );
  }

  static Widget listSkeleton({int count = 5, double itemHeight = 90}) {
    return ListView.builder(
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) => cardSkeleton(height: itemHeight),
    );
  }
}
