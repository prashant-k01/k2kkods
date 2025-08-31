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
