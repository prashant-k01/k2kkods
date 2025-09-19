import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/Iron_smith/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class MachineDeleteHandler {
  static void confirmDelete(
    BuildContext context, {
    required String? machineId,
    required String? machineName,
  }) {
    if (machineId == null || machineName == null) return;

    showDialog<void>(
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

          // Title Row
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
                  'Delete Machine',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),

          // Confirmation Message
          content: Text(
            'Are you sure you want to delete machine "$machineName"?\n'
            'This action cannot be undone.',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),

          // Actions
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
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
                Navigator.of(dialogContext).pop(); // Close dialog first

                final provider = context.read<IsMachinesProvider>();
                final success = await provider.deleteMachine(machineId);

                if (!context.mounted) return;

                if (success) {
                  context.showSuccessSnackbar('Machine deleted successfully!');
                } else {
                  context.showErrorSnackbar('Failed to delete machine.');
                }
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
