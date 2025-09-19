import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
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
import 'package:k2k/konkrete_klinkers/qc_check/model/qc_check.dart';
import 'package:k2k/konkrete_klinkers/qc_check/provider/qc_check_provider.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_delete.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class QcCheckListView extends StatefulWidget {
  const QcCheckListView({super.key});

  @override
  State<QcCheckListView> createState() => _QcCheckListViewState();
}

class _QcCheckListViewState extends State<QcCheckListView> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<QcCheckProvider>();
          if (provider.qcChecks.isEmpty && provider.error == null) {
            provider.loadQcChecks();
          }
        }
      });
    }
  }

  void _editQcCheck(String? qcCheckId) {
    if (qcCheckId != null) {
      context.goNamed(
        'qcCheckEdit', // Match the exact name from the route
        pathParameters: {'qcCheckId': qcCheckId},
      );
    }
  }

  Widget _buildQcCheckCard(QcCheckModel qcCheck) {
    final qcCheckId = qcCheck.id;
    final rejectedQuantity = qcCheck.rejectedQuantity.toString();
    final recycledQuantity = qcCheck.recycledQuantity.toString();
    final remarks = qcCheck.displayRemarks;
    final createdBy = qcCheck.displayCreatedBy;
    final createdAt = qcCheck.displayCreatedAt;
    final workOrderNumber = qcCheck.displayWorkOrder;
    final jobOrder = qcCheck.displayJobOrder;

    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      title: 'Work Order: $workOrderNumber',

      titleColor: AppColors.background,
      leading: SizedBox.shrink(), // No leading icon in original
      headerGradient: AppTheme.cardGradientList,
      backgroundColor: AppColors.cardBackground,

      borderColor: AppColors.border,
      borderWidth: 1,
      borderRadius: 12,
      elevation: 0,
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
          _editQcCheck(qcCheckId);
        } else if (value == 'delete') {
          QcCheckDeleteHandler.deleteQcCheck(context, qcCheckId, remarks);
        }
      },
      bodyItems: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Rejected: $rejectedQuantity',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.recycling_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Recycled: $recycledQuantity',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.work_outline,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Job Order: $jobOrder',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.comment_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Remarks: $remarks',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Created by: $createdBy',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Created: $createdAt',
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
            Icons.check_circle_outline,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No QC Checks Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first QC check!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add QC Check',
            icon: Icons.add,
            route: RouteNames.qcCheck,
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
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'QC Checks'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.homeScreen),
            ),
          ),
          floatingActionButton: GradientIconTextButton(
            onPressed: () => context.go(RouteNames.qcCheckAdd),
            label: 'Add QC Check',
            icon: Icons.add,
          ),
          body: Consumer<QcCheckProvider>(
            builder: (context, provider, child) {
              if (provider.error != null && provider.qcChecks.isEmpty) {
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
                        'Error Loading QC Checks',
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
                          provider.clearError();
                          provider.loadQcChecks(refresh: true);
                        },
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<QcCheckProvider>().loadQcChecks(
                    refresh: true,
                  );
                },
                color: const Color(0xFF3B82F6),
                backgroundColor: Colors.white,
                child: provider.isLoading
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => ShimmerCard(),
                      )
                    : provider.qcChecks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80.h),
                        itemCount:
                            provider.qcChecks.length +
                            (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.qcChecks.length &&
                              provider.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: GradientLoader(),
                              ),
                            );
                          }
                          return _buildQcCheckCard(provider.qcChecks[index]);
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
