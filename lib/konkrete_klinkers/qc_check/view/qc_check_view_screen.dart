import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/konkrete_klinkers/qc_check/provider/qc_check_provider.dart';
import 'package:provider/provider.dart';

class QcCheckViewScreen extends StatefulWidget {
  final String qcCheckId;

  const QcCheckViewScreen({super.key, required this.qcCheckId});

  @override
  State<QcCheckViewScreen> createState() => _QcCheckViewScreenState();
}

class _QcCheckViewScreenState extends State<QcCheckViewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<QcCheckProvider>().fetchQcCheckById(widget.qcCheckId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QcCheckProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBars(
              title: TitleText(title: "QC Check Details"),

              leading: CustomBackButton(
                onPressed: () => context.go(RouteNames.qcCheck),
              ),
            ),
            body: Center(child: Text(provider.error!)),
          );
        }

        final data = provider.qcCheckData;
        if (data == null) {
          return Scaffold(
            appBar: AppBars(
              title: TitleText(title: "QC Check Details"),

              leading: CustomBackButton(
                onPressed: () => context.go(RouteNames.qcCheck),
              ),
            ),
            body: const Center(child: Text("No QC check data found.")),
          );
        }

        return Scaffold(
          appBar: AppBars(
            title: TitleText(title: "QC Check Details"),

            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.qcCheck),
            ),
          ),
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F7FA), Color(0xFFEFEFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10.r,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxWidth: 500.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 60.sp,
                            color: Colors.purple,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "QC Check Details",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "View QC check information",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildField("Job Order", data.jobOrder?.jobOrderId ?? "-"),
                    _buildField(
                      "Work Order",
                      data.workOrder?.workOrderNumber ?? "-",
                    ),
                    _buildField(
                      "Product",
                      "${data.productId?.materialCode ?? '-'} - ${data.productId?.description ?? '-'}",
                    ),
                    _buildField(
                      "Rejected Quantity",
                      "${data.rejectedQuantity ?? 0}",
                    ),
                    _buildField(
                      "Recycled Quantity",
                      "${data.recycledQuantity ?? 0}",
                    ),
                    _buildField("Remarks", data.remarks ?? "-"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Colors.blue.shade700,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
