import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/production/model/common_model.dart';
import 'package:k2k/konkrete_klinkers/production/provider/production_provider.dart';
import 'package:provider/provider.dart';

class DowntimeScreen extends StatefulWidget {
  final String productId;
  final String jobOrder;
  final String prodId;

  const DowntimeScreen({
    super.key,
    required this.productId,
    required this.jobOrder,
    required this.prodId,
  });

  @override
  _DowntimeScreenState createState() => _DowntimeScreenState();
}

class _DowntimeScreenState extends State<DowntimeScreen> {
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductionProvider>(context, listen: false);
      provider.fetchDownTimeLogs(
        widget.productId,
        widget.jobOrder,
        widget.prodId,
      );
    });
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionProvider>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.go(RouteNames.production);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBars(
              title: TitleText(title: 'DownTime Logs'),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22.sp,
                  color: Colors.blue[700],
                ),
                onPressed: () => context.goNamed(RouteNames.production),
              ),
              action: [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue[700], size: 24.sp),
                  onPressed: () => _showDowntimeForm(context, provider),
                  tooltip: 'Add Downtime',
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // _buildDatePickerSection(provider),
                  Expanded(
                    child: provider.isLoading
                        ? Center(child: GradientLoader())
                        : _buildDowntimeList(
                            provider.downTimeLogs ?? [],
                            emptyMessage:
                                'No downtime records for this job order',
                            error: provider.error,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDowntimeList(
    List<Downtime> downTimes, {
    required String emptyMessage,
    String? error,
  }) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50.sp, color: Colors.red[400]),
            SizedBox(height: 20.h),
            Text(
              'Error: $error',
              style: TextStyle(fontSize: 16.sp, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () =>
                  Provider.of<ProductionProvider>(
                    context,
                    listen: false,
                  ).fetchDownTimeLogs(
                    widget.productId,
                    widget.jobOrder,
                    widget.prodId,
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    if (downTimes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 50.sp, color: Colors.grey[400]),
            SizedBox(height: 20.h),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: downTimes.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final dt = downTimes[index];
        return _buildDowntimeCard(dt);
      },
    );
  }

  Widget _buildDowntimeCard(Downtime dt) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.2),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dt.reason,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Duration: ${dt.total_duration} min',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info, size: 24.sp, color: Colors.blue[700]),
            onPressed: () => _showDetailDialog(context, dt),
            tooltip: 'Details',
          ),
        ],
      ),
    );
  }

  Future<void> _showDowntimeForm(
    BuildContext context,
    ProductionProvider provider,
  ) async {
    provider.resetForm();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Consumer<ProductionProvider>(
                  builder: (context, provider, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Downtime',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 24.sp,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Maintenance Type *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<Description>(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.blue[700]!,
                              width: 1.5.w,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: provider.selectedDescription,
                        items: Description.values
                            .map(
                              (desc) => DropdownMenuItem(
                                value: desc,
                                child: Text(
                                  descriptionValues.reverse[desc]!,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: provider.setSelectedDescription,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Start Time *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: provider.startTime ?? TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue[700]!,
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (time != null) provider.setStartTime(time);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue[50]!.withOpacity(0.2),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              border: InputBorder.none,
                              hintText: provider.startTime != null
                                  ? provider.startTime!.format(context)
                                  : 'Select Time',

                              hintStyle: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: Icon(
                                Icons.access_time,
                                size: 24.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Duration (min) *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.blue[700]!,
                              width: 1.5.w,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) =>
                            provider.setMinutes(int.tryParse(val)),

                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Remarks',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.blue[700]!,
                              width: 1.5.w,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (provider.selectedDescription == null ||
                                  provider.startTime == null ||
                                  provider.minutes == null) {
                                context.showErrorSnackbar(
                                  "Please fill all required fields",
                                );
                                return;
                              }
                              final now = DateTime.now();
                              final startDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                provider.startTime!.hour,
                                provider.startTime!.minute,
                              );

                              final downtimeData = {
                                'description': descriptionValues
                                    .reverse[provider.selectedDescription]!,
                                'downtime_start_time': DateFormat(
                                  'HH:mm',
                                ).format(startDateTime),
                                'job_order': widget.jobOrder,
                                'minutes': provider.minutes.toString(),
                                'product_id': widget.productId,
                                'remarks': _remarksController.text,
                                'prodId': widget.prodId,
                              };
                              try {
                                await Provider.of<ProductionProvider>(
                                  context,
                                  listen: false,
                                ).addDownTime(
                                  widget.productId,
                                  widget.jobOrder,
                                  widget.prodId,
                                  downtimeData,
                                );
                                Navigator.pop(context);
                                context.showSuccessSnackbar(
                                  'Downtime added successfully',
                                );
                              } catch (e) {
                                context.showErrorSnackbar(
                                  'Failed to add downtime',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 14.h,
                              ),
                              elevation: 2,
                              shadowColor: Colors.blue[200]!.withOpacity(0.3),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, Downtime dt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 60.h,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.blue[200]!, width: 1.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[100]!.withOpacity(0.3),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downtime Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow('Reason', dt.reason, Colors.blue[700]!),
                  SizedBox(height: 12.h),
                  _buildDetailRow(
                    'Start Time',
                    dt.startTime != null
                        ? DateFormat('hh:mm a').format(dt.startTime!)
                        : 'N/A',
                    Colors.grey[800]!,
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailRow(
                    'End Time',
                    dt.endTime != null
                        ? DateFormat('hh:mm a').format(dt.endTime!)
                        : 'N/A',
                    Colors.grey[800]!,
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailRow(
                    'Duration',
                    '${dt.total_duration} min',
                    Colors.grey[800]!,
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailRow(
                    'Remarks',
                    dt.remarks.isEmpty ? 'N/A' : dt.remarks,
                    Colors.grey[800]!,
                    isMultiLine: true,
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        elevation: 2,
                        shadowColor: Colors.blue[200]!.withOpacity(0.3),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor, {
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor,
              height: isMultiLine ? 1.4 : null,
            ),
            maxLines: isMultiLine ? 3 : 1,
            overflow: isMultiLine ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }
}
