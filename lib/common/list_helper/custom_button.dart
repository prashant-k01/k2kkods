import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? elevation;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool dense;

  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.elevation,
    this.fontSize,
    this.padding,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? const Color(0xFF3B82F6);
    final disabledColor = const Color(0xFFCBD5E1);
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveIconColor = iconColor ?? Colors.white;

    return GestureDetector(
      onTap: isLoading || onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: Container(
        decoration: BoxDecoration(
          color: isLoading || onPressed == null ? disabledColor : primaryColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: elevation ?? 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: dense ? 16.w : 24.w,
              vertical: dense ? 12.h : 16.h,
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              ),
            if (!isLoading && icon != null) ...[
              Icon(
                icon,
                size: dense ? 18.r : 20.r,
                color: isLoading || onPressed == null
                    ? effectiveIconColor.withOpacity(0.6)
                    : effectiveIconColor,
              ),
              SizedBox(width: dense ? 6.w : 8.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? (dense ? 14.sp : 16.sp),
                fontWeight: FontWeight.w600,
                color: isLoading || onPressed == null
                    ? effectiveTextColor.withOpacity(0.6)
                    : effectiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
