import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientIconTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const GradientIconTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.gradientColors = const [Color(0xFF3A8DFF), Color(0xFF9B4DFF)],
    this.borderRadius = 24,
    this.iconSize = 18,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius.r),
        onTap: onPressed,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius.r),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: iconSize.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize.sp,
                ),
              ),
            ],
          ),
        ),
  ),
);}
}