import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/utils/theme.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget leading;
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
  final List<Tab>? tabs;
  final TabController? tabController;
  final EdgeInsetsGeometry margin;
  final EdgeInsets? headerPadding;
  final EdgeInsets? bodyPadding;
  final Color? shadowColor;
  final double? shadowSpread;
  final VoidCallback? onAddPressed; // Callback for Add button
  final bool showAddButton; // Toggle Add button visibility
  final Gradient? addButtonGradient; // Gradient for Add button
  final String? addButtonText; // Text to display inside the button

  const CustomCard({
    super.key,
    required this.title,
    this.titleStyle,
    required this.leading,
    required this.bodyItems,
    this.titleColor = Colors.black,
    this.subtitleColor = Colors.grey,
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
    this.margin = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.tabs,
    this.tabController,
    this.headerPadding,
    this.bodyPadding,
    this.shadowColor,
    this.shadowSpread,
    this.onAddPressed,
    this.showAddButton = false,
    this.addButtonGradient,
    this.addButtonText,
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
                    gradient: headerGradient ?? AppTheme.cardGradientBlue,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(borderRadius.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor ?? Colors.black.withOpacity(0.03),
                        blurRadius: shadowSpread ?? 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                  padding:
                      headerPadding ??
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    children: [
                      leading,
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          title,
                          style:
                              titleStyle ??
                              TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
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
                            color: AppColors.background,
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
                // Tab Bar Section (if tabs are provided)
                if (tabs != null && tabs!.isNotEmpty && tabController != null)
                  Container(
                    color: backgroundColor,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: TabBar(
                        controller: tabController,
                        isScrollable: true,
                        tabs: tabs!,
                        indicatorColor: titleColor,
                        labelColor: titleColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                    ),
                  ),
                // Body
                Padding(
                  padding: bodyPadding ?? EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...bodyItems,
                      if (showAddButton) ...[
                        SizedBox(height: 12.h), // Space before button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  addButtonGradient ??
                                  AppTheme.ironSmithGradient,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.r),
                                onTap: onAddPressed,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16.sp,
                                        color: AppTheme.lightGray,
                                      ),
                                      if (addButtonText != null) ...[
                                        SizedBox(width: 4.w),
                                        Text(
                                          addButtonText!,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppTheme.lightGray,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
