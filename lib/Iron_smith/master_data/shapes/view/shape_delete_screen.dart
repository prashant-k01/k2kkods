import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/Iron_smith/master_data/shapes/provider/shape_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class ShapeDeleteHandler {
  static void confirmDelete(
    BuildContext context, {
    required String? shapeId,
    required String? shapeName,
  }) {
    if (shapeId == null || shapeName == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.all(20.w),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 12.h,
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),

          // Title Row with Icon + Text
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFF59E0B),
                size: 28.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Delete Shape',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),

          // Confirmation text
          content: Text(
            'Are you sure you want to delete shape "$shapeName"?\nThis action cannot be undone.',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),

          // Actions
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.ironSmithPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final provider = Provider.of<ShapesProvider>(
                  context,
                  listen: false,
                );

                await provider.deleteShape(context, shapeId);
                // ✅ Provider already shows success/error snackbar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
