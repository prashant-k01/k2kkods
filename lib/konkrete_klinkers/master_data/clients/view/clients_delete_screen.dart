import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/provider/clients_provider.dart';
import 'package:provider/provider.dart';

class ClientDeleteHandler {
  static void deleteClient(
    BuildContext context,
    String? clientId,
    String? name,
  ) {
    if (clientId == null || name == null) return;

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
          'Are you sure you want to delete "$name"?',
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
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final scaffoldContext = context;

              final provider = Provider.of<ClientsProvider>(
                scaffoldContext,
                listen: false,
              );
              final success = await provider.deleteClients(clientId);

              context.showSuccessSnackbar(
                success
                    ? 'Client deleted successfully!'
                    : 'Failed to delete Client.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
