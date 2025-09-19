import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/konkrete_klinkers/inventory/model/inventory.dart';
import 'package:k2k/konkrete_klinkers/inventory/provider/inventory_provider.dart';
import 'package:k2k/konkrete_klinkers/inventory/view/inventory_detailscreen.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryProvider>();
      provider.fetchInventory();
    });
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final materialCode = item.materialCode.isNotEmpty
        ? item.materialCode
        : 'N/A';
    final description = item.description.isNotEmpty
        ? item.description
        : 'No Description';
    final balanceQuantity = item.balanceQuantity;
    final uom = item.uom.isNotEmpty ? item.uom : '';
    final status = item.status.isNotEmpty ? item.status : 'Unknown';
    final isActive = status.toLowerCase() == 'active';

    return CustomCard(
      title: materialCode,
      titleColor: AppColors.background,
      headerGradient: AppTheme.cardGradientList,
      leading: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
          ),
        ),
      ),
      onTap: () {
        context.goNamed(RouteNames.inventorydetail, extra: item.productId);
      },
      menuItems: [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.remove_red_eye_outlined,
                size: 16.sp,
                color: Colors.blue.shade400,
              ),
              SizedBox(width: 8.w),
              Text('View Details'),
            ],
          ),
        ),
      ],
      onMenuSelected: (value) {
        if (value == 'view') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InventoryDetailScreen(productId: item.productId),
            ),
          );
        }
      },
      bodyItems: [
        Row(
          children: [
            Text(
              "Description:",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(Icons.inventory_2_outlined, 'Balance: $balanceQuantity'),
        SizedBox(height: 6.h),
        _buildInfoRow(Icons.straighten, 'UOM: $uom'),
        SizedBox(height: 6.h),
        _buildInfoRow(Icons.info_outline, 'Status: $status'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
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
            Icons.inventory_2_outlined,
            size: 64.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Inventory Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please add inventory items to get started!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Text(
          'Inventory Management',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
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
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Inventory Management'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.homeScreen);
              },
            ),
          ),
          body: Consumer<InventoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: GradientLoader());
              }

              if (provider.error != null) {
                return Center(
                  child: Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final inventory = provider.inventoryList;

              if (inventory.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.only(bottom: 80.h),
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return _buildInventoryCard(item);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
