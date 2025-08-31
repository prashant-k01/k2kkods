import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleText extends StatelessWidget {
  final String title;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const TitleText({
    super.key,
    required this.title,
    this.textColor = const Color(0xFF334155),
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
