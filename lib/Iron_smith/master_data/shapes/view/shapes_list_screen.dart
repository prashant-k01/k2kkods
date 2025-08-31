import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:k2k/Iron_smith/master_data/shapes/model/shape_model.dart';
import 'package:k2k/Iron_smith/master_data/shapes/provider/shape_provider.dart';
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/master_data/shapes/view/shape_delete_screen.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/popup_menu_item.dart';
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
import 'package:k2k/common/widgets/custom_card.dart'; // Add this import

class ShapesListScreen extends StatefulWidget {
  const ShapesListScreen({super.key});

  @override
  State<ShapesListScreen> createState() => _ShapesListScreenState();
}

class _ShapesListScreenState extends State<ShapesListScreen> {
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
          final provider = context.read<ShapesProvider>();
          if (provider.shapes.isEmpty && provider.error == null) {
            provider.fetchShapes(refresh: true);
          }
        }
      });
    }
  }

  void _editShape(BuildContext context, String? shapeId) {
    if (shapeId == null || shapeId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid shape ID')));
      return;
    }
    context.goNamed(
      RouteNames.editshapes,
      pathParameters: {'shapeId': shapeId},
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  String _getCreatedBy(CreatedBy? createdBy) {
    return createdBy?.username ?? 'Unknown';
  }

  Widget _buildShapeCard(Shape shape) {
    final dimension = shape.dimension?.dimensionName ?? '-';
    final description = shape.description ?? '-';
    final shapeCode = shape.shapeCode ?? '-';
    final createdBy = _getCreatedBy(shape.createdBy);
    final createdAt = _formatDateTime(shape.createdAt);
    final menuItems = <PopupMenuEntry<String>>[
      CustomPopupItem(
        icon: Icons.edit_outlined,
        label: "Edit",
        iconColor: AppTheme.ironSmithSecondary,
        value: "edit",
        onTap: () => context.go(RouteNames.editshapes),
      ),
      CustomPopupItem(
        icon: Icons.delete_outline,
        label: "Delete",
        iconColor: Colors.red,
        value: "delete",
        onTap: () {
          ShapeDeleteHandler.confirmDelete(
            context,
            shapeId: shape.id,
            shapeName: shape.shapeCode,
          );
        },
      ),
    ];

    return CustomCard(
      title: description,
      titleColor: const Color(0xFF334155),
      leading: Icon(
        Icons.widgets_outlined,
        size: 20.sp,
        color: AppTheme.ironSmithSecondary,
      ),
      headerGradient: AppTheme.ironSmithGradient,
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      borderRadius: 12,
      backgroundColor: AppColors.cardBackground,
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1,
      elevation: 0,
      menuItems: menuItems,
      onTap: () => context.go('${RouteNames.viewshapes}/${shape.id}'),
      onMenuSelected: (value) {
        if (value == 'edit') {
          context.go(
            '${RouteNames.editshapes}/${shape.id}', // pass the shapeId
          );
        } else if (value == 'delete') {}
      },
      bodyItems: [
        _buildInfoRow('Dimension', dimension),
        _buildInfoRow('Shape Code', shapeCode),
        _buildInfoRow('Created By', createdBy),
        _buildInfoRow('Created At', createdAt),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.ironSmithSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 64.sp,
            color: AppTheme.ironSmithPrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Shapes Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first shape!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 16.h),
          AddButton(
            text: 'Add Shape',
            icon: Icons.add,
            route: RouteNames.addshapes,
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
        if (!didPop) context.go(RouteNames.homeScreen);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBars(
          title: TitleText(title: 'Shapes'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.homeScreen),
          ),
        ),
        floatingActionButton: GradientIconTextButton(
          gradientColors: [Color(0xFFBBDEFB), Color(0xFFB2EBF2)],
          label: 'Create Shapes',
          icon: Icons.add,
          onPressed: () => context.go(RouteNames.addshapes),
        ),
        body: SafeArea(
          child: Consumer<ShapesProvider>(
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
                        'Error Loading Shapes',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      RefreshButton(
                        text: 'Retry',
                        icon: Icons.refresh,
                        onTap: () {
                          provider.clearError();
                          provider.fetchShapes(refresh: true);
                        },
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => provider.fetchShapes(refresh: true),
                color: AppTheme.ironSmithPrimary,
                backgroundColor: Colors.white,
                child: provider.isLoading && provider.shapes.isEmpty
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (_, __) => buildShimmerCard(),
                      )
                    : provider.shapes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16.h),
                        itemCount: provider.shapes.length,
                        itemBuilder: (_, index) =>
                            _buildShapeCard(provider.shapes[index]),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
