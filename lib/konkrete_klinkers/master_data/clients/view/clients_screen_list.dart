import 'package:flutter/material.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/provider/clients_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;

class ClientsListView extends StatefulWidget {
  const ClientsListView({super.key});

  @override
  State<ClientsListView> createState() => _ClientsListViewState();
}

class _ClientsListViewState extends State<ClientsListView> {
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
          final provider = context.read<ClientsProvider>();
          if (provider.clients.isEmpty && provider.error == null) {
            provider.loadAllClients();
          }
        }
      });
    }
  }

  void _editClient(String? clientId) {
    if (clientId != null) {
      context.goNamed(
        RouteNames.clientsedit,
        pathParameters: {'clientId': clientId},
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
    return Consumer<ClientsProvider>(
      builder: (context, provider, child) {
        if (provider.totalItems == 0) return SizedBox.shrink();

        if (provider.showAll) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              'Showing all ${provider.totalItems} clients',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final startItem = ((provider.currentPage - 1) * provider.limit) + 1;
        final endItem = (startItem + provider.clients.length - 1).clamp(
          1,
          provider.totalItems,
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $startItem-$endItem of ${provider.totalItems} clients',
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

  Widget _buildClientCard(dynamic Client) {
    final clientData = Client is Map<String, dynamic>
        ? Client
        : Client.toJson();
    final clientId = clientData['_id'] ?? clientData['id'] ?? '';
    final name = clientData['name'] ?? clientData['name'] ?? 'Unknown Client';
    final address = clientData['address'] ?? clientData['address'] ?? 'N/A';
    final createdBy = _getCreatedBy(
      clientData['created_by'] ?? clientData['createdBy'],
    );
    final createdAt = clientData['createdAt'] != null
        ? DateTime.tryParse(clientData['createdAt'].toString()) ??
              DateTime.now()
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
                            name,
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
                              address,
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
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 24.sp,
                        color: const Color(0xFF64748B),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editClient(clientId);
                        } else if (value == 'delete') {
                          ClientDeleteHandler.deleteClient(
                            context,
                            clientId,
                            name,
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
            'No clients Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by adding a new Client!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Client',
            icon: Icons.add,
            route: RouteNames.clientsadd,
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
          'Machine Creation',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          Consumer<ClientsProvider>(
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
      body: Consumer<ClientsProvider>(
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
                    'Error Loading clients',
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
                      provider.loadAllClients(refresh: true);
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
                    await provider.loadAllClients(refresh: true);
                  },
                  color: const Color(0xFF3B82F6),
                  backgroundColor: Colors.white,
                  child: provider.isLoading && provider.clients.isEmpty
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) => buildShimmerCard(),
                        )
                      : provider.clients.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: provider.clients.length,
                          itemBuilder: (context, index) {
                            return _buildClientCard(provider.clients[index]);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AddButton(
        text: 'Add Client',
        icon: Icons.add,
        route: RouteNames.clientsadd,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
