import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/animation_progress_bar.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/custom_card.dart';
import 'package:k2k/common/widgets/loader.dart';
import 'package:k2k/konkrete_klinkers/stock_management/view/stock_view_screen.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_detail_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart'; // Assuming the provider file is named work_order_provider.dart

class WorkOrderDetailsPage extends StatefulWidget {
  final String workOrderId;

  const WorkOrderDetailsPage({super.key, required this.workOrderId});

  @override
  State<WorkOrderDetailsPage> createState() => _WorkOrderDetailsPageState();
}

class _WorkOrderDetailsPageState extends State<WorkOrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WorkOrderProvider>(context, listen: false);
      provider.getWorkOrderById(widget.workOrderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.workorders);
        }
      },
      child: Scaffold(
        appBar: AppBars(
          title: TitleText(title: 'Work Order Details'),
          leading: CustomBackButton(
            onPressed: () {
              context.go(RouteNames.workorders);
            },
          ),
        ),

        body: SafeArea(
          child: Consumer<WorkOrderProvider>(
            builder: (context, provider, child) {
              if (provider.isWorkOrderByIdLoading) {
                return Center(child: GridLoader());
              }
              if (provider.workOrderByIdError != null) {
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
                        provider.workOrderByIdError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          provider.getWorkOrderById(widget.workOrderId);
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
              final workOrder = provider.workOrderById;
              if (workOrder == null) {
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
                        'Please check the work order ID or try again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          provider.getWorkOrderById(widget.workOrderId);
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

              double progress = 0.0;
              if (workOrder.products.isNotEmpty) {
                double totalAchieved = workOrder.products.fold(
                  0.0,
                  (sum, p) => sum + p.achievedQuantity,
                );
                double totalQty = workOrder.products.fold(
                  0.0,
                  (sum, p) => sum + p.qtyInNos,
                );
                progress = totalQty > 0 ? totalAchieved / totalQty : 0.0;
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(4.w), // Match StockDetailsScreen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 8.w),
                      child: AnimatedProgressBar(progress: progress),
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientYellow,
                      title: 'Client Details',
                      subtitle: 'Client Information',
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
                      onTap: () {
                        final fields = [
                          WorkOrderField(
                            label: "Client Name",
                            value: workOrder.clientId.name,
                          ),
                          WorkOrderField(
                            label: "Project Name",
                            value: workOrder.projectId?.name,
                          ),
                          WorkOrderField(
                            label: "Location",
                            value: workOrder.clientId.address,
                          ),
                        ];
                        showWorkOrderDetailDialog(
                          context,
                          fields,
                          title: 'Client Details',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Client Name",
                          value: workOrder.clientId.name,
                        ),
                        WorkOrderField(
                          label: "Project Name",
                          value: workOrder.projectId?.name ?? 'N/A',
                        ),
                        WorkOrderField(
                          label: "Location",
                          value: workOrder.clientId.address,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientBlue,
                      title: 'Progress',
                      subtitle: 'Work Order Progress',
                      icon: IconContainer(
                        icon: Icons.playlist_add_check_circle,
                        gradientColors: [
                          Colors.blue.shade100,
                          Colors.cyan.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.blue.shade700,
                      ),
                      iconColor: Colors.blue,
                      onTap: () {
                        final fields = [
                          WorkOrderField(label: "Planning", value: "Completed"),
                          WorkOrderField(
                            label: "Development",
                            value: "In Progress",
                          ),
                          WorkOrderField(label: "Testing", value: "Pending"),
                          WorkOrderField(label: "Deployment", value: "Pending"),
                        ];
                        showWorkOrderDetailDialog(
                          context,
                          fields,
                          title: 'In Progress Details',
                        );
                      },
                      details: [
                        WorkOrderField(label: "Planning", value: "Completed"),
                        WorkOrderField(
                          label: "Development",
                          value: "In Progress",
                        ),
                        WorkOrderField(label: "Testing", value: "Pending"),
                        WorkOrderField(label: "Deployment", value: "Pending"),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientRed,
                      title: 'Work Orders',
                      subtitle: 'Work Order Information',
                      icon: IconContainer(
                        icon: Icons.folder,
                        gradientColors: [
                          Colors.red.shade100,
                          Colors.pink.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.red.shade700,
                      ),
                      iconColor: Colors.red,
                      onTap: () {
                        final fields = [
                          WorkOrderField(
                            label: "Work Order Number",
                            value: workOrder.workOrderNumber,
                          ),
                          WorkOrderField(
                            label: "Created At",
                            value: DateFormat(
                              'dd-MM-yyyy',
                            ).format(workOrder.date!),
                          ),
                          WorkOrderField(
                            label: "Created By",
                            value: workOrder.createdBy.username,
                          ),
                          WorkOrderField(
                            label: "Target Date",
                            value: workOrder.products.isNotEmpty
                                ? workOrder.products
                                      .map(
                                        (p) => p.deliveryDate != null
                                            ? DateFormat(
                                                'dd-MM-yyyy',
                                              ).format(p.deliveryDate!)
                                            : "No date",
                                      )
                                      .join(", ")
                                : "No products",
                          ),
                          WorkOrderField(
                            label: "Status",
                            value: workOrder.status,
                          ),
                          WorkOrderField(
                            label: "Buffer Stock",
                            value: workOrder.bufferStock,
                          ),
                          if (workOrder.files.isNotEmpty)
                            WorkOrderField(
                              label: "Files",
                              value: workOrder.files
                                  .map((f) => f.fileName)
                                  .toList(),
                            ),
                        ];
                        showWorkOrderDetailDialog(
                          context,
                          fields,
                          title: 'Work Order Details',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Work Order Number",
                          value: workOrder.workOrderNumber,
                        ),
                        WorkOrderField(
                          label: "Created At",
                          value: DateFormat(
                            'dd-MM-yyyy',
                          ).format(workOrder.date!),
                        ),
                        WorkOrderField(
                          label: "Created By",
                          value: workOrder.createdBy.username,
                        ),
                        WorkOrderField(
                          label: "Status",
                          value: workOrder.status,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientGreen,
                      title: 'Products',
                      subtitle: '${workOrder.products.length} Products',
                      icon: IconContainer(
                        icon: Icons.auto_graph,
                        gradientColors: [
                          Colors.green.shade100,
                          Colors.teal.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.green.shade700,
                      ),
                      iconColor: Colors.green,
                      onTap: () {
                        showListDetailsDialog(
                          context,
                          'Products Overview',
                          workOrder.products,
                          (dynamic product) {
                            final p = product as WODDataProduct;
                            return [
                              WorkOrderField(
                                label: "Name",
                                value: p.product.description,
                              ),
                              WorkOrderField(
                                label: "Material Code",
                                value: p.product.materialCode,
                              ),
                              WorkOrderField(label: "UOM", value: p.uom),
                              WorkOrderField(
                                label: "PO Quantity",
                                value: p.poQuantity,
                              ),
                              WorkOrderField(
                                label: "Achieved",
                                value: p.achievedQuantity,
                              ),
                              WorkOrderField(
                                label: "Packed",
                                value: p.packedQuantity,
                              ),
                              WorkOrderField(
                                label: "Dispatched",
                                value: p.dispatchedQuantity,
                              ),
                            ];
                          },
                          itemName: 'Product',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Total Products",
                          value: '${workOrder.products.length}',
                        ),
                        WorkOrderField(
                          label: "Sample Product",
                          value: workOrder.products.isNotEmpty
                              ? workOrder.products[0].product.description
                              : 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientYellow,
                      title: 'Job Order',
                      subtitle: workOrder.jobOrders.isNotEmpty
                          ? '${workOrder.jobOrders.length} Job Orders'
                          : 'No Job Orders',
                      icon: IconContainer(
                        icon: Icons.location_city,
                        gradientColors: [
                          Colors.orange.shade100,
                          Colors.yellow.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.orange.shade700,
                      ),
                      iconColor: Colors.orange,
                      onTap: () {
                        showListDetailsDialog(
                          context,
                          'Job Order Details',
                          workOrder.jobOrders,
                          (dynamic jobOrder) {
                            final jo = jobOrder as WODJobOrder;
                            return [
                              WorkOrderField(
                                label: "Job Order ID",
                                value: jo.jobOrderId,
                              ),
                              WorkOrderField(
                                label: "Sales Order Number",
                                value: jo.salesOrderNumber,
                              ),
                              WorkOrderField(
                                label: "Batch Number",
                                value: jo.batchNumber,
                              ),
                              WorkOrderField(label: "Status", value: jo.status),
                            ];
                          },
                          itemName: 'Job Order',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Total Job Orders",
                          value: '${workOrder.jobOrders.length}',
                        ),
                        WorkOrderField(
                          label: "Sample Job Order",
                          value: workOrder.jobOrders.isNotEmpty
                              ? workOrder.jobOrders[0].jobOrderId
                              : 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientBlue,
                      title: 'Packing Details',
                      subtitle: workOrder.packings.isNotEmpty
                          ? '${workOrder.packings.length} Packings'
                          : 'No Packings',
                      icon: IconContainer(
                        icon: Icons.engineering_outlined,
                        gradientColors: [
                          Colors.blue.shade100,
                          Colors.cyan.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.blue.shade700,
                      ),
                      iconColor: Colors.blue,
                      onTap: () {
                        showListDetailsDialog(
                          context,
                          'Packing Details',
                          workOrder.packings,
                          (dynamic packing) {
                            final pk = packing as WODPacking;
                            return [
                              WorkOrderField(label: "SL No", value: pk.slNo),
                              WorkOrderField(
                                label: "Product",
                                value: pk.product,
                              ),
                              WorkOrderField(label: "Date", value: pk.date),
                              WorkOrderField(
                                label: "Total Qty",
                                value: pk.totalQty,
                              ),
                            ];
                          },
                          itemName: 'Packing',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Total Packings",
                          value: '${workOrder.packings.length}',
                        ),
                        WorkOrderField(
                          label: "Sample Packing",
                          value: workOrder.packings.isNotEmpty
                              ? workOrder.packings[0].product
                              : 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientRed,
                      title: 'Dispatch Details',
                      subtitle: workOrder.dispatches.isNotEmpty
                          ? '${workOrder.dispatches.length} Dispatches'
                          : 'No Dispatches',
                      icon: IconContainer(
                        icon: Icons.engineering_outlined,
                        gradientColors: [
                          Colors.red.shade100,
                          Colors.pink.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.red.shade700,
                      ),
                      iconColor: Colors.red,
                      onTap: () {
                        showListDetailsDialog(
                          context,
                          'Dispatch Details',
                          workOrder.dispatches,
                          (dynamic dispatch) {
                            final dp = dispatch as WODDispatch;
                            return [
                              WorkOrderField(label: "SL No", value: dp.slNo),
                              WorkOrderField(
                                label: "Product",
                                value: dp.product,
                              ),
                              WorkOrderField(label: "Date", value: dp.date),
                              WorkOrderField(
                                label: "Total Qty",
                                value: dp.totalQty,
                              ),
                            ];
                          },
                          itemName: 'Dispatch',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Total Dispatches",
                          value: '${workOrder.dispatches.length}',
                        ),
                        WorkOrderField(
                          label: "Sample Dispatch",
                          value: workOrder.dispatches.isNotEmpty
                              ? workOrder.dispatches[0].product
                              : 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildDetailCard(
                      headerGradient: AppTheme.cardGradientGreen,
                      title: 'QC Details',
                      subtitle: workOrder.qcDetails.isNotEmpty
                          ? '${workOrder.qcDetails.length} QC Details'
                          : 'No QC Details',
                      icon: IconContainer(
                        icon: Icons.engineering_outlined,
                        gradientColors: [
                          Colors.green.shade100,
                          Colors.teal.shade50,
                        ],
                        size: 48,
                        borderRadius: 12,
                        iconColor: Colors.green.shade700,
                      ),
                      iconColor: Colors.green,
                      onTap: () {
                        showListDetailsDialog(
                          context,
                          'QC Details',
                          workOrder.qcDetails,
                          (dynamic qc) {
                            final q = qc as WODQcDetail;
                            return [
                              WorkOrderField(label: "SL No", value: q.slNo),
                              WorkOrderField(
                                label: "Product",
                                value: q.product,
                              ),
                              WorkOrderField(
                                label: "Recycled Quantity",
                                value: q.recycledQuantity,
                              ),
                              WorkOrderField(
                                label: "Rejected Quantity",
                                value: q.rejectedQuantity,
                              ),
                            ];
                          },
                          itemName: 'QC',
                        );
                      },
                      details: [
                        WorkOrderField(
                          label: "Total QC Details",
                          value: '${workOrder.qcDetails.length}',
                        ),
                        WorkOrderField(
                          label: "Sample QC",
                          value: workOrder.qcDetails.isNotEmpty
                              ? workOrder.qcDetails[0].product
                              : 'N/A',
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

  Widget _buildDetailCard({
    required Gradient headerGradient,
    required String title,
    required String subtitle,
    required IconContainer icon,
    required Color iconColor,
    required List<WorkOrderField> details,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      title: title,
      subtitle: subtitle,
      leading: icon,
      headerGradient: headerGradient,
      borderRadius: 12,
      backgroundColor: Colors.white,
      borderColor: Colors.grey.withOpacity(0.15),
      borderWidth: 0,
      elevation: 2,
      onTap: onTap,
      bodyItems: [
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    detail.value?.toString() ?? 'N/A',
                    style: TextStyle(fontSize: 14.sp, color: AppTheme.darkGray),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showWorkOrderDetailDialog(
    BuildContext context,
    List<WorkOrderField> fields, {
    String title = "Work Order Details",
  }) {
    showGeneralDialog(
      barrierLabel: "Details",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      context: context,
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: WorkOrderDialog(fields: fields, title: title),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
    );
  }
}

class WorkOrderField {
  final String label;
  final dynamic value;

  WorkOrderField({required this.label, this.value});
}

class WorkOrderDialog extends StatelessWidget {
  final List<WorkOrderField> fields;
  final String title;

  const WorkOrderDialog({
    super.key,
    required this.fields,
    this.title = "Work Order Details",
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white.withOpacity(0.85),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          minWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment,
                  color: Colors.deepPurple,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: fields.map((field) {
                    String displayValue;
                    if (field.value == null) {
                      displayValue = "-";
                    } else if (field.value is DateTime) {
                      final dt = field.value as DateTime;
                      displayValue =
                          "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
                    } else if (field.label.toLowerCase().contains("file")) {
                      displayValue = field.value.toString().split('/').last;
                    } else if (field.value is List) {
                      displayValue = field.value.join(", ");
                    } else {
                      displayValue = field.value.toString();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              "${field.label}:",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: Text(
                              displayValue,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.backspace, color: Colors.deepPurple),
                label: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showListDetailsDialog(
  BuildContext context,
  String title,
  List<dynamic> items,
  List<WorkOrderField> Function(dynamic item) getFields, {
  String itemName = 'Item',
}) {
  showGeneralDialog(
    barrierLabel: "List Details",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 200),
    context: context,
    pageBuilder: (_, __, ___) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: ListDetailsDialog(
            title: title,
            items: items,
            getFields: getFields,
            itemName: itemName,
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      );
    },
  );
}

class ListDetailsDialog extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final List<WorkOrderField> Function(dynamic item) getFields;
  final String itemName;

  const ListDetailsDialog({
    super.key,
    required this.title,
    required this.items,
    required this.getFields,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white.withOpacity(0.85),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          minWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment,
                  color: Colors.deepPurple,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: _buildContent()),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.backspace, color: Colors.deepPurple),
                label: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    List<Widget> content = [];
    if (items.isEmpty) {
      content.add(
        const Center(
          child: Text(
            'No details available yet.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    } else {
      for (int i = 0; i < items.length; i++) {
        if (i > 0) {
          content.add(SizedBox(height: 20.h));
        }
        content.add(
          Text(
            '$itemName ${i + 1}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        );
        final fields = getFields(items[i]);
        content.addAll(
          fields.map((field) {
            String displayValue;
            if (field.value == null) {
              displayValue = "-";
            } else if (field.value is DateTime) {
              final dt = field.value as DateTime;
              displayValue =
                  "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
            } else if (field.label.toLowerCase().contains("file")) {
              displayValue = field.value.toString().split('/').last;
            } else if (field.value is List) {
              displayValue = field.value.join(", ");
            } else {
              displayValue = field.value.toString();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      "${field.label}:",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      }
    }
    return content;
  }
}
