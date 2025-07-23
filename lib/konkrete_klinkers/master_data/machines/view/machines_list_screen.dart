import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machine_delete_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MachinesListScreen extends StatefulWidget {
  const MachinesListScreen({super.key});

  @override
  State<MachinesListScreen> createState() => _MachinesListScreenState();
}

class _MachinesListScreenState extends State<MachinesListScreen> {
  bool _isInitialized = false;
  bool _isScreenUtilInitialized = false;
  final ScrollController _scrollController = ScrollController();
  final ScreenUtil screenUtil = ScreenUtil();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      final provider = context.read<MachinesProvider>();
      if (provider.machines.isEmpty && provider.error == null) {
        print('Loading machines on MachinesListScreen init');
        provider.loadAllMachines();
      }
    }
  }

  void editMachine(String? machineId) {
    if (machineId != null) {
      print('Navigating to edit machine: $machineId');
      context.goNamed(
        RouteNames.machinesedit,
        pathParameters: {'machineId': machineId},
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildMachineCard(MachineElement machineData) {
    final machineId = machineData.id;
    final name = machineData.name;
    final createdBy = machineData.createdBy.username;
    final createdAt = machineData.createdAt;

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
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 24.sp,
                        color: const Color(0xFF64748B),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          editMachine(machineId);
                        } else if (value == 'delete') {
                          print('Initiating delete for machine: $machineId');
                          MachineDeleteScreen.deleteMachine(
                            context,
                            machineId,
                            name,
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20.sp,
                                color: const Color(0xFFF59E0B),
                              ),
                              SizedBox(width: 8.w),
                              Text('Edit', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20.sp,
                                color: const Color(0xFFF43F5E),
                              ),
                              SizedBox(width: 8.w),
                              Text('Delete', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
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
            Icons.factory_outlined,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Machines Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first machine!',
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Machine',
            icon: Icons.add,
            route: RouteNames.machinesadd,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationInfo() {
    return Consumer<MachinesProvider>(
      builder: (context, provider, _) {
        if (provider.totalItems == 0 || provider.totalPages == 1) {
          return const SizedBox.shrink();
        }
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12.r,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(
                    Icons.arrow_back_ios,
                    provider.hasPreviousPage ? provider.previousPage : null,
                    'Previous',
                  ),
                  Text(
                    '${provider.currentPage}/${provider.totalPages}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildNavButton(
                    Icons.arrow_forward_ios,
                    provider.hasNextPage ? provider.nextPage : null,
                    'Next',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavButton(
    IconData icon,
    VoidCallback? onPressed,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: onPressed != null
                ? const Color(0xFF3B82F6)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 24.sp, color: Colors.white),
        ),
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
          'Machines Management',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(RouteNames.homeScreen),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: TextButton(
              onPressed: () {
                print('Navigating to add machine screen');
                context.goNamed(RouteNames.machinesadd);
              },
              child: Row(
                children: [
                  Icon(Icons.add, size: 20.sp, color: const Color(0xFF3B82F6)),
                  SizedBox(width: 4.w),
                  Text(
                    'Add Machine',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<MachinesProvider>(
            builder: (context, provider, _) {
              if (provider.error != null) {
                print('Error in MachinesProvider: ${provider.error}');
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
                        'Error Loading Machines',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      RefreshButton(
                        text: 'Retry',
                        icon: Icons.refresh,
                        onTap: () {
                          print('Retrying to load machines');
                          provider.clearError();
                          provider.loadAllMachines(refresh: true);
                        },
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () {
                  print('Refreshing machines list');
                  return provider.loadAllMachines(refresh: true);
                },
                color: const Color(0xFF3B82F6),
                backgroundColor: Colors.white,
                child: provider.isLoading && provider.machines.isEmpty
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (_, __) => _isScreenUtilInitialized
                            ? buildShimmerCard()
                            : const SizedBox.shrink(),
                      )
                    : provider.machines.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(bottom: 80.h),
                        itemCount: provider.machines.length,
                        itemBuilder: (context, index) =>
                            _buildMachineCard(provider.machines[index]),
                      ),
              );
            },
          ),
          _buildPaginationInfo(),
        ],
      ),
    );
  }
}
