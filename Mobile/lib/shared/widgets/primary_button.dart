import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scaleByDouble(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0, 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isDisabled && !widget.isLoading
              ? LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[300]!],
                )
              : const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : (widget.icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: isDisabled && !widget.isLoading ? Colors.grey[500] : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled && !widget.isLoading ? Colors.grey[500] : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled && !widget.isLoading ? Colors.grey[500] : Colors.white,
                      letterSpacing: 0.5,
                    ),
                  )),
      ),
    );
  }
}


