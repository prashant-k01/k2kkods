import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/production/model/production_logs_model.dart';
import 'package:k2k/konkrete_klinkers/production/provider/production_provider.dart';
import 'package:provider/provider.dart';

class ProductionLogScreen extends StatefulWidget {
  final String productId;
  final String jobOrder;

  const ProductionLogScreen({
    super.key,
    required this.productId,
    required this.jobOrder,
  });

  @override
  _ProductionLogScreenState createState() => _ProductionLogScreenState();
}

class _ProductionLogScreenState extends State<ProductionLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductionProvider>(context, listen: false);
      provider.fetchProductionLogs(widget.productId, widget.jobOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionProvider>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.go(RouteNames.production);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBars(
              title: Text(
                'Production Logs',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22.sp,
                  color: Colors.blue[700],
                ),
                onPressed: () => context.goNamed(RouteNames.production),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: provider.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue[700],
                              strokeWidth: 2.w,
                            ),
                          )
                        : _buildProductionLogList(
                            provider.productionLogs ?? [],
                            emptyMessage:
                                'No production logs for this job order',
                            error: provider.error,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductionLogList(
    List<ProductionLog> productionLogs, {
    required String emptyMessage,
    String? error,
  }) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50.sp, color: Colors.red[400]),
            SizedBox(height: 20.h),
            Text(
              'Error: $error',
              style: TextStyle(fontSize: 16.sp, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Provider.of<ProductionProvider>(
                context,
                listen: false,
              ).fetchProductionLogs(widget.productId, widget.jobOrder),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    if (productionLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 50.sp, color: Colors.grey[400]),
            SizedBox(height: 20.h),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: productionLogs.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final log = productionLogs[index];
        return _buildProductionLogCard(log);
      },
    );
  }

  Widget _buildProductionLogCard(ProductionLog log) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.2),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.timestamp ?? 'No timestamp',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Product: ${log.productName ?? 'Unknown'}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                Text(
                  'Quantity: ${log.achievedQuantity ?? 0}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info, size: 24.sp, color: Colors.blue[700]),
            onPressed: () => _showDetailDialog(context, log),
            tooltip: 'Details',
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, ProductionLog log) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 500.h),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[100]!.withOpacity(0.3),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
                spreadRadius: 2.r,
              ),
            ],
            border: Border.all(color: Colors.blue[200]!, width: 1.w),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Production Log Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildDetailRow(
                  'Timestamp',
                  log.timestamp ?? 'N/A',
                  Colors.blue[700]!,
                ),
                SizedBox(height: 12.h),
                _buildDetailRow(
                  'Product',
                  log.productName ?? 'Unknown',
                  Colors.grey[800]!,
                ),
                SizedBox(height: 12.h),
                _buildDetailRow(
                  'Quantity',
                  '${log.achievedQuantity ?? 0}',
                  Colors.grey[800]!,
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue[200]!.withOpacity(0.3),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor, {
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor,
              height: isMultiLine ? 1.4 : null,
            ),
            maxLines: isMultiLine ? 3 : 1,
            overflow: isMultiLine ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }
}
