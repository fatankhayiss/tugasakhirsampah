// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field`nimport 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingIndicator({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? const Color(0xFF4AC08D),
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
