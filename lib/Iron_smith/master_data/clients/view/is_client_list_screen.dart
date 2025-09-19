import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/master_data/clients/model/is_client_model.dart';
import 'package:k2k/Iron_smith/master_data/clients/provider/is_client_provider.dart';
import 'package:k2k/Iron_smith/master_data/clients/view/is_client_delete_screen.dart';
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

class IsClientsListScreen extends StatefulWidget {
  const IsClientsListScreen({super.key});

  @override
  State<IsClientsListScreen> createState() => _IsClientsListScreenState();
}

class _IsClientsListScreenState extends State<IsClientsListScreen> {
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
          final provider = context.read<IsClientProvider>();
          if (provider.clients.isEmpty && provider.error == null) {
            provider.fetchClients(refresh: true);
          }
        }
      });
    }
  }

  void _editClient(String? clientId) {
    if (clientId != null) {
      context.goNamed(
        RouteNames.isClientEdit,
        pathParameters: {'clientId': clientId},
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

  String _getCreatedBy(CreatedBy? createdBy) {
    return createdBy?.username ?? 'Unknown';
  }

  Widget _buildClientCard(IsClient client) {
    final clientId = client.id;
    final name = client.name ?? "Unnamed";
    final address = client.address ?? "No Address";
    final createdBy = _getCreatedBy(client.createdBy);
    final createdAt = client.createdAt;

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
              // Header with Name + Menu
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
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          _editClient(clientId);
                        } else if (value == 'delete') {
                          ClientDeleteHandler.confirmDelete(
                            context,
                            clientId: clientId,
                            clientName: name,
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

              // Body with Address, CreatedBy, CreatedAt
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
                        "Address: $address",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
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
                            'Created At: ${_formatDateTime(client.createdAt)}',
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
            Icons.people_outline,
            size: 64.sp,
            color: AppTheme.ironSmithPrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Clients Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first client!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Client',
            icon: Icons.add,
            route: RouteNames.isClientAdd,
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
          title: TitleText(title: 'Clients'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.homeScreen),
          ),
        ),
        floatingActionButton: GradientIconTextButton(
          gradientColors: [Color(0xFFBBDEFB), Color(0xFFB2EBF2)],
          label: 'Create Client',
          icon: Icons.add,
          onPressed: () => context.go(RouteNames.isClientAdd),
        ),
        body: Consumer<IsClientProvider>(
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
                      'Error Loading Clients',
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
                        provider.fetchClients(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchClients(refresh: true);
                },
                color: AppTheme.ironSmithPrimary,
                backgroundColor: Colors.white,
                child: provider.isLoading && provider.clients.isEmpty
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => ShimmerCard(),
                      )
                    : provider.clients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16.h),
                        itemCount: provider.clients.length,
                        itemBuilder: (context, index) {
                          return _buildClientCard(provider.clients[index]);
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
