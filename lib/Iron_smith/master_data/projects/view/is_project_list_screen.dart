import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/provider/is_project_provider.dart';
import 'package:k2k/Iron_smith/master_data/projects/view/is_project_delete_screen.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/gradient_icon_button.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/common/widgets/custom_card.dart';

class IsProjectsListScreen extends StatefulWidget {
  const IsProjectsListScreen({super.key});

  @override
  State<IsProjectsListScreen> createState() => _IsProjectsListScreenState();
}

class _IsProjectsListScreenState extends State<IsProjectsListScreen> {
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
          final provider = context.read<IsProjectProvider>();
          if (provider.projects.isEmpty && provider.error == null) {
            provider.fetchProjects(refresh: true);
          }
        }
      });
    }
  }

  void _editProject(String? projectId) {
    if (projectId != null) {
      context.goNamed(
        RouteNames.isProjectEdit,
        pathParameters: {'projectId': projectId},
      );
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'N/A';
    try {
      final parsedDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateTime);
      return DateFormat('dd-MM-yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getCreatedBy(IsPCreatedBy? createdBy) {
    return createdBy?.username ?? 'Unknown';
  }

  Widget _buildProjectCard(IsProject project) {
    final projectId = project.id;
    final projectName = project.name ?? "Unnamed Project";
    final clientName = project.client?.name ?? "No Client";
    final address = project.address ?? "No Address";
    final createdBy = _getCreatedBy(project.createdBy);
    final createdAt = project.createdAt;

    return CustomCard(
      title: projectName,
      titleColor: const Color(0xFF334155),
      leading: const SizedBox.shrink(),
      headerGradient: AppTheme.lightGradient,
      bodyItems: [
        Text(
          "Client: $clientName",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.ironSmithSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            "Address: $address",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.ironSmithSecondary,
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
                'Created At: ${_formatDateTime(project.createdAt)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
      ],
      menuItems: [
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
      onMenuSelected: (value) {
        if (value == 'edit') {
          _editProject(projectId);
        } else if (value == 'delete') {
          ProjectDeleteHandler.confirmDelete(
            context,
            projectId: projectId,
            projectName: projectName,
          );
        }
      },
      backgroundColor: AppColors.cardBackground,
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1.w,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      showAddButton: true,
      addButtonGradient: AppTheme.darkGradient,
      addButtonText: 'Add Raw Materials', // Text inside the button
      onAddPressed: () {
        if (projectId != null) {
          context.goNamed(
            RouteNames.isRawMaterial,
            pathParameters: {'projectId': projectId},
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64.sp,
            color: AppTheme.ironSmithPrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Projects Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first project!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Project',
            icon: Icons.add,
            route: RouteNames.isProjectAdd,
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
        backgroundColor: Colors.white,
        appBar: AppBars(
          title: TitleText(title: 'Projects'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.homeScreen),
          ),
        ),
        floatingActionButton: GradientIconTextButton(
          gradientColors: [
            Color(0xFFB3E5FC), // Light Blue 100
            Color(0xFFD1C4E9), // Light Purple 100
          ],
          label: 'Create Project',
          icon: Icons.add,
          onPressed: () => context.go(RouteNames.isProjectAdd),
        ),
        body: Consumer<IsProjectProvider>(
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
                      'Error Loading Projects',
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
                        provider.clearError();
                        provider.fetchProjects(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchProjects(refresh: true);
                },
                color: AppTheme.ironSmithPrimary,
                backgroundColor: Colors.white,
                child: provider.isLoading && provider.projects.isEmpty
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => ShimmerCard(),
                      )
                    : provider.projects.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16.h),
                        itemCount: provider.projects.length,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(provider.projects[index]);
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
