import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/packing/provider/packing_provider.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class PackingDetailsView extends StatefulWidget {
  final String workOrderId;
  final String productId;

  const PackingDetailsView({
    super.key,
    required this.workOrderId,
    required this.productId,
  });

  @override
  State<PackingDetailsView> createState() => _PackingDetailsViewState();
}

class _PackingDetailsViewState extends State<PackingDetailsView>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeData() async {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<PackingProvider>();
          provider.loadPackingDetails(widget.workOrderId, widget.productId);
        }
      });
    }
  }

  void _updateTabController(int length) {
    if (_tabController?.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  Widget _buildTabBar(List<Map<String, dynamic>> packingDetails) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: packingDetails.length > 3,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(4.w),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.mediumGray,
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: packingDetails.asMap().entries.map((entry) {
          final index = entry.key;
          return Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pack ${index + 1}', style: TextStyle(fontSize: 11.sp)),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> detail) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradientList,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Packing ID',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          detail['packing_id'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      detail['status'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard(Map<String, dynamic> detail) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      size: 20.sp,
                      color: AppTheme.successColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'QR Code Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow('QR ID', detail['qr_code_id'] ?? 'N/A'),

              // QR Code Image Display
              if (detail['qr_code'] != null &&
                  detail['qr_code'].toString().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            'QR Code',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(8.w),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.network(
                                      detail['qr_code'],
                                      width: 120.w,
                                      height: 120.w,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 120.w,
                                          height: 120.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppTheme.successColor,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 120.w,
                                              height: 120.w,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    size: 32.sp,
                                                    color: AppTheme.errorColor,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    'Failed to load QR',
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color:
                                                          AppTheme.errorColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Work Order Information Card
  Widget _buildWorkOrderCard(Map<String, dynamic> detail) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      size: 20.sp,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Work Order Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow('Work Order', detail['work_order_number'] ?? 'N/A'),
              _buildInfoRow('Job Order', detail['job_order_name'] ?? 'N/A'),
              _buildInfoRow('Client', detail['client_name'] ?? 'N/A'),
              _buildInfoRow('Project', detail['project_name'] ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  // Product Information Card
  Widget _buildProductCard(Map<String, dynamic> detail) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.inventory,
                      size: 20.sp,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow('Product Name', detail['product_name'] ?? 'N/A'),
              _buildInfoRow(
                'Product Quantity',
                detail['product_quantity']?.toString() ?? 'N/A',
              ),
              _buildInfoRow(
                'Bundle Size',
                detail['bundle_size']?.toString() ?? 'N/A',
              ),
              _buildInfoRow('UOM', detail['uom'] ?? 'N/A'),
              _buildInfoRow(
                'Rejected Quantity',
                detail['rejected_quantity']?.toString() ?? '0',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // QR Code Information Card - Updated with QR Image

  // Timeline Information Card
  Widget _buildTimelineCard(Map<String, dynamic> detail) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.access_time,
                      size: 20.sp,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Timeline & Creator',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow('Created By', detail['created_by'] ?? 'N/A'),
              _buildInfoRow(
                'Created At',
                detail['createdAt'] != null
                    ? _formatDateTime(detail['createdAt'])
                    : 'N/A',
              ),
              _buildInfoRow(
                'Updated At',
                detail['updatedAt'] != null
                    ? _formatDateTime(detail['updatedAt'])
                    : 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingDetailContent(Map<String, dynamic> detail) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(detail),
          _buildQrCard(detail),

          _buildWorkOrderCard(detail),
          _buildProductCard(detail),
          _buildTimelineCard(detail),
          SizedBox(height: 80.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildTabBarView(List<Map<String, dynamic>> packingDetails) {
    return TabBarView(
      controller: _tabController,
      children: packingDetails.map((detail) {
        return _buildPackingDetailContent(detail);
      }).toList(),
    );
  }

  Widget _buildCountIndicator(int count) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 18.sp, color: AppTheme.primaryBlue),
          SizedBox(width: 8.w),
          Text(
            '$count Packing Detail${count > 1 ? 's' : ''} Found',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format DateTime
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final localDateTime = dateTime.toLocal();

      // Format as: "04 Aug 2025, 05:16 PM"
      final day = localDateTime.day.toString().padLeft(2, '0');
      final month = _getMonthName(localDateTime.month);
      final year = localDateTime.year.toString();
      final hour = localDateTime.hour > 12
          ? (localDateTime.hour - 12).toString().padLeft(2, '0')
          : (localDateTime.hour == 0 ? 12 : localDateTime.hour)
                .toString()
                .padLeft(2, '0');
      final minute = localDateTime.minute.toString().padLeft(2, '0');
      final amPm = localDateTime.hour >= 12 ? 'PM' : 'AM';

      return '$day $month $year, $hour:$minute $amPm';
    } catch (e) {
      return dateTimeString;
    }
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64.sp,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Packing Details Found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'No packing details available for this work order and product.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.packing);
        }
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Packing Details'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.packing),
            ),
          ),
          body: Consumer<PackingProvider>(
            builder: (context, provider, child) {
              if (provider.error != null && provider.packingDetails.isEmpty) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.all(24.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: AppTheme.errorColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error Loading Packing Details',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.loadPackingDetails(
                              widget.workOrderId,
                              widget.productId,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text('Retry'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.isLoading && provider.packingDetails.isEmpty) {
                return Column(
                  children: [
                    // Shimmer for tab bar
                    Container(
                      margin: EdgeInsets.all(16.w),
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    // Shimmer for content
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        itemCount: 3,
                        itemBuilder: (context, index) => ShimmerCard(),
                      ),
                    ),
                  ],
                );
              }

              if (provider.packingDetails.isEmpty && !provider.isLoading) {
                return _buildEmptyState();
              }

              // Update tab controller with current data length
              _updateTabController(provider.packingDetails.length);

              return RefreshIndicator(
                onRefresh: () async {
                  await provider.loadPackingDetails(
                    widget.workOrderId,
                    widget.productId,
                  );
                },
                color: AppTheme.primaryBlue,
                backgroundColor: Colors.white,
                child: Column(
                  children: [
                    _buildCountIndicator(provider.packingDetails.length),
                    _buildTabBar(provider.packingDetails),
                    Expanded(child: _buildTabBarView(provider.packingDetails)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
