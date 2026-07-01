import 'package:flutter/material.dart';
import 'scale_tap.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.borderRadius,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF4AC08D);
    final txtColor = textColor ?? Colors.white;

    Widget buttonWidget;

    if (isOutlined) {
      buttonWidget = SizedBox(
        height: height ?? 50,
        child: OutlinedButton(
          onPressed: null, // Let ScaleTap handle clicks for consistent animation
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bgColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            disabledForegroundColor: bgColor, // Keep original colors since button is technically disabled to let ScaleTap animate
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: bgColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: bgColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bgColor,
                  ),
                ),
        ),
      );
    } else {
      buttonWidget = SizedBox(
        height: height ?? 50,
        child: ElevatedButton(
          onPressed: null, // Let ScaleTap handle clicks
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            disabledBackgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            elevation: 0,
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: txtColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: txtColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: txtColor,
                  ),
                ),
        ),
      );
    }

    return ScaleTap(
      onTap: onPressed,
      child: buttonWidget,
    );
  }
}
