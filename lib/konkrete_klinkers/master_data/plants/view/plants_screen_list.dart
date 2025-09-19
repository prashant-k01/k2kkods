import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class PlantsListView extends StatefulWidget {
  const PlantsListView({super.key});

  @override
  State<PlantsListView> createState() => _PlantsListViewState();
}

class _PlantsListViewState extends State<PlantsListView> {
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
          final provider = context.read<PlantProvider>();
          if (provider.plants.isEmpty && provider.error == null) {
            provider.loadPlants();
          }
        }
      });
    }
  }

  void _editPlant(String? plantId) {
    if (plantId != null) {
      context.goNamed(
        RouteNames.plantsedit,
        pathParameters: {'plantId': plantId},
      );
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final formatter = DateFormat('dd-MM-yyyy, hh:mm a');
    return formatter.format(dateTime.toLocal());
  }

  String _getCreatedBy(dynamic createdBy) {
    if (createdBy is Map<String, dynamic>) {
      return createdBy['username']?.toString() ?? 'Unknown';
    }
    return createdBy?.toString() ?? 'Unknown';
  }

  Widget _buildPlantCard(dynamic plant) {
    final plantData = plant is Map<String, dynamic> ? plant : plant.toJson();
    final plantId =
        plantData['_id']?.toString() ?? plantData['id']?.toString() ?? '';
    final plantName =
        plantData['plant_name']?.toString() ??
        plantData['plantName']?.toString() ??
        'Unknown Plant';
    final plantCode =
        plantData['plant_code']?.toString() ??
        plantData['plantCode']?.toString() ??
        'N/A';
    final createdBy = _getCreatedBy(
      plantData['created_by'] ?? plantData['createdBy'],
    );

    // Use PlantModel's createdAt property if available
    DateTime? createdAt;
    if (plant is PlantModel) {
      createdAt = plant.createdAt;
    } else {
      createdAt = plantData['createdAt'] != null
          ? DateTime.tryParse(plantData['createdAt'].toString())
          : null;
    }

    return CustomCard(
      title: plantName,
      titleColor: AppColors.background,
      leading: Icon(
        Icons.factory_outlined,
        size: 20.sp,
        color: AppColors.background,
      ),
      headerGradient: AppTheme.cardGradientList,
      borderRadius: 12,
      backgroundColor: AppColors.cardBackground,
      borderColor: AppColors.border,
      borderWidth: 1,
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
          _editPlant(plantId);
        } else if (value == 'delete') {
          PlantDeleteHandler.deletePlant(context, plantId, plantName);
        }
      },
      bodyItems: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'Plant Code: $plantCode',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
          ),
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
              'Created: ${_formatDateTime(createdAt)}',
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
            'No Plants Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first plant!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Plant',
            icon: Icons.add,
            route: RouteNames.plantsadd,
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
            title: TitleText(title: 'Plants Management'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.homeScreen);
              },
            ),
          ),
          floatingActionButton: GradientIconTextButton(
            onPressed: () => context.goNamed(RouteNames.plantsadd),
            label: 'Add Plants',
            icon: Icons.add,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          body: Consumer<PlantProvider>(
            builder: (context, provider, child) {
              if (provider.error != null && provider.plants.isEmpty) {
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
                        'Error Loading Plants',
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
                          provider.loadPlants(refresh: true);
                        },
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<PlantProvider>().loadPlants(refresh: true);
                },
                color: const Color(0xFF3B82F6),
                backgroundColor: Colors.white,
                child: provider.isLoading && provider.plants.isEmpty
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => ShimmerCard(),
                      )
                    : provider.plants.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80.h),
                        itemCount:
                            provider.plants.length +
                            (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.plants.length &&
                              provider.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: GradientLoader(),
                              ),
                            );
                          }
                          return _buildPlantCard(provider.plants[index]);
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
