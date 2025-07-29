import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/model/projects.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/provider/projects_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:provider/provider.dart';

class ProjectsListView extends StatefulWidget {
  const ProjectsListView({super.key});

  @override
  State<ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<ProjectsListView> {
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrollLoading = false;

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
          final provider = context.read<ProjectProvider>();
          if (provider.projects.isEmpty && provider.error == null) {
            provider.loadAllProjects();
          }
        }
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !context.read<ProjectProvider>().isLoading &&
          context.read<ProjectProvider>().hasMore &&
          !_isScrollLoading) {
        _isScrollLoading = true;
        await context.read<ProjectProvider>().loadAllProjects();
        _isScrollLoading = false;
      }
    });
  }

  void _editProjects(String? projectsId) {
    if (projectsId != null) {
      context.goNamed(
        RouteNames.projectsedit,
        pathParameters: {'projectsId': projectsId},
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildProjectsCard(dynamic project) {
    final projectModel = project is ProjectModel
        ? project
        : ProjectModel.fromJson(project is Map<String, dynamic> ? project : {});

    final projectsId = projectModel.id;
    final projectsName = projectModel.name.isNotEmpty ? projectModel.name : 'Unknown Project';
    final projectsAddress = projectModel.address.isNotEmpty ? projectModel.address : 'N/A';
    final createdBy = projectModel.createdBy.username.isNotEmpty ? projectModel.createdBy.username : 'Unknown';
    final createdAt = projectModel.createdAt;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
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
                            projectsName,
                            style: TextStyle(
                              fontSize: 18.sp, // Increased from 16.sp
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 6.h), // Slightly increased spacing
                          Text(
                            projectsAddress,
                            style: TextStyle(
                              fontSize: 16.sp, // Increased from 14.sp
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B82F6),
                            ),
                            maxLines: 2, // Allow wrapping to second line
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 22.sp, color: const Color(0xFF64748B)), // Increased icon size
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editProjects(projectsId);
                        } else if (value == 'delete') {
                          ProjectDeleteHandler.deleteProject(context, projectsId, projectsName);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20.sp, color: const Color(0xFFF59E0B)), // Increased icon size
                              SizedBox(width: 8.w),
                              Text('Edit', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF334155))), // Increased font size
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20.sp, color: const Color(0xFFF43F5E)), // Increased icon size
                              SizedBox(width: 8.w),
                              Text('Delete', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF334155))), // Increased font size
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h), // Slightly increased spacing
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16.sp, color: const Color(0xFF64748B)), // Increased icon size
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Created by: $createdBy',
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)), // Increased from 12.sp
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h), // Slightly increased spacing
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, size: 16.sp, color: const Color(0xFF64748B)), // Increased icon size
                    SizedBox(width: 4.w),
                    Text(
                      'Created: ${_formatDateTime(createdAt)}',
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)), // Increased from 12.sp
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

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Text(
          'Projects',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)), // Increased from 18.sp
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: 26.sp, color: const Color(0xFF334155)), // Increased from 24.sp
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
          context.goNamed(RouteNames.projectsadd);
        },
        child: Row(
          children: [
            Icon(Icons.add, size: 22.sp, color: const Color(0xFF3B82F6)), // Increased from 20.sp
            SizedBox(width: 4.w),
            Text(
              'Add Project',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6)), // Increased from 16.sp
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.local_florist_outlined, size: 72.sp, color: const Color(0xFF3B82F6)), // Increased from 64.sp
        SizedBox(height: 16.h),
        Text(
          'No Projects Found',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)), // Increased from 18.sp
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap the button below to add your first Project!',
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF64748B)), // Increased from 14.sp
        ),
        SizedBox(height: 16.h),
        AddButton(
          text: 'Add Project',
          icon: Icons.add,
          route: RouteNames.projectsadd,
        ),
      ],
    );
  }

  Widget _buildErrorState(ProjectProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 72.sp, color: const Color(0xFFF43F5E)), // Increased from 64.sp
        SizedBox(height: 16.h),
        Text(
          'Error Loading Projects',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)), // Increased from 18.sp
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF64748B)), // Increased from 14.sp
          ),
        ),
        SizedBox(height: 16.h),
        RefreshButton(
          text: 'Retry',
          icon: Icons.refresh,
          onTap: () {
            provider.clearError();
            provider.loadAllProjects(refresh: true);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBars(
        title: _buildLogoAndTitle(),
        leading: _buildBackButton(),
        action: [_buildActionButtons()],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.projects.isEmpty && provider.error == null) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => buildShimmerCard(),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadAllProjects(refresh: true);
            },
            color: const Color(0xFF3B82F6),
            backgroundColor: Colors.white,
            child: provider.projects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 80.h),
                    itemCount: provider.projects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectsCard(provider.projects[index]);
                    },
                  ),
          );
        },
      ),
    );
  }
}