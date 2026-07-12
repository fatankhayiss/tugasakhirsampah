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

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(24),
        elevation: isDisabled ? 0 : (_isPressed ? 2 : 6),
        color: Colors.transparent,
        shadowColor: AppColors.primaryBlue.withValues(alpha: 0.25),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isDisabled && !widget.isLoading
                ? LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                  )
                : const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                  ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
              onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
              onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
              borderRadius: BorderRadius.circular(24),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: widget.isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          key: const ValueKey('content'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: isDisabled && !widget.isLoading ? Colors.grey[600] : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDisabled && !widget.isLoading ? Colors.grey[600] : Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


