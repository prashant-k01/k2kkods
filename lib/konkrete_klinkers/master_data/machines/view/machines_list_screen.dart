import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:intl/intl.dart';
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
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machine_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MachinesListScreen extends StatefulWidget {
  const MachinesListScreen({super.key});

  @override
  State<MachinesListScreen> createState() => _MachinesListScreenState();
}

class _MachinesListScreenState extends State<MachinesListScreen> {
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScreenUtil.init(context);
          final provider = context.read<MachinesProvider>();
          if (provider.machines.isEmpty && provider.error == null) {
            print('Loading machines on MachinesListScreen init');
            provider.loadAllMachines(refresh: true);
          }
        }
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !context.read<MachinesProvider>().isLoading &&
          context.read<MachinesProvider>().hasMore) {
        print('Loading more machines');
        context.read<MachinesProvider>().loadAllMachines();
      }
    });
  }

  void _editMachine(String? machineId) {
    if (machineId != null) {
      print('Navigating to edit machine: $machineId');
      context.goNamed(
        RouteNames.machinesedit,
        pathParameters: {'machineId': machineId},
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy, hh:mm a').format(dateTime);
  }

  String _getCreatedBy(CreatedBy? createdBy) {
    if (createdBy == null || createdBy.username.isEmpty) {
      return 'Unknown';
    }
    return createdBy.username;
  }

  Widget _buildMachineCard(MachineElement machine) {
    final machineId = machine.id;
    final name = machine.name;
    final plantName = machine.plantId.plantName;
    final createdBy = _getCreatedBy(machine.createdBy);
    final createdAt = machine.createdAt;

    return CustomCard(
      title: name,
      titleColor: AppColors.background,
      leading: Icon(
        Icons.memory_outlined,
        color: AppColors.background,
        size: 20.sp,
      ),
      headerGradient: AppTheme.cardGradientList,
      borderRadius: 12,
      backgroundColor: AppColors.cardBackground,
      borderColor: AppColors.border,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

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
          _editMachine(machineId);
        } else if (value == 'delete') {
          print('Initiating delete for machine: $machineId');
          MachineDeleteScreen.deleteMachine(context, machineId, name);
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
            "Plant Name : $plantName",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
          ),
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
            Icons.factory_outlined,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
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
            route: RouteNames.machinesadd,
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
            title: TitleText(title: 'Machines'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.homeScreen);
              },
            ),
          ),
          floatingActionButton: GradientIconTextButton(
            onPressed: () => context.goNamed(RouteNames.machinesadd),
            label: 'Add Machine',
            icon: Icons.add,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),

          body: SafeArea(
            child: Consumer<MachinesProvider>(
              builder: (context, provider, child) {
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
                            provider.loadAllMachines(refresh: true);
                          },
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    print('Refreshing machines list');
                    await provider.loadAllMachines(refresh: true);
                  },
                  color: const Color(0xFF3B82F6),
                  backgroundColor: Colors.white,
                  child: provider.isLoading && provider.machines.isEmpty
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) => ShimmerCard(),
                        )
                      : provider.machines.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 16.h),
                          itemCount:
                              provider.machines.length +
                              (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.machines.length &&
                                provider.hasMore) {
                              return _buildLoadingIndicator();
                            }
                            return _buildMachineCard(provider.machines[index]);
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
