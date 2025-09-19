import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF3B82F6);
  static const Color error = Color(0xFFF43F5E);
  static const Color textPrimary = Color(0xFF334155);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardHeaderStart = Color(0xFFEDE9FE);
  static const Color cardHeaderEnd = Color(0xFFF5F3FF);
  static const Color shadow = Color(0xFF6B7280);
  static const Color transparent = Color(0x00000000);
  static const Color border = Color(0xFFD1D5DB);
}

// Centralized typography
class AppTextStyles {
  static TextStyle title(double fontSize) => TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle subtitle(double fontSize) => TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle body(double fontSize) => TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static TextStyle secondary(double fontSize) =>
      TextStyle(fontSize: fontSize, color: AppColors.textSecondary);
}

class AppTheme {
  // Primary gradient colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color appBarcolor = Color(0xFFF0F8FF);

  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color darkPurple = Color(0xFF6D28D9);
  static const Color white = Colors.white;
  static final Color? grey = Colors.grey[300];
  static final Color headingform = const Color(0xFF64748B);

  // Additional colors
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color ironSmithPrimary = Color(0xFF70E1F5);
  static const Color ironSmithSecondary = Color(0xFFFFD194);
  static const Color ironSmithBacground = Color(0xFFEAF7FA);

  static const Color mediumGray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF334155);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // static const Color ironSmithPrimary = Color(0xFF70E1F5);
  // static const Color ironSmithSecondary = Color(0xFFFFD194);
  // static const Color ironSmithBacground = Color(0xFFEAF7FA);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6A1B9A), // equivalent to Colors.purple[700]
      Color(0xFFAB47BC), // equivalent to Colors.purple[400]
    ],
  );

  // static const LinearGradient cardGradientList = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  //   colors: [
  //     Color(0xFF4D8FFB), // bright blue (start)
  //     Color(0xFF7D5CFF), // bluish violet (mid transition)
  //     Color(0xFFCA33FF), // vibrant purple-pink (end)
  //   ],
  //   stops: [0.0, 0.5, 1.0], // smooth 3-stage transition
  // );
  static const LinearGradient cardGradientList = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [
      Color(0xFF4A9FE9), // blue
      // Colors.white, // white
      Color(0xFFB19CD9), // purple
    ],
  );

  static const LinearGradient cardGradientYellow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF9C4), // pale yellow (lighter)
      Color(0xFFFFE0B2), // light pastel orange (middle)
      Color(0xFFFFF1E0), // soft peach-cream (lighter)
    ],
    stops: [0.0, 0.6, 1.0],
  );
  static final LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFEEEFFD), // soft lavender
      Color(0xFFEAF3FF), // light blue tint
      Color(0xFFE9F8FF), // pastel aqua blue
      Color(0xFFF7FAFF), // near white
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
  );

  static const LinearGradient cardGradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0F7FA), // very pale aqua (lighter)
      Color(0xFFBBDEFB), // soft sky blue (middle)
      Color(0xFFB2EBF2), // light minty teal (lighter)
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGradientRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCE4EC), // pale blush pink (lighter)
      Color(0xFFFFCDD2), // soft rose red (middle)
      Color(0xFFFFE0E0), // light peachy-pink (lighter)
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0F2F1), // pale aqua-teal (lighter)
      Color(0xFFC8E6C9), // soft leafy green (middle)
      Color(0xFFB2DFDB), // soft mint green (lighter)
    ],
    stops: [0.0, 0.6, 1.0],
  );
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBlue, darkPurple],
  );
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB3E5FC), // Light Blue 100
      Color(0xFFD1C4E9), // Light Purple 100
    ],
  );

  // static const LinearGradient ironSmithGradient = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  //   colors: [ironSmithPrimary, ironSmithSecondary],
  // );
  static const LinearGradient ironSmithBackgroundGradientMild = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7FAFC), // almost white with a hint of blue-gray
      Color(0xFFEAF0F6), // soft pale blue-gray
      Color(0xFFDCE6ED), // light steel blue with a warm tint
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEBF4FF), Color(0xFFF3E8FF)],
  );
  static const LinearGradient ironSmithGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0F7FA), // very pale aqua (lighter)
      Color(0xFFBBDEFB), // soft sky blue (middle)
      Color(0xFFB2EBF2), // light minty teal (lighter)
    ],
    stops: [0.0, 0.6, 1.0],
  );

  // static const LinearGradient ironSmithGradient = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  //   colors: [
  //     Color(0xFFE0F7FA), // very pale aqua (lighter)
  //     Color(0xFFBBDEFB), // soft sky blue (middle)
  //     Color(0xFFB2EBF2), // light minty teal (lighter)
  //   ],
  //   stops: [0.0, 0.6, 1.0],
  // );
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: primaryPurple,
      surface: Colors.white,
      background: lightGray,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: darkGray,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(
        color: darkGray,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: darkGray),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryBlue.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 40,
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkGray,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkGray,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkGray,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: mediumGray,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: mediumGray,
      ),
    ),

    // Drawer Theme
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: mediumGray,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark Theme
}

// Custom gradient button widget
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final LinearGradient? gradient;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.padding,
    this.width,
    this.height,
    this.textStyle,
    this.gradient,
    this.borderRadius,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 50,
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  text,
                  style:
                      textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

// Custom gradient card widget
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final LinearGradient? gradient;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    Key? key,
    required this.child,
    this.padding,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.cardGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );
  }
}
