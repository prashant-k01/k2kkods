import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/utils/theme.dart';
import 'package:intl/intl.dart';

class JobOrderViewScreen extends StatelessWidget {
  final JobOrderModel jobOrder;

  const JobOrderViewScreen({super.key, required this.jobOrder});

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatDateOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildDetailCard({
    required Gradient headerGradient,
    required String title,
    required IconContainer icon,
    required Color iconColor,
    required List<DetailItem> details,
    Widget? child,
  }) {
    return CustomCard(
      margin: EdgeInsets.zero,
      title: title,
      titleColor: iconColor,
      subtitle: _getSubtitleForCard(title),
      subtitleColor: AppTheme.mediumGray,
      leading: icon,
      backgroundColor: AppColors.cardBackground,
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1,
      borderRadius: 12,
      elevation: 0,
      headerGradient: headerGradient,
      bodyItems: child != null
          ? [child]
          : [
              SizedBox(height: 8.h),
              ...details.map(
                (detail) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${detail.label}:',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          detail.value,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
    );
  }

  String _getSubtitleForCard(String title) {
    switch (title) {
      case 'Job Order Information':
        return 'Basic job order details and status';
      case 'Schedule Information':
        return 'Project timeline and dates';
      case 'Client Information':
        return 'Customer details and contact info';
      case 'Work Order Details':
        return 'Work order specifications';
      case 'Products Information':
        return 'Product details and quantities';
      default:
        return 'Additional information';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.jobOrder);
        }
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Job Order Details'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.jobOrder);
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                    headerGradient: AppTheme.cardGradientBlue,
                    title: 'Job Order Information',
                    icon: IconContainer(
                      icon: Icons.assignment,
                      gradientColors: [
                        Colors.blue.shade100,
                        Colors.cyan.shade50,
                      ],
                      size: 40.w,
                      borderRadius: 8.r,
                      iconColor: Colors.blue.shade700,
                    ),
                    iconColor: Colors.blue,
                    details: [
                      DetailItem(
                        label: 'Job Order ID',
                        value: jobOrder.jobOrderId,
                      ),
                      DetailItem(
                        label: 'Batch Number',
                        value: jobOrder.batchNumber.toString(),
                      ),
                      DetailItem(
                        label: 'Sales Order',
                        value: jobOrder.salesOrderNumber,
                      ),
                      DetailItem(label: 'Status', value: jobOrder.status),
                      DetailItem(
                        label: 'Created By',
                        value: jobOrder.createdBy ?? 'N/A',
                      ),
                      DetailItem(
                        label: 'Created At',
                        value: _formatDateTime(jobOrder.createdAt),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailCard(
                    headerGradient: AppTheme.cardGradientGreen,
                    title: 'Schedule Information',
                    icon: IconContainer(
                      icon: Icons.date_range,
                      gradientColors: [
                        Colors.green.shade100,
                        Colors.teal.shade50,
                      ],
                      size: 40.w,
                      borderRadius: 8.r,
                      iconColor: Colors.green.shade700,
                    ),
                    iconColor: Colors.green,
                    details: [
                      DetailItem(
                        label: 'Start Date',
                        value: _formatDateOnly(jobOrder.date.from),
                      ),
                      DetailItem(
                        label: 'End Date',
                        value: _formatDateOnly(jobOrder.date.to),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (jobOrder.client != null) ...[
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientRed,
                      title: 'Client Information',
                      icon: IconContainer(
                        icon: Icons.person,
                        gradientColors: [
                          Colors.orange.shade100,
                          Colors.yellow.shade50,
                        ],
                        size: 40.w,
                        borderRadius: 8.r,
                        iconColor: Colors.orange.shade700,
                      ),
                      iconColor: Colors.orange,
                      details: [
                        DetailItem(
                          label: 'Client Name',
                          value: jobOrder.client?.name ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Address',
                          value: jobOrder.client?.address ?? 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                  if (jobOrder.workOrderDetails != null) ...[
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientList,
                      title: 'Work Order Details',
                      icon: IconContainer(
                        icon: Icons.work,
                        gradientColors: [
                          Colors.purple.shade100,
                          Colors.indigo.shade50,
                        ],
                        size: 40.w,
                        borderRadius: 8.r,
                        iconColor: Colors.purple.shade700,
                      ),
                      iconColor: Colors.purple,
                      details: [
                        DetailItem(
                          label: 'Work Order Number',
                          value:
                              jobOrder.workOrderDetails?.workOrderNumber ??
                              'N/A',
                        ),
                        DetailItem(
                          label: 'Status',
                          value: jobOrder.workOrderDetails?.status ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Created By',
                          value: jobOrder.workOrderDetails?.createdBy ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Created At',
                          value: _formatDateTime(
                            jobOrder.workOrderDetails?.createdAt,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                  _buildDetailCard(
                    headerGradient: AppTheme.cardGradientRed,
                    title: 'Products Information',
                    icon: IconContainer(
                      icon: Icons.inventory,
                      gradientColors: [
                        Colors.pink.shade100,
                        Colors.red.shade50,
                      ],
                      size: 40.w,
                      borderRadius: 8.r,
                      iconColor: Colors.pink.shade700,
                    ),
                    iconColor: Colors.pink,
                    details: [],
                    child: Column(
                      children: jobOrder.jobOrders.map((product) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1.w,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.description ?? 'No Description',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pink.shade700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildProductDetail(
                                'Material Code',
                                product.materialCode ?? 'N/A',
                              ),
                              _buildProductDetail(
                                'Machine Name',
                                product.machineName,
                              ),
                              _buildProductDetail(
                                'Plant Name',
                                product.plantName ?? 'N/A',
                              ),
                              _buildProductDetail(
                                'Planned Quantity',
                                product.plannedQuantity.toString(),
                              ),
                              _buildProductDetail(
                                'Achieved Quantity',
                                product.achievedQuantity?.toString() ?? '0',
                                valueColor: product.achievedQuantity != null
                                    ? (product.achievedQuantity! > 0
                                          ? Colors.green
                                          : Colors.grey)
                                    : Colors.grey,
                              ),
                              _buildProductDetail(
                                'Rejected Quantity',
                                product.rejectedQuantity?.toString() ?? '0',
                                valueColor: product.rejectedQuantity != null
                                    ? (product.rejectedQuantity! > 0
                                          ? Colors.red
                                          : Colors.grey)
                                    : Colors.grey,
                              ),
                              _buildProductDetail(
                                'Scheduled Date',
                                _formatDateOnly(product.scheduledDate),
                              ),
                              if (product.plannedQuantity > 0) ...[
                                SizedBox(height: 8.h),
                                _buildProgressIndicator(product),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(JobOrderItem product) {
    final achieved = product.achievedQuantity ?? 0;
    final planned = product.plannedQuantity;
    final progress = planned > 0 ? achieved / planned : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGray,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : Colors.blue,
          ),
          minHeight: 6.h,
        ),
      ],
    );
  }

  Widget _buildProductDetail(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: valueColor ?? AppTheme.mediumGray,
                fontWeight: valueColor != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailItem {
  final String label;
  final String value;

  DetailItem({required this.label, required this.value});
}

class IconContainer extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double size;
  final double borderRadius;
  final Color iconColor;

  const IconContainer({
    Key? key,
    required this.icon,
    this.gradientColors = const [Colors.orange, Colors.pink],
    this.size = 40.0, // Default size
    this.borderRadius = 8.0,
    this.iconColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.h,
      width: size.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: (size * 0.5).sp),
    );
  }
}
