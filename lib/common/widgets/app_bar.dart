import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBars extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? action;

  const AppBars({super.key, required this.title, this.leading, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24.r), // Rounded bottom corners
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 20.h, // Increase bottom space
      ),
      child: Row(
        children: [
          leading ?? SizedBox(width: 40.w, height: 40.w),
          Expanded(child: title),
          if (action != null && action!.isNotEmpty)
            Row(children: action!)
          else
            SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // Adjusted height to accommodate added padding
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight+60.h);
}