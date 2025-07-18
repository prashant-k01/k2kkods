// utils/screen_util.dart
import 'package:flutter/material.dart';

class ScreenUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  // Device type detection
  static bool get isMobile => screenWidth < 600;
  static bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  static bool get isDesktop => screenWidth >= 1024;

  // Responsive font sizes
  static double get textSizeSmall => isMobile ? 12.0 : isTablet ? 14.0 : 16.0;
  static double get textSizeMedium => isMobile ? 14.0 : isTablet ? 16.0 : 18.0;
  static double get textSizeLarge => isMobile ? 16.0 : isTablet ? 18.0 : 20.0;
  static double get textSizeXLarge => isMobile ? 18.0 : isTablet ? 20.0 : 24.0;

  // Responsive padding
  static EdgeInsets get defaultPadding => EdgeInsets.all(isMobile ? 8.0 : isTablet ? 12.0 : 16.0);
  static EdgeInsets get smallPadding => EdgeInsets.all(isMobile ? 4.0 : isTablet ? 6.0 : 8.0);
  static EdgeInsets get largePadding => EdgeInsets.all(isMobile ? 16.0 : isTablet ? 20.0 : 24.0);

  // Responsive spacing
  static double get spacingSmall => isMobile ? 4.0 : isTablet ? 6.0 : 8.0;
  static double get spacingMedium => isMobile ? 8.0 : isTablet ? 12.0 : 16.0;
  static double get spacingLarge => isMobile ? 16.0 : isTablet ? 20.0 : 24.0;

  // Responsive icon sizes
  static double get iconSizeSmall => isMobile ? 16.0 : isTablet ? 18.0 : 20.0;
  static double get iconSizeMedium => isMobile ? 20.0 : isTablet ? 24.0 : 28.0;
  static double get iconSizeLarge => isMobile ? 24.0 : isTablet ? 28.0 : 32.0;

  // Responsive button heights
  static double get buttonHeightSmall => isMobile ? 32.0 : isTablet ? 36.0 : 40.0;
  static double get buttonHeightMedium => isMobile ? 40.0 : isTablet ? 44.0 : 48.0;
  static double get buttonHeightLarge => isMobile ? 48.0 : isTablet ? 52.0 : 56.0;

  // Responsive border radius
  static double get borderRadiusSmall => isMobile ? 4.0 : isTablet ? 6.0 : 8.0;
  static double get borderRadiusMedium => isMobile ? 8.0 : isTablet ? 10.0 : 12.0;
  static double get borderRadiusLarge => isMobile ? 12.0 : isTablet ? 14.0 : 16.0;

  // Screen percentage calculations
  static double screenWidthPercentage(double percentage) {
    return screenWidth * (percentage / 100);
  }

  static double screenHeightPercentage(double percentage) {
    return screenHeight * (percentage / 100);
  }

  // Responsive container widths
  static double get containerMaxWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return screenWidth * 0.8;
    return screenWidth * 0.6;
  }

  // Data table specific responsive values
  static double get tableHeaderHeight => isMobile ? 48.0 : isTablet ? 52.0 : 56.0;
  static double get tableRowHeight => isMobile ? 56.0 : isTablet ? 60.0 : 64.0;
  static double get tableActionButtonSize => isMobile ? 32.0 : isTablet ? 36.0 : 40.0;

  // Responsive columns for different screen sizes
  static int get maxColumnsToShow {
    if (isMobile) return 3;
    if (isTablet) return 5;
    return 7;
  }

  // Safe area calculations
  static EdgeInsets get safeAreaPadding => EdgeInsets.only(
    top: _mediaQueryData.padding.top,
    bottom: _mediaQueryData.padding.bottom,
    left: _mediaQueryData.padding.left,
    right: _mediaQueryData.padding.right,
  );
}