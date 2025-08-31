import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed; // Optional custom action
  final Color color;
  final double size;

  const CustomBackButton({
    super.key,
    required this.onPressed,
    this.color = const Color(0xFF334155),
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: size.sp, color: color),
      onPressed: () {
        onPressed();
      },
    );
  }
}
