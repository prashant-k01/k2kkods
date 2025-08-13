import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch.dart';
import 'package:k2k/konkrete_klinkers/dispatch/provider/dispatch_provider.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class DispatchListView extends StatefulWidget {
  const DispatchListView({super.key});

  @override
  State<DispatchListView> createState() => _DispatchListViewState();
}

class _DispatchListViewState extends State<DispatchListView> {
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
          final provider = context.read<DispatchProvider>();
          if (provider.dispatches.isEmpty && provider.error == null) {
            provider.loadDispatches();
          }
        }
      });
    }
  }

  void _editDispatch(String? dispatchId) {
    if (dispatchId != null) {
      context.goNamed(
        '/dispatchEdit',
        pathParameters: {'dispatchId': dispatchId},
      );
    }
  }

  Widget _buildDispatchCard(DispatchModel dispatch) {
    final dispatchId = dispatch.id;
    final workOrderNumber = dispatch.workOrderNumber;
    final clientName = dispatch.clientName;
    final projectName = dispatch.projectName;
    final productNames = dispatch.productNames
        .map((p) => '${p.name} (${p.dispatchQuantity})')
        .join(', ');
    final createdBy = dispatch.createdBy;
    final createdAt = dispatch.createdAt.toString().split('.')[0];

    return Container(
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Text(
                            'Work Order: $workOrderNumber',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.darkGray,
                              fontWeight: FontWeight.w600,
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
                          _editDispatch(dispatchId);
                        } else if (value == 'delete') {
                          // Add delete logic here
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
                          Icons.person_outline,
                          size: 16.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Client: $clientName',
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
                          Icons.work_outline,
                          size: 16.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Project: $projectName',
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
                          Icons.inventory_outlined,
                          size: 16.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Products: $productNames',
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
                          Icons.access_time_outlined,
                          size: 16.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Created: $createdAt',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
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
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Text(
          'Dispatches',
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
          context.goNamed(RouteNames.dispatchAdd);
        },
        child: Row(
          children: [
            Icon(Icons.add, size: 20.sp, color: const Color(0xFF3B82F6)),
            SizedBox(width: 4.w),
            Text(
              'Add Dispatch',
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
            Icons.local_shipping_outlined,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Dispatches Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first dispatch!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Dispatch',
            icon: Icons.add,
            route: RouteNames.qcCheckAdd,
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
        body: Consumer<DispatchProvider>(
          builder: (context, provider, child) {
            if (provider.error != null && provider.dispatches.isEmpty) {
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
                      'Error Loading Dispatches',
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
                        provider.loadDispatches(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DispatchProvider>().loadDispatches(
                  refresh: true,
                );
              },
              color: const Color(0xFF3B82F6),
              backgroundColor: Colors.white,
              child: provider.isLoading
                  ? ListView.builder(
                      itemCount: 5, // shimmer count
                      itemBuilder: (context, index) => buildShimmerCard(),
                    )
                  : provider.dispatches.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 80.h),
                      itemCount: provider.dispatches.length,
                      itemBuilder: (context, index) {
                        return _buildDispatchCard(provider.dispatches[index]);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
