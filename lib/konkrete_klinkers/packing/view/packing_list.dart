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
import 'package:k2k/konkrete_klinkers/packing/model/packing.dart';
import 'package:k2k/konkrete_klinkers/packing/provider/packing_provider.dart';
import 'package:k2k/konkrete_klinkers/packing/view/packing_delete.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class PackingListView extends StatefulWidget {
  const PackingListView({super.key});

  @override
  State<PackingListView> createState() => _PackingListViewState();
}

class _PackingListViewState extends State<PackingListView> {
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
          final provider = context.read<PackingProvider>();
          if (provider.packings.isEmpty && provider.error == null) {
            provider.loadPackings();
          }
        }
      });
    }
  }

  // Handle back navigation properly
  void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.homeScreen);
    }
  }

  Widget _buildPackingCard(PackingModel packing) {
    final workOrderNumber = packing.displayWorkOrderNumber;
    final productName = packing.displayProductName;
    final totalBundles = packing.displayTotalBundles;
    final totalQuantity = packing.displayTotalQuantity;
    final createdBy = packing.displayCreatedBy;
    final createdAt = packing.displayCreatedAt;

    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      title: 'Work Order: $workOrderNumber',
      titleColor: AppColors.background,
      leading: SizedBox.shrink(), // No leading icon in original
      headerGradient: AppTheme.cardGradientList,
      backgroundColor: AppColors.cardBackground,
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1,
      borderRadius: 12,
      elevation: 0,
      onTap: () {
        context.goNamed(
          RouteNames.packingDetails,
          pathParameters: {
            'workOrderId': packing.workOrderId,
            'productId': packing.productId,
          },
        );
      },
      menuItems: [
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 20.sp, color: AppTheme.primaryBlue),
              SizedBox(width: 8.w),
              Text(
                'View',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.mediumGray),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 20.sp,
                color: AppTheme.warningColor,
              ),
              SizedBox(width: 8.w),
              Text(
                'Edit',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.mediumGray),
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
                color: AppTheme.errorColor,
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
        if (value == 'view') {
          context.goNamed(
            RouteNames.packingDetails,
            pathParameters: {
              'workOrderId': packing.workOrderId,
              'productId': packing.productId,
            },
          );
        } else if (value == 'edit') {
          context.goNamed(RouteNames.packingadd, extra: packing.toJson());
        } else if (value == 'delete') {
          PackingDeleteHandler.deletePacking(context, packing.id, productName);
        }
      },
      bodyItems: [
        Row(
          children: [
            Icon(Icons.inventory, size: 16.sp, color: const Color(0xFF64748B)),
            SizedBox(width: 8.w),
            Text(
              'Product: $productName',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Total Bundles: $totalBundles',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.format_list_numbered,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 8.w),
            Text(
              'Total Quantity: $totalQuantity',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
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
              color: AppTheme.mediumGray,
            ),
            SizedBox(width: 8.w),
            Text(
              'Created: $createdAt',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.mediumGray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Text(
          'Packings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: 24.sp, color: AppTheme.darkGray),
      onPressed: _handleBackNavigation,
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: TextButton(
        onPressed: () {
          context.goNamed(RouteNames.packingadd);
        },
        child: Row(
          children: [
            Icon(Icons.add, size: 20.sp, color: AppTheme.primaryBlue),
            SizedBox(width: 4.w),
            Text(
              'Add Packing',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
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
            Icons.check_circle_outline,
            size: 64.sp,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Packings Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first packing!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Packing',
            icon: Icons.add,
            route: RouteNames.packingadd,
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
            title: TitleText(title: 'Packings'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.homeScreen),
            ),
          ),
          floatingActionButton: GradientIconTextButton(
            onPressed: () => context.go(RouteNames.packingadd),
            label: 'Add Packing',
            icon: Icons.add,
          ),
          body: Consumer<PackingProvider>(
            builder: (context, provider, child) {
              print(
                'Building PackingListView: '
                'packings=${provider.packings.length}, '
                'isLoading=${provider.isLoading}, '
                'error=${provider.error}, '
                'packingIds=${provider.packings.map((p) => p.id).toList()}',
              );

              // Show error state only if there's an error and no packings
              if (provider.error != null && provider.packings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppTheme.errorColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error Loading Packings',
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
                          provider.loadPackings(refresh: true);
                        },
                      ),
                    ],
                  ),
                );
              }

              // Show loading shimmer only for initial load with no packings
              if (provider.isLoading && provider.packings.isEmpty) {
                return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => ShimmerCard(),
                );
              }

              // Show empty state only if no packings and not loading
              if (provider.packings.isEmpty && !provider.isLoading) {
                return _buildEmptyState();
              }

              // Show packing list with RefreshIndicator
              return RefreshIndicator(
                onRefresh: () async {
                  await provider.loadPackings(refresh: true);
                },
                color: AppTheme.primaryBlue,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 80.h),
                  itemCount:
                      provider.packings.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.packings.length &&
                        provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: GradientLoader(),
                        ),
                      );
                    }
                    final packing = provider.packings[index];
                    print(
                      'Rendering packing card: id=${packing.id}, '
                      'workOrder=${packing.displayWorkOrderNumber}, '
                      'product=${packing.displayProductName}',
                    );
                    return _buildPackingCard(packing);
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
