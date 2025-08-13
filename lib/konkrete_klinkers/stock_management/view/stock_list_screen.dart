import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/add_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/konkrete_klinkers/stock_management/model/stock.dart';
import 'package:k2k/konkrete_klinkers/stock_management/provider/stock_provider.dart';
import 'package:k2k/konkrete_klinkers/stock_management/view/stock_view_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class StockManagementListView extends StatefulWidget {
  const StockManagementListView({super.key});

  @override
  State<StockManagementListView> createState() =>
      _StockManagementListViewState();
}

class _StockManagementListViewState extends State<StockManagementListView> {
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
          final provider = context.read<StockProvider>();
          if (provider.transfers.isEmpty && provider.error == null) {
            provider.loadStockManagements();
          }
        }
      });
    }
  }

  void _editTransfer(String? transferId) {
    if (transferId != null) {
      context.goNamed(
        'StockManagementEdit',
        pathParameters: {'transferId': transferId},
      );
    }
  }

  Widget _buildStatusContainer(String status) {
    Color backgroundColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = const Color(0xFFE7F5EF);
        textColor = const Color(0xFF10B981);
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFF59E0B);
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFFE5E7);
        textColor = const Color(0xFFF43F5E);
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTransferCard(StockManagement transfer) {
    final transferId = transfer.id;
    final fromWorkOrderId = transfer.fromWorkOrderId;
    final toWorkOrderId = transfer.toWorkOrderId;
    final quantityTransferred = transfer.quantityTransferred.toString();
    final transferredBy = transfer.transferredBy;
    final transferDate = transfer.transferDate.toString().split('.')[0];
    final isBufferTransfer = transfer.isBufferTransfer ? 'Yes' : 'No';
    final status = transfer.status;
    final createdAt = transfer.createdAt.toString().split('.')[0];
    final productName = transfer.productName;

    return CustomCard(
      title: productName,

      leading: IconContainer(
        icon: Icons.swap_horiz_outlined,
        gradientColors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
        size: 48.sp,
        borderRadius: 12.r,
        iconColor: AppTheme.primaryPurple,
      ),
      onTap: () {
        context.goNamed(
          RouteNames.stockmanagementview,
          pathParameters: {'id': transferId},
        );
      },
      headerGradient: AppTheme.cardGradientList,
      borderRadius: 12,
      backgroundColor: Colors.white,
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      onMenuSelected: (value) {
        if (value == 'edit') {
          _editTransfer(transferId);
        } else if (value == 'delete') {
          // Implement delete handler
          // StockManagementDeleteHandler.deleteTransfer(context, transferId, productName);
        }
      },
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
      bodyItems: [
        _buildStatusContainer(status),
        SizedBox(height: 8.h),
        _infoRow(Icons.arrow_forward, 'From Work Order', fromWorkOrderId),
        SizedBox(height: 6.h),
        _infoRow(Icons.arrow_back, 'To Work Order', toWorkOrderId),
        SizedBox(height: 6.h),
        _infoRow(
          Icons.inventory_outlined,
          'Quantity Transferred',
          quantityTransferred,
        ),
        SizedBox(height: 6.h),
        _infoRow(Icons.person_outline, 'Transferred By', transferredBy),
        SizedBox(height: 6.h),
        _infoRow(Icons.calendar_today_outlined, 'Transfer Date', transferDate),
        SizedBox(height: 6.h),
        _infoRow(Icons.storage_outlined, 'Buffer Transfer', isBufferTransfer),
        SizedBox(height: 6.h),
        _infoRow(Icons.access_time_outlined, 'Created', createdAt),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppTheme.primaryPurple),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600, // label in black
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black54, // value in grey
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Text(
          'Stock Transfers',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 24.sp,
        color: const Color(0xFF334155),
      ),
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
          context.goNamed(RouteNames.stockmanagementAdd);
        },
        child: Row(
          children: [
            Icon(Icons.add, size: 20.sp, color: const Color(0xFF3B82F6)),
            SizedBox(width: 4.w),
            Text(
              'Add Transfer',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
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
            Icons.move_to_inbox_outlined,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Stock Transfers Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first stock transfer!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Stock',
            icon: Icons.add,
            route: RouteNames.stockmanagementAdd,
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
          context.go(RouteNames.homeScreen); // Adjust route as needed
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: _buildLogoAndTitle(),
          leading: _buildBackButton(),
          action: [_buildActionButtons()],
        ),
        body: Consumer<StockProvider>(
          builder: (context, provider, child) {
            if (provider.error != null && provider.transfers.isEmpty) {
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
                      'Error Loading Stock Transfers',
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
                        provider.loadStockManagements(refresh: true);
                      },
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<StockProvider>().loadStockManagements(
                  refresh: true,
                );
              },
              color: const Color(0xFF3B82F6),
              backgroundColor: Colors.white,
              child: provider.isLoading && provider.transfers.isEmpty
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => buildShimmerCard(),
                    )
                  : provider.transfers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 80.h),
                      itemCount:
                          provider.transfers.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.transfers.length &&
                            provider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildTransferCard(provider.transfers[index]);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
