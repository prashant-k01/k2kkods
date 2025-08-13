import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/production/model/common_model.dart';
import 'package:k2k/konkrete_klinkers/production/model/production_model.dart';
import 'package:k2k/konkrete_klinkers/production/provider/production_provider.dart';
import 'package:provider/provider.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  _ProductionScreenState createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductionProvider>(context, listen: false);
      print('Initializing ProductionScreen, setting date to today');
      provider.setDate(DateTime.now());
      provider.fetchProductionJobOrderByDate();
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
        print(
          'Building ProductionScreen, isLoading: ${provider.isLoading}, '
          'error: ${provider.error}, '
          'todayDpr: ${provider.getFilteredTodayDpr().length}',
        );
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.go(RouteNames.homeScreen);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBars(
              title: Text(
                'Production Logs',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22.sp,
                  color: Colors.blue[700],
                ),
                onPressed: () => context.goNamed(RouteNames.homeScreen),
              ),
              action: [
                IconButton(
                  icon: Icon(
                    provider.showTimer ? Icons.timer_off : Icons.timer,
                    color: Colors.blue[700],
                    size: 24.sp,
                  ),
                  onPressed: () {
                    print(
                      'Toggling timer, current showTimer: ${provider.showTimer}',
                    );
                    provider.toggleTimer();
                  },
                  tooltip: provider.showTimer ? 'Hide Timer' : 'Show Timer',
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildDatePickerSection(provider),
                  if (provider.showTimer && provider.activeTimerJobId != null)
                    _buildTimerSection(provider),
                  _buildMetricsSection(provider),
                  // Add filter indicator
                  if (provider.selectedFilter != 'all')
                    _buildFilterIndicator(provider),
                  Expanded(
                    child: provider.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue[700],
                              strokeWidth: 2.w,
                            ),
                          )
                        : _buildDprList(
                            dprList: provider.getFilteredTodayDpr(),
                            emptyMessage: provider.getEmptyMessage(),
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

  // Updated to use provider's filter
  Widget _buildFilterIndicator(ProductionProvider provider) {
    String filterText = '';
    Color filterColor = Colors.blue;

    switch (provider.selectedFilter) {
      case 'active':
        filterText = 'Showing Active Jobs';
        filterColor = Colors.green;
        break;
      case 'inactive':
        filterText = 'Showing Inactive Jobs';
        filterColor = Colors.orange;
        break;
      case 'created_today':
        filterText = 'Showing Jobs Created Today';
        filterColor = Colors.purple;
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: filterColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: filterColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16.sp, color: filterColor),
          SizedBox(width: 8.w),
          Text(
            filterText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: filterColor,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              provider.setFilter('all');
            },
            child: Icon(Icons.close, size: 18.sp, color: filterColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerSection(ProductionProvider provider) {
    print('Building DatePickerSection, selectedDate: ${provider.selectedDate}');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 10.h),
      child: GestureDetector(
        onTap: () {
          print('Date picker tapped');
          _showDatePicker(provider);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[100]!.withOpacity(0.2),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
            border: Border.all(color: Colors.blue[200]!, width: 1.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.selectedDate != null
                    ? DateFormat(
                        'EEE, MMM d, yyyy',
                      ).format(provider.selectedDate!)
                    : 'Select Date',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              Icon(Icons.calendar_today, size: 22.sp, color: Colors.blue[700]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(ProductionProvider provider) async {
    final today = _normalizeDate(DateTime.now());
    print(
      'Showing date picker, initialDate: ${provider.selectedDate ?? today}',
    );
    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue[700]!,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );
    if (date != null) {
      print('Date selected: $date');
      provider.setDate(date);
      await provider.fetchProductionJobOrderByDate();
    }
  }

  Widget _buildTimerSection(ProductionProvider provider) {
    print(
      'Building TimerSection, activeTimerJobId: ${provider.activeTimerJobId}, '
      'timer: ${provider.formatTimer(provider.activeTimerJobId!)}',
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.blue[100]!.withOpacity(0.2),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
          border: Border.all(color: Colors.blue[200]!, width: 1.w),
        ),
        child: Row(
          children: [
            Icon(Icons.timer, size: 22.sp, color: Colors.blue[700]),
            SizedBox(width: 10.w),
            Text(
              'Active Job: ',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Text(
              provider.activeTimerJobId!,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const Spacer(),
            Text(
              provider.formatTimer(provider.activeTimerJobId!),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(ProductionProvider provider) {
    final dprList = provider.getFilteredTodayDpr();
    final total = dprList.length;

    final active = dprList.where((dpr) {
      final Status actualStatus = dpr is PastDpr
          ? (dpr.dailyProduction?.status ?? dpr.status)
          : dpr.status;
      return actualStatus == Status.IN_PROGRESS;
    }).length;

    final inactive = dprList.where((dpr) {
      final Status actualStatus = dpr is PastDpr
          ? (dpr.dailyProduction?.status ?? dpr.status)
          : dpr.status;
      return actualStatus == Status.PAUSED || actualStatus == Status.PENDING_QC;
    }).length;

    final today = _normalizeDate(DateTime.now());
    final createdToday = dprList.where((dpr) {
      final DateTime createdAt = dpr.createdAt;
      return _normalizeDate(createdAt) == today;
    }).length;

    print(
      'Building MetricsSection, total: $total, active: $active, inactive: $inactive, createdToday: $createdToday',
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ), // Reduced margins
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfessionalMetricBox(
              title: 'Total Jobs',
              value: total.toString(),
              icon: Icons.inventory_2_outlined,
              gradientColors: [
                const Color.fromARGB(255, 92, 187, 255),
                const Color(0xFFBBDEFB),
              ],
              filterKey: 'all',
              isSelected: provider.selectedFilter == 'all',
              provider: provider,
            ),
            SizedBox(width: 8.w), // Reduced spacing
            _buildProfessionalMetricBox(
              title: 'Active',
              value: active.toString(),
              icon: Icons.play_circle_outline,
              gradientColors: [
                const Color.fromARGB(255, 5, 161, 18),
                const Color(0xFFC8E6C9),
              ],
              filterKey: 'active',
              isSelected: provider.selectedFilter == 'active',
              provider: provider,
            ),
            SizedBox(width: 8.w), // Reduced spacing
            _buildProfessionalMetricBox(
              title: 'Inactive',
              value: inactive.toString(),
              icon: Icons.pause_circle_outline,
              gradientColors: [
                const Color.fromARGB(255, 248, 171, 46),
                const Color(0xFFFFE0B2),
              ],
              filterKey: 'inactive',
              isSelected: provider.selectedFilter == 'inactive',
              provider: provider,
            ),
            SizedBox(width: 8.w), // Reduced spacing
            _buildProfessionalMetricBox(
              title: 'Created',
              value: createdToday.toString(),
              icon: Icons.add_circle_outline,
              gradientColors: [
                const Color.fromARGB(255, 172, 20, 196),
                const Color(0xFFE1BEE7),
              ],
              filterKey: 'created_today',
              isSelected: provider.selectedFilter == 'created_today',
              provider: provider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required String filterKey,
    required bool isSelected,
    required ProductionProvider provider,
  }) {
    return GestureDetector(
      onTap: () => provider.setFilter(filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 90.w, // Fixed width for consistency
        height: 100.h, // Reduced height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.3),
              blurRadius: isSelected ? 10.r : 6.r,
              offset: Offset(0, isSelected ? 4.h : 2.h),
              spreadRadius: isSelected ? 1.r : 0,
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 1.5.w)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => provider.setFilter(filterKey),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 10.h,
              ), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.h,
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(icon, color: Colors.white, size: 16.sp),
                      ),
                      if (isSelected)
                        Container(
                          width: 20.w,
                          height: 20.h,
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.check,
                            color: gradientColors[1],
                            size: 12.sp,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDprList({
    List<dynamic>? dprList,
    String? emptyMessage,
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
              onPressed: () {
                print('Retrying fetchProductionJobOrderByDate');
                Provider.of<ProductionProvider>(
                  context,
                  listen: false,
                ).fetchProductionJobOrderByDate();
              },
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
    if (dprList!.isEmpty) {
      print('DPR List is empty, showing: $emptyMessage');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 50.sp, color: Colors.grey[400]),
            SizedBox(height: 20.h),
            Text(
              emptyMessage!,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: dprList.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final dpr = dprList[index];
        final provider = Provider.of<ProductionProvider>(
          context,
          listen: false,
        );

        final Status actualStatus = dpr is PastDpr
            ? (dpr.dailyProduction?.status ?? dpr.status)
            : dpr.status;
        final statusColor = provider.getStatusColor(actualStatus);

        return _buildProductionCard(dpr, statusColor, provider);
      },
    );
  }

  Widget _buildProductionCard(
    dynamic dpr,
    Color statusColor,
    ProductionProvider provider,
  ) {
    final String? id = dpr is PastDpr ? dpr.id : dpr.id;

    final Status status = dpr is PastDpr
        ? (dpr.dailyProduction?.status ?? dpr.status)
        : dpr.status;

    final WorkOrder workOrder = dpr is PastDpr ? dpr.workOrder : dpr.workOrder;
    final String? jobOrderId = dpr is PastDpr ? dpr.jobOrderId : dpr.jobOrder;
    final String? salesOrderNumber = dpr is PastDpr
        ? dpr.salesOrderNumber
        : 'N/A';
    final String? machineName = dpr is PastDpr ? dpr.machineName : 'N/A';
    final DateTime? startedAt = dpr is PastDpr ? dpr.startedAt : dpr.startedAt;
    final DateTime? stoppedAt = dpr is PastDpr ? dpr.stoppedAt : null;
    final String? plantName = dpr is PastDpr ? dpr.plantName : 'N/A';
    final int poQuantity = dpr is PastDpr ? dpr.poQuantity : 0;
    final int achievedQuantity = dpr is PastDpr
        ? dpr.achievedQuantity
        : (dpr.products.isNotEmpty ? dpr.products[0].achievedQuantity : 0);
    final int rejectedQuantity = dpr is PastDpr
        ? dpr.rejectedQuantity
        : (dpr.products.isNotEmpty ? dpr.products[0].rejectedQuantity : 0);
    final int recycledQuantity = dpr is PastDpr
        ? dpr.recycledQuantity
        : (dpr.products.isNotEmpty ? dpr.products[0].recycledQuantity : 0);

    print('Building ProductionCard for id: $id, status: $status');

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.2),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.factory,
                    size: 22.sp,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    plantName ?? 'N/A',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                buildStatusBadge(status),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Work Order Info"),
                SizedBox(height: 8.h),
                _buildInfoGrid([
                  _buildDetailItem(
                    "Work Order No",
                    workOrder.workOrderNumber ?? 'N/A',
                  ),
                  _buildDetailItem("Job Order No", jobOrderId ?? 'N/A'),
                  _buildDetailItem("Sales Order No", salesOrderNumber ?? 'N/A'),
                  _buildDetailItem("Machine Name", machineName ?? 'N/A'),
                  _buildDetailItem("Client", workOrder.clientName ?? 'N/A'),
                  _buildDetailItem("Project", workOrder.projectName ?? 'N/A'),
                ]),
                SizedBox(height: 16.h),
                _buildTimelineSection(startedAt, stoppedAt),
                SizedBox(height: 16.h),
                _buildSectionTitle("Production Details"),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricBox(
                      title: "PO Qty",
                      value: poQuantity.toString(),
                      color: Colors.blue,
                    ),
                    _buildMetricBox(
                      title: "Achieved",
                      value: achievedQuantity.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricBox(
                      title: "Rejected",
                      value: rejectedQuantity.toString(),
                      color: Colors.red,
                    ),
                    _buildMetricBox(
                      title: "Recycled",
                      value: recycledQuantity.toString(),
                      color: Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildActionButtons(dpr, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(DateTime? startTime, DateTime? endTime) {
    print('Building TimelineSection, startTime: $startTime, endTime: $endTime');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Timeline"),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimeItem("Started", startTime),
            _buildTimeItem("Stopped", endTime),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildTimeItem(String label, DateTime? dateTime) {
    print('Building TimeItem: $label, dateTime: $dateTime');
    if (dateTime == null) {
      return Text(
        '$label\nN/A',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
            SizedBox(width: 8.w),
            Text(
              DateFormat('dd MMM yyyy').format(dateTime),
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
            SizedBox(width: 8.w),
            Text(
              DateFormat('hh:mm a').format(dateTime),
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    print('Building SectionTitle: $title');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<Widget> items) {
    print('Building InfoGrid with ${items.length} items');
    return Wrap(
      spacing: 20.w,
      runSpacing: 12.h,
      children: items
          .map((item) => SizedBox(width: 160.w, child: item))
          .toList(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    print('Building DetailItem: $label, value: $value');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
          ),
        ),
        SizedBox(height: 6.h),
        Divider(height: 1.h, color: Colors.blue[100]),
      ],
    );
  }

  Widget buildStatusBadge(Status status) {
    print('Building StatusBadge: $status');
    final (color, icon, label) = switch (status) {
      Status.PENDING => (Colors.grey, Icons.access_time, 'Pending'),
      Status.IN_PROGRESS => (Colors.green, Icons.play_arrow, 'In Progress'),
      Status.PENDING_QC => (
        Colors.blue,
        Icons.check_circle_outline,
        'Pending QC',
      ),
      Status.PAUSED => (Colors.orange, Icons.pause_circle_filled, 'Paused'),
      Status.COMPLETED => (Colors.black54, Icons.check_circle, 'Completed'),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic dpr, ProductionProvider provider) {
    final Status status = dpr is PastDpr
        ? (dpr.dailyProduction?.status ?? dpr.status)
        : dpr.status;
    final String? jobOrder = dpr is PastDpr ? dpr.jobOrder : dpr.jobOrder;
    final String? productId = dpr is PastDpr
        ? dpr.productId
        : (dpr.products.isNotEmpty ? dpr.products[0].productId : null);

    final (action, label, icon, color, isEnabled) = switch (status) {
      Status.PENDING => (
        'start',
        'Start',
        Icons.play_arrow,
        Colors.green,
        true,
      ),
      Status.IN_PROGRESS => (
        'pause',
        'Pause',
        Icons.pause,
        Colors.orange,
        true,
      ),
      Status.PAUSED => (
        'resume',
        'Resume',
        Icons.play_arrow,
        Colors.green,
        true,
      ),
      Status.PENDING_QC => (
        'complete',
        'Completed',
        Icons.check,
        Colors.blue,
        false,
      ),
      Status.COMPLETED => (
        'complete',
        'Completed',
        Icons.check,
        Colors.blue,
        false,
      ),
    };

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.refresh,
            label: 'Refresh',
            color: Colors.blue[700]!,
            onPressed: jobOrder != null && productId != null
                ? () async {
                    await provider.updateProduction(productId, jobOrder);
                  }
                : null,
          ),
          _buildActionButton(
            icon: Icons.settings,
            label: 'Downtime',
            color: Colors.teal,
            onPressed: jobOrder != null && productId != null
                ? () async {
                    await provider.fetchDownTimeLogs(productId, jobOrder);
                    GoRouter.of(context).goNamed(
                      RouteNames.downtime,
                      extra: {'productId': productId, 'jobOrder': jobOrder},
                    );
                  }
                : null,
          ),
          _buildActionButton(
            icon: Icons.list_alt,
            label: 'Logs',
            color: Colors.purple,
            onPressed: jobOrder != null && productId != null
                ? () async {
                    await provider.fetchProductionLogs(productId, jobOrder);
                    GoRouter.of(context).goNamed(
                      RouteNames.logs,
                      extra: {'productId': productId, 'jobOrder': jobOrder},
                    );
                  }
                : null,
          ),
          _buildActionButton(
            icon: icon,
            label: label,
            color: color,
            isEnabled: isEnabled && jobOrder != null && productId != null,
            onPressed: isEnabled && jobOrder != null && productId != null
                ? () async {
                    try {
                      await provider.performProductionAction(
                        jobOrder: jobOrder,
                        productId: productId,
                        action: action,
                      );
                      print('Action $action successful');
                    } catch (e) {
                      print('Error performing action $action: $e');
                      context.showErrorSnackbar("Error: $e");
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  DateTime? _lastTapTime;
  Widget _buildActionButton({
    IconData? icon,
    String? label,
    Color? color,
    Future<void> Function()? onPressed,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled
          ? () async {
              final now = DateTime.now();
              if (_lastTapTime == null ||
                  now.difference(_lastTapTime!) > Duration(milliseconds: 500)) {
                _lastTapTime = now;
                await onPressed?.call();
              }
            }
          : null,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color!.withOpacity(isEnabled ? 0.1 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon!,
              size: 22.sp,
              color: isEnabled ? color : Colors.grey,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.sp,
              color: isEnabled ? color : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({String? title, String? value, Color? color}) {
    return Container(
      width: (ScreenUtil().screenWidth - 40.w) / 2.5,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        children: [
          Text(
            title!,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value!,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    print('Normalizing date: $date');
    return DateTime(date.year, date.month, date.day);
  }
}
