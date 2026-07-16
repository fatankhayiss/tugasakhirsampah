import 'package:flutter/material.dart';
import 'scale_tap.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool enableHaptic;

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
    this.isLoading = false,
    this.isDisabled = false,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF4AC08D);
    final txtColor = textColor ?? Colors.white;
    final double radius = borderRadius ?? 16;
    final bool actuallyDisabled = onPressed == null || isLoading || isDisabled;

    final Color effectiveBg = actuallyDisabled
        ? (isOutlined ? Colors.transparent : Colors.grey.withValues(alpha: 0.25))
        : (isOutlined ? Colors.transparent : bgColor);
    final Color effectiveText = actuallyDisabled
        ? Colors.grey.withValues(alpha: 0.7)
        : (isOutlined ? bgColor : txtColor);

    Widget content;
    if (isLoading) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Memuat...',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: effectiveText,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: effectiveText, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: effectiveText,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: effectiveText,
        ),
      );
    }

    Widget buttonContainer = Container(
      height: height ?? 52,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
        border: isOutlined
            ? Border.all(
                color: actuallyDisabled ? Colors.grey.withValues(alpha: 0.3) : bgColor,
                width: 1.5,
              )
            : null,
        boxShadow: (!actuallyDisabled && !isOutlined)
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: actuallyDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Center(child: content),
        ),
      ),
    );

    if (actuallyDisabled) {
      return buttonContainer;
    }

    return ScaleTap(
      onTap: onPressed,
      enableHaptic: enableHaptic,
      executeOnTap: false,
      child: buttonContainer,
    );
  }
}
