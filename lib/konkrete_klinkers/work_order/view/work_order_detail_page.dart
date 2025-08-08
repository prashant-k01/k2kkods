import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';

class WorkOrderDetailsPage extends StatelessWidget {
  const WorkOrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.1),
            radius: 1.8,
            colors: [Color(0xFFA87BFF), Color(0xFFE9DDFC), Color(0xFFFFFFFF)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.goNamed(RouteNames.workorders),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24.sp,
                      color: Colors.purple,
                    ),
                  ),
                ),
                SizedBox(width: 30.w),
                Text(
                  'Work Order Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              'Clients, Work Order, Products, Job Orders',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 16.h,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '60%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.0,
                children: [
                  WorkCard(
                    icon: Icons.person,
                    title: 'Clients',
                    subtitle: 'Acme Inc.',
                    onTap: () {
                      showWorkOrderDetailDialog(context, [
                        WorkOrderField(
                          label: "Work Order Number",
                          value: "hdiwufhiuowc",
                        ),
                        WorkOrderField(
                          label: "Created At",
                          value: DateTime(2025, 7, 25, 9, 44),
                        ),
                        WorkOrderField(
                          label: "Created By",
                          value: "admin (Admin)",
                        ),
                        WorkOrderField(
                          label: "Files",
                          value: "/documents/work_order.pdf",
                        ),
                        WorkOrderField(
                          label: "Dates",
                          value: DateTime(2025, 7, 19),
                        ),
                        WorkOrderField(label: "Status", value: "Pending"),
                        WorkOrderField(label: "Buffer Stock", value: "No"),
                      ]);
                    },
                  ),
                  WorkCard(
                    icon: Icons.playlist_add_check_circle,
                    title: 'Projects',
                    subtitle: 'In Progress',
                  ),
                  WorkCard(
                    icon: Icons.folder,
                    title: 'Work Orders',
                    subtitle: 'May 20, 2024',
                  ),
                  WorkCard(
                    icon: Icons.auto_graph,
                    title: 'Products',
                    subtitle: 'Los Angeles',
                  ),
                  WorkCard(
                    icon: Icons.location_city,
                    title: 'Job Order',
                    subtitle: 'Installation',
                  ),
                  WorkCard(
                    icon: Icons.engineering_outlined,
                    title: 'Packing Details',
                    subtitle: 'John Smith',
                  ),
                  WorkCard(
                    icon: Icons.engineering_outlined,
                    title: 'Dispatch Details',
                    subtitle: 'John Smith',
                  ),
                  WorkCard(
                    icon: Icons.engineering_outlined,
                    title: 'Qc Details',
                    subtitle: 'John Smith',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const WorkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade100,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: Icon(icon, color: Colors.purple, size: 24.sp),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: Icon(
                    Icons.arrow_outward,
                    size: 24.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkOrderField {
  final String label;
  final dynamic value;

  WorkOrderField({required this.label, this.value});
}

void showWorkOrderDetailDialog(
  BuildContext context,
  List<WorkOrderField> fields,
) {
  showGeneralDialog(
    barrierLabel: "Work Order",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4), // background dim
    transitionDuration: const Duration(milliseconds: 200),
    context: context,
    pageBuilder: (_, __, ___) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Glass effect
        child: Center(child: WorkOrderDialog(fields: fields)),
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

class WorkOrderDialog extends StatelessWidget {
  final List<WorkOrderField> fields;

  const WorkOrderDialog({super.key, required this.fields});

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
            // 🔹 Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.assignment, color: Colors.deepPurple, size: 26),
                SizedBox(width: 10),
                Text(
                  "Work Order Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),

            // 🔹 Field Cards
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

            // 🔹 Close Button: Real UI Style (bottom right aligned TextButton)
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
