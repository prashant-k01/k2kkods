import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/Iron_smith/job_order/model/job_order_detail.dart';
import 'package:k2k/Iron_smith/job_order/provider/job_order_provider_is.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/loader.dart';
import 'package:k2k/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IronJobOrderViewScreen extends StatefulWidget {
  final String jobOrderId;

  const IronJobOrderViewScreen({super.key, required this.jobOrderId});

  @override
  State<IronJobOrderViewScreen> createState() => _IronJobOrderViewScreenState();
}

class _IronJobOrderViewScreenState extends State<IronJobOrderViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<JobOrderProviderIS>();
      provider.getJobOrderById(widget.jobOrderId);
    });
  }

  String _formatDateOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateFormat("d/M/yyyy, h:mm:ss a").parse(dateTimeString);
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
      case 'Client Details':
        return 'Customer and project information';
      case 'Work Order Details':
        return 'Job order and work order specifications';
      case 'Product Information':
        return 'Product details and quantities';
      default:
        return 'Additional information';
    }
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

  Widget _buildProgressIndicator(Product product) {
    final achieved = product.achievedQuantity ?? 0;
    final planned = product.plannedQuantity ?? 0;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.ironJobOrder);
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
                context.go(RouteNames.ironJobOrder);
              },
            ),
          ),
          body: SafeArea(
            child: Consumer<JobOrderProviderIS>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: GridLoader());
                }
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: const Color(0xFFF43F5E),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error Loading Job Order',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (provider.selectedJobOrder == null) {
                  return Center(
                    child: Text(
                      'No Job Order Found',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  );
                }

                final jobOrder = provider.selectedJobOrder!;

                return SingleChildScrollView(
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
                          icon: Icons.person,
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
                            label: 'Address',
                            value: jobOrder.project?.address ?? 'N/A',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailCard(
                        headerGradient: AppTheme.cardGradientGreen,
                        title: 'Work Order Details',
                        icon: IconContainer(
                          icon: Icons.work,
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
                            label: 'Work Order Number',
                            value: jobOrder.workOrderNumber ?? 'N/A',
                          ),
                          DetailItem(
                            label: 'Job Order ID',
                            value: jobOrder.jobOrderNumber ?? 'N/A',
                          ),
                          DetailItem(
                            label: 'Dates',
                            value:
                                '${_formatDateOnly(jobOrder.dateRange?.from)} - ${_formatDateOnly(jobOrder.dateRange?.to)}',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailCard(
                        headerGradient: AppTheme.cardGradientRed,
                        title: 'Product Information',
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
                          children:
                              jobOrder.products?.map((product) {
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
                                        '${jobOrder.project?.name ?? 'N/A'} : ${product.shapeCode ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.pink.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      _buildProductDetail(
                                        'Shape',
                                        product.shapeCode ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Member',
                                        product.member ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Desc',
                                        product.description ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Bar Mark',
                                        product.barMark ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Dia',
                                        product.dia?.toString() ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'CL',
                                        product.poQuantity?.toString() ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Qty',
                                        product.plannedQuantity?.toString() ??
                                            'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Wt / Kgs',
                                        product.weight ?? 'N/A',
                                      ),
                                      _buildProductDetail(
                                        'Achieved Quantity',
                                        product.achievedQuantity?.toString() ??
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
                                        product.rejectedQuantity?.toString() ??
                                            '0',
                                        valueColor:
                                            product.rejectedQuantity != null
                                            ? (product.rejectedQuantity! > 0
                                                  ? Colors.red
                                                  : Colors.grey)
                                            : Colors.grey,
                                      ),
                                      _buildProductDetail(
                                        'Scheduled Date',
                                        _formatDateOnly(product.scheduleDate),
                                      ),
                                      if (product.plannedQuantity != null &&
                                          product.plannedQuantity! > 0) ...[
                                        SizedBox(height: 8.h),
                                        _buildProgressIndicator(product),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList() ??
                              [],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
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
    this.gradientColors = const [Colors.blue, Colors.cyan],
    this.size = 40.0,
    this.borderRadius = 8.0,
    this.iconColor = Colors.blue,
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
