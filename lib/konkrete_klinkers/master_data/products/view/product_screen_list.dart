import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/gradient_icon_button.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/model/product.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/provider/product_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/view/product_delete_screen.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ProductsListView extends StatefulWidget {
  const ProductsListView({super.key});

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
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
        final provider = context.read<ProductProvider>();
        if (provider.products.isEmpty && provider.error == null) {
          provider.loadAllProducts();
        }
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !context.read<ProductProvider>().isLoading &&
          context.read<ProductProvider>().hasMore &&
          !_isScrollLoading) {
        print('Triggering load more products...');
        _isScrollLoading = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await context.read<ProductProvider>().loadAllProducts();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load products: $e')),
            );
          } finally {
            _isScrollLoading = false;
          }
        });
      }
    });
  }

  void _editProduct(String? productId) {
    if (productId != null) {
      context.goNamed(
        RouteNames.productedit,
        pathParameters: {'productId': productId},
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildProductCard(ProductModel product) {
    final productId = product.id;
    final materialCode = product.materialCode.isNotEmpty
        ? product.materialCode
        : 'Unknown Product';
    final plantName = product.plant.plantName.isNotEmpty
        ? product.plant.plantName
        : 'N/A';
    final createdBy = product.createdBy.username.isNotEmpty
        ? product.createdBy.username
        : 'Unknown';
    final createdAt = product.createdAt;

    return CustomCard(
      title: materialCode,
      titleColor: AppColors.background,
      leading: Icon(
        Icons.production_quantity_limits,
        size: 20.sp,
        color: AppColors.background,
      ),

      menuItems: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20.sp, color: Color(0xFFF59E0B)),
              SizedBox(width: 8.w),
              Text(
                'Edit',
                style: TextStyle(fontSize: 16.sp, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20.sp, color: Color(0xFFF43F5E)),
              SizedBox(width: 8.w),
              Text(
                'Delete',
                style: TextStyle(fontSize: 16.sp, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
      ],
      onMenuSelected: (value) {
        if (value == 'edit') {
          _editProduct(productId);
        } else if (value == 'delete') {
          ProductDeleteHandler.deleteProduct(context, productId, plantName);
        }
      },
      bodyItems: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Plant Name: ',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: plantName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
            Expanded(
              child: Text(
                'Created by: $createdBy',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
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
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ],
      headerGradient: AppTheme.cardGradientList,
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
            'No Products Found',
            style: TextStyle(
              fontSize: 20.sp, // Increased from 18.sp
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first Product!',
            style: TextStyle(
              fontSize: 16.sp, // Increased from 14.sp
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProductProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
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
              'Error Loading Products',
              style: TextStyle(
                fontSize: 20.sp, // Increased from 18.sp
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unable to load products at this time. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp, // Increased from 14.sp
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            RefreshButton(
              text: 'Retry',
              icon: Icons.refresh,
              onTap: () {
                provider.clearError();
                provider.loadAllProducts(refresh: true);
              },
            ),
          ],
        ),
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
          context.go(RouteNames.homeScreen);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: TitleText(title: 'Products'),
          leading: CustomBackButton(
            onPressed: () {
              context.go(RouteNames.homeScreen);
            },
          ),
        ),
        floatingActionButton: GradientIconTextButton(
          onPressed: () => context.goNamed(RouteNames.productsadd),
          label: 'Add Product',
          icon: Icons.add,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        ),
        body: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            // Show shimmer loading when initially loading
            if (provider.isLoading &&
                provider.products.isEmpty &&
                provider.error == null) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => buildShimmerCard(),
              );
            }

            // Show error state
            if (provider.error != null) {
              return _buildErrorState(provider);
            }

            // Show empty state
            if (provider.products.isEmpty && !provider.isLoading) {
              return _buildEmptyState();
            }

            // Show products list
            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadAllProducts(refresh: true);
              },
              color: const Color(0xFF3B82F6),
              backgroundColor: Colors.white,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    provider.products.length +
                    (provider.hasMore && provider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end
                  if (index == provider.products.length &&
                      provider.hasMore &&
                      provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: GradientLoader(),
                      ),
                    );
                  }

                  // Build product card
                  return _buildProductCard(provider.products[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
