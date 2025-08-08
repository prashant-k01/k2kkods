import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart';
import 'package:k2k/konkrete_klinkers/work_order/view/work_order_delete_screen.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Centralized color management

class WorkOrderListView extends StatefulWidget {
  const WorkOrderListView({super.key});

  @override
  State<WorkOrderListView> createState() => _WorkOrderListViewState();
}

class _WorkOrderListViewState extends State<WorkOrderListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<WorkOrderProvider>();
        if (provider.workOrders.isEmpty && provider.error == null) {
          debugPrint('Loading work orders on WorkOrderListView init');
          provider.loadAllWorkOrders();
        }
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      final provider = context.read<WorkOrderProvider>();
      if (provider.hasMoreData && !provider.isLoading) {
        debugPrint('Loading more work orders');
        provider.loadAllWorkOrders();
      }
    }
  }

  void _editWorkOrder(String? workOrderId) {
    if (workOrderId != null && workOrderId.isNotEmpty) {
      debugPrint('Navigating to edit work order: workOrderId=$workOrderId');
      context.goNamed(
        RouteNames.workordersedit,
        pathParameters: {'workorderId': workOrderId},
      );
    } else {
      _showSnackBar('Invalid Work Order ID');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body(13.sp)),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown Date';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _getClientName(String? clientId) {
    final provider = context.read<WorkOrderProvider>();
    final clientName = provider.getClientName(clientId);
    debugPrint('Client lookup: clientId=$clientId, name=$clientName');
    return clientName.isNotEmpty ? clientName : 'Unknown Client';
  }

  String _getProjectName(String? projectId) {
    final provider = context.read<WorkOrderProvider>();
    final projectName = provider.getProjectName(projectId);
    debugPrint('Project lookup: projectId=$projectId, name=$projectName');
    return projectName.isNotEmpty ? projectName : 'Unknown Project';
  }

  String _getCreatedBy(dynamic createdBy) {
    if (createdBy is CreatedBy && createdBy.username.name.isNotEmpty) {
      return createdBy.username.name;
    }
    debugPrint('Invalid createdBy: $createdBy');
    return 'Unknown';
  }

  Widget _buildWorkOrderCard(Datum workOrder) {
    final workOrderId = workOrder.id;
    final workOrderNumber = workOrder.workOrderNumber;
    final clientName = _getClientName(workOrder.clientId);
    final projectName = _getProjectName(workOrder.projectId);
    final createdBy = _getCreatedBy(workOrder.createdBy);
    final createdAt = _formatDateTime(workOrder.createdAt);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: () => context.goNamed(RouteNames.workorderdetail),
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
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Colors.deepPurple,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          workOrderNumber,
                          style: AppTextStyles.subtitle(14.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            _editWorkOrder(workOrderId);
                          } else if (value == 'delete') {
                            WorkOrderDeleteHandler.deleteWorkOrder(
                              context,
                              workOrderId,
                              workOrderNumber,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          _popupItem(
                            Icons.edit_outlined,
                            'Edit',
                            AppColors.primary,
                          ),
                          _popupItem(
                            Icons.delete_outline,
                            'Delete',
                            AppColors.error,
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
                      _infoRow(
                        Icons.business_outlined,
                        'Client',
                        clientName,
                        fontSize: 13,
                      ),
                      SizedBox(height: 6.h),
                      _infoRow(
                        Icons.folder_open_outlined,
                        'Project',
                        projectName,
                        fontSize: 13,
                      ),
                      SizedBox(height: 8.h),
                      _infoRow(
                        Icons.person_outline,
                        'Created by',
                        createdBy,
                        fontSize: 12,
                      ),
                      SizedBox(height: 6.h),
                      _infoRow(
                        Icons.access_time_outlined,
                        'Created',
                        createdAt,
                        fontSize: 12,
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

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    required double fontSize,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.textPrimary),
        SizedBox(width: 6.w),
        Text('$label:', style: AppTextStyles.subtitle(fontSize.sp)),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.secondary(fontSize.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _popupItem(
    IconData icon,
    String label,
    Color iconColor,
  ) {
    return PopupMenuItem(
      value: label.toLowerCase(),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 6.w),
          Text(label, style: AppTextStyles.body(13.sp)),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Work Orders',
            style: AppTextStyles.title(16.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 18.sp,
        color: AppColors.textPrimary,
      ),
      onPressed: () => context.go(RouteNames.homeScreen),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: TextButton(
        onPressed: () => context.goNamed(RouteNames.workordersadd),
        child: Row(
          children: [
            Icon(Icons.add, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              'Add Work Order',
              style: AppTextStyles.body(
                13.sp,
              ).copyWith(color: AppColors.primary),
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
            size: 48.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 12.h),
          Text('No Work Orders Found', style: AppTextStyles.title(16.sp)),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Tap the button below to add your first Work Order!',
              style: AppTextStyles.secondary(12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
          AddButton(
            text: 'Add Work Order',
            icon: Icons.add,
            route: RouteNames.workordersadd,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      child: Card(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 18.sp,
                      height: 18.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(height: 14.sp, color: Colors.grey[300]),
                    ),
                    Container(
                      width: 18.sp,
                      height: 18.sp,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Container(
                            width: 18.sp,
                            height: 18.sp,
                            color: Colors.grey[300],
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Container(
                              height: 13.sp,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.homeScreen);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBars(
          title: _buildLogoAndTitle(),
          leading: _buildBackButton(),
          action: [_buildActionButtons()],
        ),
        body: Consumer<WorkOrderProvider>(
          builder: (context, provider, child) {
            debugPrint(
              'UI Rebuild - WorkOrders: ${provider.workOrders.length}, HasMoreData: ${provider.hasMoreData}, IsLoading: ${provider.isLoading}',
            );
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Error Loading Work Orders',
                      style: AppTextStyles.title(16.sp),
                    ),
                    SizedBox(height: 6.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        provider.error ?? 'An unexpected error occurred',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondary(12.sp),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    RefreshButton(
                      text: 'Retry',
                      icon: Icons.refresh,
                      onTap: () {
                        provider.clearError();
                        provider.loadAllWorkOrders(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                debugPrint('Refreshing work orders list');
                await provider.loadAllWorkOrders(refresh: true);
              },
              color: AppColors.primary,
              backgroundColor: AppColors.cardBackground,
              child: provider.isLoading && provider.workOrders.isEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 16.h,
                        left: 8.w,
                        right: 8.w,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) => _buildShimmerCard(),
                    )
                  : provider.workOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 16.h,
                        left: 8.w,
                        right: 8.w,
                      ),
                      itemCount:
                          provider.workOrders.length +
                          (provider.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.workOrders.length &&
                            provider.hasMoreData) {
                          return _buildLoadingIndicator();
                        }
                        return _buildWorkOrderCard(provider.workOrders[index]);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
