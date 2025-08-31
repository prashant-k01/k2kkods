import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPopupItem extends PopupMenuItem<String> {
  CustomPopupItem({
    Key? key,
    required String value,
    required IconData icon,
    required String label,
    Color? iconColor,
    String? subtitle,
    bool dangerous = false, // red styling for destructive actions
    VoidCallback? onTap,
  }) : super(
         key: key,
         value: value,
         onTap: onTap,
         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
         child: _MenuItemContent(
           icon: icon,
           label: label,
           subtitle: subtitle,
           iconColor: iconColor,
           dangerous: dangerous,
         ),
       );
}

class _MenuItemContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final bool dangerous;

  const _MenuItemContent({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.dangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedIconColor = dangerous
        ? Colors.red
        : (iconColor ?? scheme.primary);
    final textColor = dangerous ? Colors.red.shade700 : const Color(0xFF334155);

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: resolvedIconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.all(6.w),
          child: Icon(icon, size: 18.sp, color: resolvedIconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
