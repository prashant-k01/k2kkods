import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/provider/job_order_provider.dart';
import 'package:k2k/konkrete_klinkers/job_order/view/job_order_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class JobOrderListView extends StatefulWidget {
  const JobOrderListView({super.key});

  @override
  State<JobOrderListView> createState() => _JobOrderListViewState();
}

class _JobOrderListViewState extends State<JobOrderListView> {
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<JobOrderProvider>();
          if (provider.jobOrders.isEmpty && provider.error == null) {
            provider.loadAllJobOrders(refresh: true);
          }
        }
      });
    }
  }

  void _editJobOrder(String mongoId) {
    context.goNamed(
      RouteNames.jobOrderedit,
      pathParameters: {'mongoId': mongoId},
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildJobOrderCard(JobOrderModel jobOrder) {
    final mangoId = jobOrder.mongoId;
    final batchNumber = jobOrder.batchNumber.toString();

    final fromDate = DateTime.tryParse(jobOrder.date.from);
    final toDate = DateTime.tryParse(jobOrder.date.to);

    return InkWell(
      onTap: () {
        context.goNamed(
          RouteNames.jobOrderView,
          pathParameters: {'mongoId': mangoId},
          extra: jobOrder,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Card(
          elevation: 0,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cardHeaderStart,
                        AppColors.cardHeaderEnd,
                        AppColors.cardBackground,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.03),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Order NO: ${jobOrder.jobOrderId}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Project: ${jobOrder.projectName}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editJobOrder(mangoId);
                          } else if (value == 'delete') {
                            print(
                              '🔍 DEBUG - mongoId being passed: ${jobOrder.mongoId}',
                            );
                            print(
                              '🔍 DEBUG - batchNumber being passed: $batchNumber',
                            );
                            JobOrderDeleteHandler.deleteJoborder(
                              context,
                              jobOrder.mongoId,
                              batchNumber.toString(),
                            );
                          } else if (value == 'view') {
                            context.goNamed(
                              RouteNames.jobOrderView,
                              pathParameters: {'mongoId': mangoId},
                              extra: jobOrder,
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20.sp,
                                  color: const Color(0xFFF59E0B),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 20.sp,
                                  color: const Color(0xFF3B82F6),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 20.sp,
                                  color: const Color(0xFFF43F5E),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        offset: Offset(0, 32.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        color: AppColors.cardBackground,
                        elevation: 2,
                      ),
                    ],
                  ),
                ),
                // Body Section
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 16.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Batch No: $batchNumber',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 16.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Sales Order: ${jobOrder.salesOrderNumber}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Status: ${jobOrder.status}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Schedule Period',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.play_arrow_outlined,
                                            size: 16.sp,
                                            color: const Color(0xFF10B981),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'From:',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _formatDateTime(fromDate),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40.h,
                                  width: 1,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.stop_outlined,
                                            size: 16.sp,
                                            color: const Color(0xFFF59E0B),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'To:',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _formatDateTime(toDate),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Text(
          'Job Orders',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 24.sp,
        color: const Color(0xFF334155),
      ),
      onPressed: () {
        context.go(RouteNames.homeScreen);
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: TextButton(
        onPressed: () {
          context.goNamed(RouteNames.joborderadd);
        },
        child: Row(
          children: [
            Icon(Icons.add, size: 20.sp, color: const Color(0xFF3B82F6)),
            SizedBox(width: 4.w),
            Text(
              'Add Job Order',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_florist_outlined,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Job Orders Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first Job Order!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.goNamed(RouteNames.joborderadd);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            child: Text(
              'Add Job Order',
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
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
          context.go(RouteNames.homeScreen);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: _buildLogoAndTitle(),
          leading: _buildBackButton(),
          action: [_buildActionButtons()],
        ),
        body: Consumer<JobOrderProvider>(
          builder: (context, provider, child) {
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
                      'Error Loading Job Orders',
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
                    SizedBox(height: 16.h),
                    RefreshButton(
                      text: 'Retry',
                      icon: Icons.refresh,
                      onTap: () {
                        provider.error;
                        provider.loadAllJobOrders(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadAllJobOrders(refresh: true);
              },
              color: const Color(0xFF3B82F6),
              backgroundColor: Colors.white,
              child: provider.isLoading && provider.jobOrders.isEmpty
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => buildShimmerCard(),
                    )
                  : provider.jobOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: provider.jobOrders.length,
                      itemBuilder: (context, index) {
                        return _buildJobOrderCard(provider.jobOrders[index]);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
