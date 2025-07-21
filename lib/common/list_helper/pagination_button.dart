
  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: onPressed != null
                ? const Color(0xFF3B82F6)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 24.sp, color: Colors.white),
        ),
      ),
    );
  }
