import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/pdf_screen.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch_detail.dart';
import 'package:k2k/konkrete_klinkers/dispatch/provider/dispatch_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DispatchViewScreen extends StatefulWidget {
  final String dispatchId;

  const DispatchViewScreen({super.key, required this.dispatchId});

  @override
  State<DispatchViewScreen> createState() => _DispatchViewScreenState();
}

class _DispatchViewScreenState extends State<DispatchViewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DispatchProvider>().fetchDispatchById(widget.dispatchId);
    });
  }

  String _formatDateTime(dynamic dateTimeInput) {
    if (dateTimeInput == null) return 'N/A';
    try {
      DateTime dateTime;
      if (dateTimeInput is String) {
        dateTime = DateTime.parse(dateTimeInput);
      } else if (dateTimeInput is DateTime) {
        dateTime = dateTimeInput;
      } else {
        return 'N/A';
      }
      return DateFormat('MMMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeInput.toString();
    }
  }

  Widget _buildDetailCard({
    required Gradient headerGradient,
    required String title,
    required IconContainer icon,
    required Color iconColor,
    required List<DetailItem> details,
    Widget? child,
  }) {
    return CustomCard(
      margin: EdgeInsets.zero,
      title: title,
      titleColor: iconColor,
      subtitleColor: AppTheme.mediumGray,
      leading: icon,
      backgroundColor: AppColors.cardBackground,
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1,
      borderRadius: 12,
      elevation: 0,
      headerGradient: headerGradient,
      bodyItems: child != null
          ? [child]
          : [
              SizedBox(height: 8.h),
              ...details.map(
                (detail) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${detail.label}:',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          detail.value,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
    );
  }

  Widget _buildDispatchProductDetail(
    DispatchProduct product,
    DispatchData dispatch,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product.productName ?? 'N/A',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8.h),

          // UOM List
          _buildProductField(
            'UOM',
            product.uoms != null ? product.uoms!.join(' / ') : 'N/A',
          ),

          // Batch ID
          _buildProductField('Batch ID', product.batchId ?? 'N/A'),

          // Dispatch Quantity
          _buildProductField(
            'Dispatch Quantity',
            product.dispatchQuantity?.toString() ?? '0',
          ),

          // Dispatch Date (from dispatch object)
          _buildProductField('Date', _formatDateTime(dispatch.dispatchDate)),

          // Vehicle Number (from dispatch object)
          _buildProductField('Vehicle No', dispatch.vehicleNumber ?? 'N/A'),

          // Invoice / STO
          if (dispatch.invoiceOrSto != null)
            _buildProductField('Invoice / STO', dispatch.invoiceOrSto!),

          // Invoice Files (clickable if any)
          if (dispatch.invoiceFiles != null &&
              dispatch.invoiceFiles!.isNotEmpty)
            _buildInvoiceFiles(dispatch.invoiceFiles),
        ],
      ),
    );
  }

  Widget _buildInvoiceFiles(List<String>? invoiceFiles) {
    if (invoiceFiles == null || invoiceFiles.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: invoiceFiles.map((fileUrl) {
        final lowerUrl = fileUrl.toLowerCase();
        final isImage =
            lowerUrl.endsWith('.jpg') ||
            lowerUrl.endsWith('.jpeg') ||
            lowerUrl.endsWith('.png') ||
            lowerUrl.endsWith('.gif');
        final isPdf = lowerUrl.endsWith('.pdf');

        IconData icon;
        if (isImage) {
          icon = Icons.image;
        } else if (isPdf) {
          icon = Icons.picture_as_pdf;
        } else {
          icon = Icons.insert_drive_file;
        }

        return GestureDetector(
          onTap: () {
            if (isImage) {
              _showImageModal(fileUrl);
            } else if (isPdf) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewerScreen(fileUrl: fileUrl),
                ),
              );
            } else {
              // Open other file types in browser or download
              launchUrl(Uri.parse(fileUrl));
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(icon, size: 18.0, color: Colors.blue),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    fileUrl.split('/').last, // show file name only
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showImageModal(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(12.w),
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 200.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.mediumGray),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DispatchProvider>(
      builder: (context, provider, child) {
        final dispatch = provider.selectedDispatch;
        final error = provider.error;

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (error != null) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (!didPop) {
                context.go(RouteNames.dispatch);
              }
            },
            child: Scaffold(
              appBar: AppBars(
                title: TitleText(title: 'Dispatch Details'),
                leading: CustomBackButton(
                  onPressed: () {
                    context.go(RouteNames.dispatch);
                  },
                ),
              ),
              body: Center(child: Text(error)),
            ),
          );
        }

        if (dispatch == null) {
          return Scaffold(
            appBar: AppBars(
              title: TitleText(title: 'Dispatch Details'),
              leading: CustomBackButton(
                onPressed: () {
                  context.go(RouteNames.dispatch);
                },
              ),
            ),
            body: const Center(child: Text("No Dispatch found")),
          );
        }

        return Container(
          decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: Scaffold(
            backgroundColor: AppColors.transparent,
            appBar: AppBars(
              title: TitleText(title: 'Dispatch Details'),
              leading: CustomBackButton(
                onPressed: () {
                  context.go(RouteNames.dispatch);
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Card
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientBlue,
                      title: 'Client Details',
                      icon: IconContainer(
                        icon: Icons.assignment,
                        gradientColors: [
                          Colors.blue.shade100,
                          Colors.cyan.shade50,
                        ],
                        size: 40.w,
                        borderRadius: 8.r,
                        iconColor: Colors.blue.shade700,
                      ),
                      iconColor: Colors.blue,
                      details: [
                        DetailItem(
                          label: 'Client Name',
                          value: dispatch.clientProject?.clientName ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Project Name',
                          value: dispatch.clientProject?.projectName ?? 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Work Order Card
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientGreen,
                      title: 'Work Order Details',
                      icon: IconContainer(
                        icon: Icons.date_range,
                        gradientColors: [
                          Colors.green.shade100,
                          Colors.teal.shade50,
                        ],
                        size: 40.w,
                        borderRadius: 8.r,
                        iconColor: Colors.green.shade700,
                      ),
                      iconColor: Colors.green,
                      details: [
                        DetailItem(
                          label: 'Work Order ID',
                          value: dispatch.workOrderName ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Job Order ID',
                          value: dispatch.jobOrderName ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Created By',
                          value: dispatch.createdInfo?.createdBy ?? 'N/A',
                        ),
                        DetailItem(
                          label: 'Timestamp',
                          value: _formatDateTime(
                            dispatch.createdInfo?.createdAt,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Products / Dispatch Card
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientRed,
                      title: 'Products / Dispatch Information',
                      icon: IconContainer(
                        icon: Icons.inventory,
                        gradientColors: [
                          Colors.pink.shade100,
                          Colors.red.shade50,
                        ],
                        size: 40.w,
                        borderRadius: 8.r,
                        iconColor: Colors.pink.shade700,
                      ),
                      iconColor: Colors.pink,
                      details: [],
                      child: Column(
                        children:
                            dispatch.products != null &&
                                dispatch.products!.isNotEmpty
                            ? dispatch.products!
                                  .map<Widget>(
                                    (product) => _buildDispatchProductDetail(
                                      product,
                                      dispatch,
                                    ),
                                  )
                                  .toList()
                            : [const Text("No products available")],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
    super.key,
    required this.icon,
    this.gradientColors = const [Colors.orange, Colors.pink],
    this.size = 40.0,
    this.borderRadius = 8.0,
    this.iconColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.h,
      width: size.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: (size * 0.5).sp),
    );
  }
}
