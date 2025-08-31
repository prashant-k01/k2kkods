import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide ScreenUtil;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:k2k/Iron_smith/master_data/shapes/model/shape_model.dart';
import 'package:k2k/Iron_smith/master_data/shapes/provider/shape_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/refresh.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:k2k/utils/theme.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:provider/provider.dart';

class ShapeDetailsScreen extends StatefulWidget {
  final String shapeId;

  const ShapeDetailsScreen({super.key, required this.shapeId});

  @override
  State<ShapeDetailsScreen> createState() => _ShapeDetailsScreenState();
}

class _ShapeDetailsScreenState extends State<ShapeDetailsScreen> {
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
          provider.fetchShapeById(context, widget.shapeId);
        }
      });
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy HH:mm:ss').format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  String _getCreatedBy(CreatedBy? createdBy) {
    return createdBy != null
        ? '${createdBy.username} (${createdBy.email ?? 'No email'})'
        : 'Unknown';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeCard(Shape shape, ShapesProvider provider) {
    final dimension = shape.dimension?.dimensionName ?? 'F';
    final description = shape.description ?? 'JKL';
    final shapeCode = shape.shapeCode ?? 'P4';
    final imageFile =
        shape.file?.fileName ?? 'TESTING.jpg'; // Use fetched file_name
    final createdBy = _getCreatedBy(shape.createdBy);
    final createdAt = _formatDateTime(shape.createdAt);
    final updatedAt = _formatDateTime(shape.updatedAt);

    return CustomCard(
      title: description,
      titleColor: AppTheme.darkGray,
      titleStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      leading: Icon(
        Icons.widgets_outlined,
        size: 36.sp,
        color: AppTheme.ironSmithSecondary,
      ),
      headerGradient: AppTheme.ironSmithGradient,
      borderRadius: 12,
      backgroundColor: AppColors.cardBackground,
      borderColor: Colors.transparent,
      borderWidth: 0,
      elevation: 6,
      shadowColor: const Color(0xFF6B21A8).withOpacity(0.3),
      shadowSpread: 8,
      bodyItems: [
        _buildInfoRow('Dimension', dimension),
        _buildInfoRow('Shape Code', shapeCode),
        _buildInfoRow('Image File', imageFile),
        _buildInfoRow('Created By', createdBy),
        _buildInfoRow('Created At', createdAt),
        _buildInfoRow('Updated At', updatedAt),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.allshapes);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBars(
          title: TitleText(title: 'Shape Details'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.allshapes),
          ),
        ),
        body: SafeArea(
          child: Consumer<ShapesProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: GradientLoader());
              }
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
                        'Error Loading Shape',
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
                          provider.fetchShapeById(context, widget.shapeId);
                        },
                      ),
                    ],
                  ),
                );
              }
              final shape = provider.shapes.firstWhere(
                (shape) => shape.id == widget.shapeId,
                orElse: () => Shape(
                  id: widget.shapeId,
                  dimension: Dimension(dimensionName: 'F'),
                  description: 'JKL',
                  shapeCode: 'P4',
                  file: FileClass(fileName: 'TESTING.jpg'), // Default file
                  createdBy: CreatedBy(
                    username: 'admin',
                    email: 'admin@gmail.com',
                  ),
                  createdAt: '2025-08-18T16:00:41Z',
                  updatedAt: '2025-08-18T16:00:41Z',
                ),
              );
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildShapeCard(shape, provider)],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
