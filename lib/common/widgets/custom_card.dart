import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget leading;
  final Color? iconColor;
  final List<PopupMenuEntry<String>>? menuItems;
  final VoidCallback? onTap;
  final List<Widget> bodyItems;
  final Gradient? headerGradient;
  final double borderRadius;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double elevation;
  final ValueChanged<String>? onMenuSelected;

  final EdgeInsetsGeometry margin;

  const CustomCard({
    super.key,
    required this.title,
    required this.leading,
    required this.bodyItems,
    this.iconColor,
    this.subtitle,
    this.menuItems,
    this.onTap,
    this.headerGradient,
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
    this.borderWidth = 1,
    this.elevation = 0,
    this.onMenuSelected,
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: double.infinity,
      child: Card(
        elevation: elevation,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          side: BorderSide(color: borderColor, width: borderWidth.w),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient:
                        headerGradient ??
                        LinearGradient(
                          colors: [
                            const Color(0xFFEBEDFC), // soft lavender
                            const Color(0xFFE6F0FF), // light blue
                            backgroundColor ?? Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(borderRadius.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      leading,
                      SizedBox(width: 8.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (menuItems != null)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 18.sp,
                            color: Colors.grey[600],
                          ),
                          itemBuilder: (context) => menuItems!,
                          offset: Offset(0, 32.h),
                          onSelected: onMenuSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          color: backgroundColor,
                          elevation: 2,
                        ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bodyItems,
                  ),
                ),
              ],
            ),
          ),
        ),
  ),
);
}
}