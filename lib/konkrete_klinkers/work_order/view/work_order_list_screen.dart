import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/gradient_icon_button.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart';
import 'package:k2k/konkrete_klinkers/work_order/view/work_order_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

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
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
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

    return CustomCard(
      margin: EdgeInsetsGeometry.symmetric(vertical: 12.h, horizontal: 12.w),
      title: workOrderNumber,
      titleColor: AppColors.background,
      leading: Icon(
        Icons.description_outlined,
        size: 20.sp,
        color: AppColors.background,
      ),
      onTap: () {
        if (workOrderId.isEmpty) {
          context.showErrorSnackbar('Invalid Work Order No');
          return;
        }
        context.goNamed(
          RouteNames.workorderdetail,
          pathParameters: {'id': workOrderId},
        );
      },
      menuItems: [
        _popupItem(Icons.edit_outlined, 'Edit', AppColors.primary),
        _popupItem(Icons.delete_outline, 'Delete', AppColors.error),
      ],
      onMenuSelected: (value) {
        if (value == 'edit') {
          _editWorkOrder(workOrder.id);
        } else if (value == 'delete') {
          WorkOrderDeleteHandler.deleteWorkOrder(
            context,
            workOrder.id,
            workOrderNumber,
          );
        }
      },
      bodyItems: [
        _infoRow(Icons.business_outlined, 'Client', clientName, fontSize: 13),
        SizedBox(height: 6.h),
        _infoRow(
          Icons.folder_open_outlined,
          'Project',
          projectName,
          fontSize: 13,
        ),
        SizedBox(height: 8.h),
        _infoRow(Icons.person_outline, 'Created by', createdBy, fontSize: 12),
        SizedBox(height: 6.h),
        _infoRow(
          Icons.access_time_outlined,
          'Created',
          createdAt,
          fontSize: 12,
        ),
      ],
      headerGradient: AppTheme.cardGradientList,
      backgroundColor: AppColors.cardBackground,
      borderColor: AppColors.border,
      borderRadius: 12.r,
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

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(child: GradientLoader()),
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
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Work Orders'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.homeScreen);
              },
            ),
          ),
          floatingActionButton: GradientIconTextButton(
            onPressed: () => context.goNamed(RouteNames.workordersadd),
            label: 'Add Work Order',
            icon: Icons.add,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          body: Consumer<WorkOrderProvider>(
            builder: (context, provider, child) {
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
                          provider.loadAllWorkOrders(refresh: true);
                        },
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
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
                        itemBuilder: (context, index) => ShimmerCard(),
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
                          return _buildWorkOrderCard(
                            provider.workOrders[index],
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
