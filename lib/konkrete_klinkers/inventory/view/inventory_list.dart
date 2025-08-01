import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/konkrete_klinkers/inventory/model/inventory.dart';
import 'package:k2k/konkrete_klinkers/inventory/provider/inventory_provider.dart';
import 'package:k2k/konkrete_klinkers/inventory/view/inventory_detailscreen.dart';
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
                        materialCode,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: status.toLowerCase() == 'active'
                            ? Colors.green.shade50
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: status.toLowerCase() == 'active'
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Eye icon button
                    IconButton(
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.blue.shade400,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        // Navigate to the detail screen with product_id
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InventoryDetailScreen(
                              productId: item.productId,
                            ),
                          ),
                        );
                      },
                      tooltip: 'View Details',
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                Row(
                  children: [
                    Text(
                      "Description:",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18.sp,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Balance: $balanceQuantity',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 18.sp,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'UOM: $uom',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18.sp,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 24.sp,
        color: const Color(0xFF334155),
      ),
      onPressed: () {
        Navigator.of(context).maybePop();
      },
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
        action: [],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
    );
  }
}
