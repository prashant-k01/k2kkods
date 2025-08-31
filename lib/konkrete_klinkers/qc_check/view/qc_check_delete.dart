import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/qc_check/provider/qc_check_provider.dart';
import 'package:provider/provider.dart';

class QcCheckDeleteHandler {
  static void deleteQcCheck(
    BuildContext context,
    String? qcCheckId,
    String? remarks,
  ) {
    if (qcCheckId == null || remarks == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFF59E0B),
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Confirm Delete',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete QC check with remarks "$remarks"?\n\nThis action cannot be undone.',
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF3B82F6)),
            ),
          ),
          Consumer<QcCheckProvider>(
            builder: (consumerContext, provider, child) {
              return ElevatedButton(
                onPressed: provider.isDeleteQcCheckLoading
                    ? null
                    : () async {
                        try {
                          // Call delete method
                          await provider.deleteQcCheck(qcCheckId);

                          // Close the dialog first
                          Navigator.pop(dialogContext);

                          // Use the original context (not dialogContext) for snackbar
                          // Check if the deletion was successful
                          if (provider.error == null) {
                            if (context.mounted) {
                              context.showSuccessSnackbar(
                                'QC check deleted successfully!',
                              );
                            }
                          } else {
                            if (context.mounted) {
                              context.showErrorSnackbar(provider.error!);
                            }
                          }
                        } catch (e) {
                          // Close the dialog first
                          Navigator.pop(dialogContext);

                          // Show error message using original context
                          if (context.mounted) {
                            context.showErrorSnackbar(
                              'Failed to delete QC check: $e',
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                child: provider.isDeleteQcCheckLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: GradientLoader(),
                      )
                    : Text(
                        'Delete',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
