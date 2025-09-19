import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/Iron_smith/job_order/model/job_order_summary.dart';
import 'package:k2k/Iron_smith/job_order/provider/job_order_provider_is.dart';
import 'package:k2k/Iron_smith/job_order/view/job_order_delete_screen_is.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/gradient_icon_button.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class JobOrderListViewIS extends StatefulWidget {
  const JobOrderListViewIS({super.key});

  @override
  State<JobOrderListViewIS> createState() => _JobOrderListViewISState();
}

class _JobOrderListViewISState extends State<JobOrderListViewIS> {
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<JobOrderProviderIS>();
          if (provider.jobOrders.isEmpty && provider.error == null) {
            provider.loadAllJobOrders(refresh: true);
          }
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      final provider = context.read<JobOrderProviderIS>();
      if (provider.hasMoreData && !provider.isLoading) {
        provider.loadAllJobOrders(refresh: false);
      }
    }
  }

  void _editJobOrder(String jobOrderId) {
    context.goNamed(
      RouteNames.jobOrderedit,
      pathParameters: {'mongoId': jobOrderId},
    );
  }

  Widget _buildJobOrderCard(JobOrderData jobOrder) {
    final provider = context.read<JobOrderProviderIS>();
    final formattedDate = provider.formatDate(jobOrder.createdAt);

    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      title: 'Job Order NO: ${jobOrder.jobOrderNumber ?? "N/A"}',
      titleColor: AppColors.background,
      subtitleColor: const Color(0xFF64748B),
      leading: SizedBox.shrink(),
      headerGradient: AppTheme.cardGradientList,
      backgroundColor: AppColors.cardBackground,
      borderColor: AppColors.border,
      borderWidth: 1,
      borderRadius: 12.r,
      elevation: 0,
      onTap: () {
        // Navigation to view details can be enabled if needed
        context.goNamed(
          RouteNames.viewIronJobOrder,
          pathParameters: {'joborderId': jobOrder.id!},
          extra: jobOrder,
        );
      },
      menuItems: [
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
      onMenuSelected: (value) {
        if (value == 'edit') {
          _editJobOrder(jobOrder.id!);
        } else if (value == 'delete') {
          JobOrderDeleteHandlerIS.deleteJoborder(
            context,
            jobOrder.id,
            jobOrder.jobOrderNumber,
          );
        }
      },
      bodyItems: [
        Row(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Work Order: ${jobOrder.workOrder?.workOrderNumber ?? "N/A"}',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Created At: $formattedDate',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Project: ${jobOrder.project?.name ?? "N/A"}',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ],
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
              color: const Color(0xFF334155),
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
              context.goNamed(RouteNames.addIronJobOrder);
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
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Job Orders'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.homeScreen);
              },
            ),
          ),
          floatingActionButton: GradientIconTextButton(
            label: 'Add Job Order',
            onPressed: () => context.go(RouteNames.addIronJobOrder),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            icon: Icons.add,
          ),
          body: SafeArea(
            child: Consumer<JobOrderProviderIS>(
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
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).padding.bottom + 16.h,
                            left: 8.w,
                            right: 8.w,
                          ),
                          itemCount: 5,
                          itemBuilder: (context, index) => ShimmerCard(),
                        )
                      : provider.jobOrders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).padding.bottom + 16.h,
                            left: 8.w,
                            right: 8.w,
                          ),
                          itemCount: provider.jobOrders.length,
                          itemBuilder: (context, index) {
                            if (index == provider.jobOrders.length) {
                              return _buildLoadingIndicator();
                            }
                            return _buildJobOrderCard(
                              provider.jobOrders[index],
                            );
                          },
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
