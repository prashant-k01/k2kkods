import 'package:flutter/material.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/action_button.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/container.dart';
import 'package:k2k/common/list_helper/info_card.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_delete_screen.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;

class PlantsListView extends StatefulWidget {
  const PlantsListView({super.key});

  @override
  State<PlantsListView> createState() => _PlantsListViewState();
}

class _PlantsListViewState extends State<PlantsListView> {
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

  void _initializeData() async {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<PlantProvider>();
          if (provider.plants.isEmpty && provider.error == null) {
            provider.loadAllPlants();
          }
        }
      });
    }
  }

  void _viewPlant(String? plantId, Map<String, dynamic> plantData) {
    if (plantId != null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 650.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                GradientContainer(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 20.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_florist_outlined,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Plant Information',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.all(8.w),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Flexible(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: plantData.entries
                            .where(
                              (entry) =>
                                  entry.key != '_id' &&
                                  entry.value is! Map &&
                                  entry.value is! List,
                            )
                            .map((entry) {
                              return InfoCard(
                                title: _formatKey(entry.key),
                                value: _formatValue(entry.value),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                ),

                // Footer Section
                Container(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GradientContainer(
                        borderRadius: BorderRadius.circular(10.r),
                        padding: EdgeInsets.zero,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10.r),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Got it',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
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
              ],
            ),
          ),
        ),
      );
    }
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is DateTime) {
      return _formatDateTime(value);
    }
    if (value is Map<String, dynamic>) {
      return value['username']?.toString() ?? 'Unknown';
    }
    return value.toString();
  }

  void _editPlant(String? plantId) {
    if (plantId != null) {
      context.goNamed(
        RouteNames.plantsedit,
        pathParameters: {'plantId': plantId},
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _getCreatedBy(dynamic createdBy) {
    if (createdBy is Map<String, dynamic>) {
      return createdBy['username'] ?? 'Unknown';
    }
    return createdBy?.toString() ?? 'Unknown';
  }

  Widget _buildPaginationInfo() {
    return Consumer<PlantProvider>(
      builder: (context, provider, child) {
        if (provider.totalItems == 0) return SizedBox.shrink();

        if (provider.showAll) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              'Showing all ${provider.totalItems} plants',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final startItem = ((provider.currentPage - 1) * provider.limit) + 1;
        final endItem = (startItem + provider.plants.length - 1).clamp(
          1,
          provider.totalItems,
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $startItem-$endItem of ${provider.totalItems} plants',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Page ${provider.currentPage} of ${provider.totalPages}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlantCard(dynamic plant) {
    final plantData = plant is Map<String, dynamic> ? plant : plant.toJson();
    final plantId = plantData['_id'] ?? plantData['id'] ?? '';
    final plantName =
        plantData['plant_name'] ?? plantData['plantName'] ?? 'Unknown Plant';
    final plantCode =
        plantData['plant_code'] ?? plantData['plantCode'] ?? 'N/A';
    final createdBy = _getCreatedBy(
      plantData['created_by'] ?? plantData['createdBy'],
    );
    final createdAt = plantData['createdAt'] != null
        ? DateTime.tryParse(plantData['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
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
                            plantName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              plantCode,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ActionButton(
                          icon: Icons.visibility_outlined,
                          color: const Color(0xFF3B82F6),
                          onPressed: () => _viewPlant(plantId, plantData),
                        ),
                        SizedBox(width: 16.w),
                        ActionButton(
                          icon: Icons.edit_outlined,
                          color: const Color(0xFFF59E0B),
                          onPressed: () => _editPlant(plantId),
                        ),
                        SizedBox(width: 16.w),
                        ActionButton(
                          icon: Icons.delete_outline,
                          color: const Color(0xFFF43F5E),
                          onPressed: () => PlantDeleteHandler.deletePlant(
                            context,
                            plantId,
                            plantName,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
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
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            'No Plants Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by adding a new plant!',
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334155),
        title: Text(
          'Plants Management',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final provider = context.read<PlantProvider>();
              provider.loadAllPlants(refresh: true);
            },
            icon: Icon(Icons.refresh, size: 24.sp),
            tooltip: 'Refresh',
          ),
          Consumer<PlantProvider>(
            builder: (context, provider, child) => Row(
              children: [
                Switch(
                  value: provider.showAll,
                  onChanged: (value) {
                    provider.toggleShowAll(value);
                  },
                  activeColor: const Color(0xFF3B82F6),
                  activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.5),
                  inactiveThumbColor: const Color(0xFF64748B),
                  inactiveTrackColor: const Color(0xFFCBD5E1),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Text(
                    'Show All',
                    style: TextStyle(
                      color: const Color(0xFF334155),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<PlantProvider>(
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
                      provider.loadAllPlants(refresh: true);
                    },
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: _buildPaginationInfo(),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadAllPlants(refresh: true);
                  },
                  color: const Color(0xFF3B82F6),
                  backgroundColor: Colors.white,
                  child: provider.isLoading && provider.plants.isEmpty
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) => buildShimmerCard(),
                        )
                      : provider.plants.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: provider.plants.length,
                          itemBuilder: (context, index) {
                            return _buildPlantCard(provider.plants[index]);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AddButton(
        text: 'Add Plant',
        icon: Icons.add,
        route: RouteNames.plantsadd,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
