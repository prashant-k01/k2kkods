import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/master_data/machines/model/machines.dart';
import 'package:k2k/Iron_smith/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/Iron_smith/master_data/machines/view/machine_delete.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/gradient_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';

class IsMachinesListScreen extends StatefulWidget {
  const IsMachinesListScreen({super.key});

  @override
  State<IsMachinesListScreen> createState() => _IsMachinesListScreenState();
}

class _IsMachinesListScreenState extends State<IsMachinesListScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScreenUtil.init(context);
          final provider = context.read<IsMachinesProvider>();
          if (provider.machines.isEmpty && provider.error == null) {
            print('Loading machines on IsMachinesListScreen init');
            provider.fetchMachines(refresh: true);
          }
        }
      });
    }
  }

  void _editMachine(String? machineId) {
    if (machineId != null) {
      print('Navigating to edit machine: $machineId');
      context.goNamed(
        RouteNames.isMachineEdit,
        pathParameters: {'machineId': machineId},
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy, hh:mm a').format(dateTime);
  }

  String _getCreatedBy(CreatedBy? createdBy) {
    return createdBy?.username ?? 'Unknown';
  }

  Widget _buildMachineCard(Machines machine) {
    final machineId = machine.id?.oid;
    final name = machine.name;
    final role = machine.role;
    final createdBy = _getCreatedBy(machine.createdBy);
    final createdAt = machine.createdAt?.date;

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
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.ironSmithGradient,
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
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
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
                          _editMachine(machineId);
                        } else if (value == 'delete') {
                          print('Initiating delete for machine: $machineId');
                          MachineDeleteHandler.confirmDelete(
                            context,
                            machineId: machineId,
                            machineName: name,
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
                                color: AppTheme.ironSmithSecondary,
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
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        "Role: $role",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ironSmithSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
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
                    if (createdAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Created At: ${_formatDateTime(createdAt)}',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.factory_outlined,
            size: 64.sp,
            color: AppTheme.ironSmithPrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Machines Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first machine!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Machine',
            icon: Icons.add,
            route: RouteNames.isMachineAdd,
          ),
        ],
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBars(
          title: TitleText(title: 'Machines'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.homeScreen),
          ),
        ),
        floatingActionButton: GradientIconTextButton(
          gradientColors: [Color(0xFFBBDEFB), Color(0xFFB2EBF2)],
          label: 'Create Machine',
          icon: Icons.add,
          onPressed: () => context.go(RouteNames.isMachineAdd),
        ),
        body: Consumer<IsMachinesProvider>(
          builder: (context, provider, child) {
            if (provider.error != null) {
              print('Error in IsMachinesProvider: ${provider.error}');
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
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        provider.error.toString(),
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
                        print('Retrying to load machines');
                        provider.clearError();
                        provider.fetchMachines(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  print('Refreshing machines list');
                  await provider.fetchMachines(refresh: true);
                },
                color: AppTheme.ironSmithPrimary,
                backgroundColor: Colors.white,
                child: provider.isLoading && provider.machines.isEmpty
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => buildShimmerCard(),
                      )
                    : provider.machines.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16.h),
                        itemCount: provider.machines.length,
                        itemBuilder: (context, index) {
                          return _buildMachineCard(provider.machines[index]);
                        },
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
