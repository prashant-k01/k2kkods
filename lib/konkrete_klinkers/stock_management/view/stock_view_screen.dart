import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:k2k/konkrete_klinkers/stock_management/provider/stock_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/utils/theme.dart';

class StockDetailsScreen extends StatefulWidget {
  final String id;

  const StockDetailsScreen({super.key, required this.id});

  @override
  _StockDetailsScreenState createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StockProvider>(context, listen: false);
      print('Initiating getStockById with id: ${widget.id}');
      provider.getStockById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.stockmanagement);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBars(
          title: _buildLogoAndTitle(),
          leading: _buildBackButton(),
        ),
        body: SafeArea(
          child: Consumer<StockProvider>(
            builder: (context, provider, child) {
              if (provider.isStockByIdLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                    strokeWidth: 4.0,
                  ),
                );
              }
              if (provider.stockByIdError != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60.sp,
                        color: AppTheme.errorColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error Loading Data',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        provider.stockByIdError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          final provider = Provider.of<StockProvider>(
                            context,
                            listen: false,
                          );
                          print('Retrying getStockById with id: ${widget.id}');
                          provider.getStockById(widget.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
                      ),
                    ],
                  ),
                );
              }
              final stockById = provider.stockById;
              print('StockById state: ${stockById.toString}');
              if (stockById == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 60.sp,
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Data Available',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Please check the transfer ID or try again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          final provider = Provider.of<StockProvider>(
                            context,
                            listen: false,
                          );
                          print(
                            'Refreshing getStockById with id: ${widget.id}',
                          );
                          provider.getStockById(widget.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Refresh',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final from = stockById.from;
              final to = stockById.to;

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard(
                      headerColor: Colors.yellow[50]!,
                      title: 'Client Details',
                      icon: IconContainer(
                        icon: Icons.person,
                        gradientColors: [
                          Colors.orange.shade100,
                          Colors.yellow.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.orange.shade700,
                      ),
                      iconColor: Colors.orange,
                      details: [
                        DetailItem(
                          label: 'Client Name',
                          value: from?.client ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Project Name',
                          value: from?.project ?? 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerColor: Colors.blue[50]!,
                      title: 'Work Order Details',
                      icon: IconContainer(
                        icon: Icons.description,
                        gradientColors: [
                          Colors.blue.shade100,
                          Colors.cyan.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.blue.shade700,
                      ),
                      iconColor: Colors.blue,
                      details: [
                        DetailItem(
                          label: 'Work Order ID',
                          value: from?.workOrderId ?? 'N/A',
                        ),
                        DetailItem(label: 'Created By', value: 'admin'),
                        DetailItem(
                          label: 'Timestamp',
                          value: from?.createdAt != null
                              ? DateFormat(
                                  'MM/dd/yyyy, hh:mm:ss a',
                                ).format(from!.createdAt!)
                              : 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerColor: Colors.pink[50]!,
                      title: 'Transferred From',
                      icon: IconContainer(
                        icon: Icons.trending_up,
                        gradientColors: [
                          Colors.red.shade100,
                          Colors.pink.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.red.shade700,
                      ),
                      iconColor: Colors.red,
                      details: [
                        DetailItem(
                          label: 'Product',
                          value: from?.productName ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Work Order ID',
                          value: from?.workOrderId ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Client Name',
                          value: from?.client ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Project Name',
                          value: from?.project ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Transferred Qty',
                          value: '${from?.quantityTransferred ?? 0}',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerColor: Colors.green[50]!,
                      title: 'Transferred To',
                      icon: IconContainer(
                        icon: Icons.trending_down,
                        gradientColors: [
                          Colors.green.shade100,
                          Colors.teal.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.green.shade700,
                      ),
                      iconColor: Colors.green,
                      details: [
                        DetailItem(
                          label: 'Product',
                          value: to?.productName ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Work Order ID',
                          value: to?.workOrderId ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Client Name',
                          value: to?.client ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Project Name',
                          value: to?.project ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Received Qty',
                          value: '${to?.quantityTransferred ?? 0}',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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
          'Stock Transfer Details',
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
        context.go(RouteNames.stockmanagement);
      },
    );
  }

  Widget _buildDetailCard({
    required Color headerColor,
    required String title,
    required IconContainer icon,
    required Color iconColor,
    required List<DetailItem> details,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: ListTile(
              leading: icon,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              subtitle: Text(
                title == 'Transferred From'
                    ? 'Source  transfer information'
                    : ' Destination transfer information',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.mediumGray),
              ),

              contentPadding: EdgeInsets.zero,
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 12.h),
                ...details.map(
                  (detail) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${detail.label}:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            detail.value,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailItem {
  final String label;
  final String value;

  DetailItem({required this.label, required this.value});
}

class IconContainer extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double size;
  final double borderRadius;
  final Color iconColor;

  const IconContainer({
    Key? key,
    required this.icon,
    this.gradientColors = const [Colors.orange, Colors.pink],
    this.size = 48,
    this.borderRadius = 12,
    this.iconColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size, // Square shape
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: size * 0.5, // Slightly smaller icon for better proportion
      ),
    );
  }
}
