import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';

import 'package:k2k/konkrete_klinkers/job_order/provider/job_order_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class JobOrderViewScreen extends StatefulWidget {
  final String jobOrderId;

  const JobOrderViewScreen({super.key, required this.jobOrderId});

  @override
  State<JobOrderViewScreen> createState() => _JobOrderViewScreenState();
}

class _JobOrderViewScreenState extends State<JobOrderViewScreen> {
  @override
  void initState() {
    super.initState();
    // fetch job order details when screen loads
    Future.microtask(() {
      context.read<JobOrderProvider>().getJobOrderById(widget.jobOrderId);
    });
  }

  String _formatDateTime(dynamic dateTimeInput) {
    if (dateTimeInput == null) return 'N/A';
    try {
      DateTime dateTime;
      if (dateTimeInput is String) {
        dateTime = DateTime.parse(dateTimeInput);
      } else if (dateTimeInput is DateTime) {
        dateTime = dateTimeInput;
      } else {
        return 'N/A';
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeInput.toString();
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
      child: Consumer<JobOrderProvider>(
        builder: (context, provider, child) {
          final jobOrder = provider.jobOrder;
          final error = provider.error;

          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (error != null) {
            return Scaffold(
              appBar: AppBars(
                title: TitleText(title: 'Job Order Details'),
                leading: CustomBackButton(
                  onPressed: () {
                    context.go(RouteNames.jobOrder);
                  },
                ),
              ),
              body: Center(child: Text(error)),
            );
          }

          if (jobOrder == null) {
            return Scaffold(
              appBar: AppBars(
                title: TitleText(title: 'Job Order Details'),
                leading: CustomBackButton(
                  onPressed: () {
                    context.go(RouteNames.jobOrder);
                  },
                ),
              ),
              body: const Center(child: Text("No Job Order found")),
            );
          }

          return Container(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard(
                        headerGradient: AppTheme.cardGradientBlue,
                        title: 'Client Details',
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
                            label: 'Client Name',
                            value: jobOrder.client?.name ?? 'N/A',
                          ),
                          DetailItem(
                            label: 'Project Name',
                            value: jobOrder.project?.name ?? 'N/A',
                          ),
                          DetailItem(
                            label: 'Client Address',
                            value: jobOrder.client?.address ?? 'N/A',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailCard(
                        headerGradient: AppTheme.cardGradientGreen,
                        title:
                            'Work Order Details\nOrder Status & Information ',
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
                            label: 'WorkOrder Number ',
                            value:
                                jobOrder.workOrderDetails?.workOrderNumber ??
                                'N/A',
                          ),
                          DetailItem(
                            label: 'Created',
                            value: _formatDateTime(
                              jobOrder.workOrderDetails?.createdAt,
                            ),
                          ),
                          DetailItem(
                            label: 'Status',
                            value: jobOrder.workOrderDetails?.status ?? 'N/A',
                          ),
                          DetailItem(
                            label: 'Batch Date',
                            value: jobOrder.batchDate != null
                                ? jobOrder.batchDate!.toIso8601String().split(
                                    'T',
                                  )[0]
                                : 'N/A',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      _buildDetailCard(
                        headerGradient: AppTheme.cardGradientRed,
                        title:
                            'Products Information\nProduction and manufacturing details',
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
                          children: jobOrder.products != null
                              ? jobOrder.products!.map((product) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.description ??
                                              'No Description',
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
                                          'Plant Name',
                                          product.plantName ?? 'N/A',
                                        ),
                                        _buildProductDetail(
                                          'Planned Quantity',
                                          product.plannedQuantity.toString(),
                                        ),
                                        _buildProductDetail(
                                          'Achieved Quantity',
                                          product.achievedQuantity
                                                  ?.toString() ??
                                              '0',
                                          valueColor:
                                              product.achievedQuantity != null
                                              ? (product.achievedQuantity! > 0
                                                    ? Colors.green
                                                    : Colors.grey)
                                              : Colors.grey,
                                        ),
                                        _buildProductDetail(
                                          'Rejected Quantity',
                                          product.rejectedQuantity
                                                  ?.toString() ??
                                              '0',
                                          valueColor:
                                              product.rejectedQuantity != null
                                              ? (product.rejectedQuantity! > 0
                                                    ? Colors.red
                                                    : Colors.grey)
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : [const Text("No products available")],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
    super.key,
    required this.icon,
    this.gradientColors = const [Colors.orange, Colors.pink],
    this.size = 40.0, // Default size
    this.borderRadius = 8.0,
    this.iconColor = Colors.red,
  });

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
