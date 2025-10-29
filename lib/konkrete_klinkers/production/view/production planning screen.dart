import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
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
            backgroundColor: const Color(0xFFF8FAFC),
            // appBar: AppBars(
            //   title: TitleText(title: 'Production Planning'),
            //   leading: Container(
            //     margin: EdgeInsets.all(8.w),
            //     child: Material(
            //       color: const Color(0xFFF1F5F9),
            //       borderRadius: BorderRadius.circular(12.r),
            //       child: InkWell(
            //         borderRadius: BorderRadius.circular(12.r),
            //         onTap: () => context.goNamed(RouteNames.homeScreen),
            //         child: Icon(
            //           Icons.arrow_back_ios_new_rounded,
            //           size: 20.sp,
            //           color: const Color(0xFF475569),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildCompactDatePickerSection(provider),
                  if (provider.showTimer && provider.activeTimerJobId != null)
                    _buildCompactTimerSection(provider),
                  _buildCompactMetricsSection(provider),
                  if (provider.selectedFilter != 'all')
                    _buildFilterIndicator(provider),
                  Expanded(
                    child: provider.isLoading
                        ? Center(child: GradientLoader())
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

  Widget _buildFilterIndicator(ProductionProvider provider) {
    String filterText = '';
    Color filterColor = const Color(0xFF3B82F6);
    IconData filterIcon = Icons.filter_alt_rounded;

    switch (provider.selectedFilter) {
      case 'active':
        filterText = 'Active Jobs Only';
        filterColor = const Color(0xFF10B981);
        filterIcon = Icons.play_circle_outline_rounded;
        break;
      case 'inactive':
        filterText = 'Inactive Jobs Only';
        filterColor = const Color(0xFFF59E0B);
        filterIcon = Icons.pause_circle_outline_rounded;
        break;
      case 'created_today':
        filterText = 'Jobs Created Today';
        filterColor = const Color(0xFF8B5CF6);
        filterIcon = Icons.add_circle_outline_rounded;
        break;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
      child: Material(
        color: filterColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: filterColor.withOpacity(0.2),
              width: 1.5.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: filterColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(filterIcon, size: 16.sp, color: filterColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  filterText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: filterColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Material(
                color: filterColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6.r),
                  onTap: () => provider.setFilter('all'),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.sp,
                      color: filterColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Date Picker - Reduced height and padding
  Widget _buildCompactDatePickerSection(ProductionProvider provider) {
    print('Building DatePickerSection, selectedDate: ${provider.selectedDate}');
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            print('Date picker tapped');
            _showDatePicker(provider);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5.w),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.05),
                  blurRadius: 15.r,
                  offset: Offset(0, 4.h),
                  spreadRadius: -2.r,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18.sp,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Production Date',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          letterSpacing: -0.1,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        provider.selectedDate != null
                            ? DateFormat(
                                'EEEE, MMM d, yyyy',
                              ).format(provider.selectedDate!)
                            : 'Select Production Date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1E293B),
          ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
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

  // Compact Timer Section - Reduced height and padding
  Widget _buildCompactTimerSection(ProductionProvider provider) {
    print(
      'Building TimerSection, activeTimerJobId: ${provider.activeTimerJobId}, '
      'timer: ${provider.formatTimer(provider.activeTimerJobId!)}',
    );
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2),
              width: 1.5.w,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF10B981).withOpacity(0.05), Colors.white],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.timer_rounded,
                  size: 20.sp,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Active Production',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Job: ${provider.activeTimerJobId!}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  provider.formatTimer(provider.activeTimerJobId!),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Metrics Section - Reduced height and card size
  Widget _buildCompactMetricsSection(ProductionProvider provider) {
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
      height: 100.h, // Reduced from 140.h
      margin: EdgeInsets.fromLTRB(20.w, 0, 0, 12.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 20.w),
        children: [
          _buildCompactMetricBox(
            title: 'Total Jobs',
            value: total.toString(),
            icon: Icons.inventory_2_rounded,
            primaryColor: const Color(0xFF3B82F6),
            secondaryColor: const Color(0xFFDBEAFE),
            filterKey: 'all',
            isSelected: provider.selectedFilter == 'all',
            provider: provider,
          ),
          _buildCompactMetricBox(
            title: 'Active Jobs',
            value: active.toString(),
            icon: Icons.play_circle_rounded,
            primaryColor: const Color(0xFF10B981),
            secondaryColor: const Color(0xFFD1FAE5),
            filterKey: 'active',
            isSelected: provider.selectedFilter == 'active',
            provider: provider,
          ),
          _buildCompactMetricBox(
            title: 'Paused Jobs',
            value: inactive.toString(),
            icon: Icons.pause_circle_rounded,
            primaryColor: const Color(0xFFF59E0B),
            secondaryColor: const Color(0xFFFEF3C7),
            filterKey: 'inactive',
            isSelected: provider.selectedFilter == 'inactive',
            provider: provider,
          ),
          _buildCompactMetricBox(
            title: 'Created Today',
            value: createdToday.toString(),
            icon: Icons.add_circle_rounded,
            primaryColor: const Color(0xFF8B5CF6),
            secondaryColor: const Color(0xFFEDE9FE),
            filterKey: 'created_today',
            isSelected: provider.selectedFilter == 'created_today',
            provider: provider,
          ),
        ],
      ),
    );
  }

  // Compact Metric Box - Reduced size and padding
  Widget _buildCompactMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required Color primaryColor,
    required Color secondaryColor,
    required String filterKey,
    required bool isSelected,
    required ProductionProvider provider,
  }) {
    return Container(
      width: 110.w, // Reduced from 130.w
      margin: EdgeInsets.only(right: 12.w),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => provider.setFilter(filterKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(14.w), // Reduced from 20.w
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isSelected
                    ? primaryColor.withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 2.w : 1.5.w,
              ),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor.withOpacity(0.08), Colors.white],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? primaryColor.withOpacity(0.15)
                      : const Color(0xFF64748B).withOpacity(0.06),
                  blurRadius: isSelected ? 15.r : 10.r,
                  offset: Offset(0, isSelected ? 4.h : 2.h),
                  spreadRadius: isSelected ? 0 : -1.r,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w), // Reduced from 8.w
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        icon,
                        size: 18.sp,
                        color: primaryColor,
                      ), // Reduced from 22.sp
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h), // Reduced from 12.h
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp, // Reduced from 24.sp
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2.h), // Reduced from 4.h
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp, // Reduced from 13.sp
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
      return _buildErrorState(error);
    }

    if (dprList!.isEmpty) {
      return _buildEmptyState(emptyMessage!);
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      itemCount: dprList.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h), // Reduced from 20.h
      itemBuilder: (context, index) {
        final dpr = dprList[index];
        final provider = Provider.of<ProductionProvider>(
          context,
          listen: false,
        );
        return _buildProductionCard(dpr, provider);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(36.w),
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
            SizedBox(height: 36.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 16.h),
            Material(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  print('Retrying fetchProductionJobOrderByDate');
                  Provider.of<ProductionProvider>(
                    context,
                    listen: false,
                  ).fetchProductionJobOrderByDate();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String emptyMessage) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(40.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF64748B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 48.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Jobs Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionCard(dynamic dpr, ProductionProvider provider) {
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
    final int quantityInNos = dpr is PastDpr ? dpr.quantityInNos : 0;

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

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r), // Reduced from 24.r
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: 20.r,
              offset: Offset(0, 6.h),
              spreadRadius: -3.r,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(plantName, status),
            _buildCardContent(
              workOrder,
              jobOrderId,
              salesOrderNumber,
              machineName,
              startedAt,
              stoppedAt,
              quantityInNos,
              achievedQuantity,
              rejectedQuantity,
              recycledQuantity,
            ),
            _buildActionButtons(dpr, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(String? plantName, Status status) {
    return Container(
      padding: EdgeInsets.all(14.w), // Reduced from 16.w
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.08),
            const Color(0xFF3B82F6).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w), // Reduced from 12.w
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.factory_rounded,
              size: 16.sp, // Reduced from 18.sp
              color: const Color(0xFF3B82F6),
            ),
          ),
          SizedBox(width: 10.w), // Reduced from 12.w
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Production Plant',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  plantName ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          buildStatusBadge(status),
        ],
      ),
    );
  }

  Widget _buildCardContent(
    WorkOrder workOrder,
    String? jobOrderId,
    String? salesOrderNumber,
    String? machineName,
    DateTime? startedAt,
    DateTime? stoppedAt,
    int quantityInNos,
    int achievedQuantity,
    int rejectedQuantity,
    int recycledQuantity,
  ) {
    return Padding(
      padding: EdgeInsets.all(20.w), // Reduced from 24.w
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Work Order Details"),
          SizedBox(height: 12.h), // Reduced from 16.h
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
          SizedBox(height: 20.h), // Reduced from 24.h
          _buildTimelineSection(startedAt, stoppedAt),
          SizedBox(height: 20.h), // Reduced from 24.h
          _buildSectionTitle("Production Metrics"),
          SizedBox(height: 12.h), // Reduced from 16.h
          _buildProductionMetrics(
            quantityInNos,
            achievedQuantity,
            rejectedQuantity,
            recycledQuantity,
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
        _buildSectionTitle("Production Timeline"),
        SizedBox(height: 12.h), // Reduced from 16.h
        Row(
          children: [
            Expanded(
              child: _buildTimelineItem(
                "Started",
                startTime,
                Icons.play_arrow_rounded,
                const Color(0xFF10B981),
              ),
            ),
            SizedBox(width: 12.w), // Reduced from 16.w
            Expanded(
              child: _buildTimelineItem(
                "Stopped",
                endTime,
                Icons.stop_rounded,
                const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String label,
    DateTime? dateTime,
    IconData icon,
    Color color,
  ) {
    print('Building TimelineItem: $label, dateTime: $dateTime');
    return Container(
      padding: EdgeInsets.all(12.w), // Reduced from 16.w
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r), // Reduced from 16.r
        border: Border.all(color: color.withOpacity(0.2), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color), // Reduced from 18.sp
              SizedBox(width: 6.w), // Reduced from 8.w
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp, // Reduced from 13.sp
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h), // Reduced from 12.h
          if (dateTime != null) ...[
            Text(
              DateFormat('MMM dd, yyyy').format(dateTime),
              style: TextStyle(
                fontSize: 13.sp, // Reduced from 14.sp
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 3.h), // Reduced from 4.h
            Text(
              DateFormat('hh:mm a').format(dateTime),
              style: TextStyle(
                fontSize: 11.sp, // Reduced from 12.sp
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ] else
            Text(
              'Not available',
              style: TextStyle(
                fontSize: 13.sp, // Reduced from 14.sp
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    print('Building SectionTitle: $title');
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp, // Reduced from 16.sp
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildInfoGrid(List<Widget> items) {
    print('Building InfoGrid with ${items.length} items');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8, // Increased from 2.5 to make items more compact
        crossAxisSpacing: 12.w, // Reduced from 16.w
        mainAxisSpacing: 12.h, // Reduced from 16.h
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    print('Building DetailItem: $label, value: $value');
    return Container(
      padding: EdgeInsets.all(6.w), // Reduced from 8.w
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r), // Reduced from 12.r
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.7.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp, // Reduced from 11.sp
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 2.h), // Reduced from 4.h
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp, // Reduced from 14.sp
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductionMetrics(
    int quantityInNos,
    int achievedQuantity,
    int rejectedQuantity,
    int recycledQuantity,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.0, // Increased from 1.8 to make items more compact
      crossAxisSpacing: 12.w, // Reduced from 16.w
      mainAxisSpacing: 12.h, // Reduced from 16.h
      children: [
        _buildMetricCard(
          "Quantity In Nos",
          quantityInNos.toString(),
          Icons.assignment_rounded,
          const Color(0xFF3B82F6),
        ),
        _buildMetricCard(
          "Achieved",
          achievedQuantity.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF10B981),
        ),
        _buildMetricCard(
          "Rejected",
          rejectedQuantity.toString(),
          Icons.cancel_rounded,
          const Color(0xFFEF4444),
        ),
        _buildMetricCard(
          "Recycled",
          recycledQuantity.toString(),
          Icons.recycling_rounded,
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w), // Reduced from 12.w
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r), // Reduced from 16.r
        border: Border.all(color: color.withOpacity(0.2), width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: color), // Reduced from 20.sp
              SizedBox(width: 6.w), // Reduced from 8.w
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp, // Reduced from 12.sp
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h), // Reduced from 10.h
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp, // Reduced from 18.sp
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBadge(Status status) {
    print('Building StatusBadge: $status');
    final (color, icon, label) = switch (status) {
      Status.PENDING => (
        const Color(0xFF64748B),
        Icons.schedule_rounded,
        'Pending',
      ),
      Status.IN_PROGRESS => (
        const Color(0xFF10B981),
        Icons.play_circle_rounded,
        'In Progress',
      ),
      Status.PENDING_QC => (
        const Color(0xFF3B82F6),
        Icons.verified_rounded,
        'Pending QC',
      ),
      Status.PAUSED => (
        const Color(0xFFF59E0B),
        Icons.pause_circle_rounded,
        'Paused',
      ),
      Status.COMPLETED => (
        const Color(0xFF64748B),
        Icons.task_alt,
        'Completed',
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r), // Reduced from 12.r
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color), // Reduced from 16.sp
          SizedBox(width: 4.w), // Reduced from 6.w
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp, // Reduced from 12.sp
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.1,
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
    final String? prodId = dpr is PastDpr ? dpr.prodId : dpr.prodId;

    final String? jobOrder = dpr is PastDpr ? dpr.jobOrder : dpr.jobOrder;
    final String? productId = dpr is PastDpr
        ? dpr.productId
        : (dpr.products.isNotEmpty ? dpr.products[0].productId : null);

    final (action, label, icon, color, isEnabled) = switch (status) {
      Status.PENDING => (
        'start',
        'Start',
        Icons.play_arrow_rounded,
        const Color(0xFF10B981),
        true,
      ),
      Status.IN_PROGRESS => (
        'pause',
        'Pause',
        Icons.pause_rounded,
        const Color(0xFFF59E0B),
        true,
      ),
      Status.PAUSED => (
        'resume',
        'Resume',
        Icons.play_arrow_rounded,
        const Color(0xFF10B981),
        true,
      ),
      Status.PENDING_QC => (
        'complete',
        'Complete',
        Icons.check_rounded,
        const Color(0xFF3B82F6),
        false,
      ),
      Status.COMPLETED => (
        'complete',
        'Completed',
        Icons.check_rounded,
        const Color(0xFF64748B),
        false,
      ),
    };

    return Container(
      padding: EdgeInsets.all(20.w), // Reduced from 24.w
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r), // Reduced from 24.r
          bottomRight: Radius.circular(20.r), // Reduced from 24.r
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1.w),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            color: const Color(0xFF3B82F6),
            isEnabled: jobOrder != null && productId != null && prodId != null,
            onPressed: jobOrder != null && productId != null && prodId != null
                ? () async {
                    await provider.updateProduction(
                      productId,
                      jobOrder,
                      prodId,
                    );
                  }
                : null,
          ),
          SizedBox(width: 8.w), // Reduced from 12.w
          _buildActionButton(
            icon: Icons.build_rounded,
            label: 'Downtime',
            color: const Color(0xFF06B6D4),
            isEnabled: jobOrder != null && productId != null && prodId != null,
            onPressed: jobOrder != null && productId != null && prodId != null
                ? () async {
                    await provider.fetchDownTimeLogs(
                      productId,
                      jobOrder,
                      prodId,
                    );
                    GoRouter.of(context).goNamed(
                      RouteNames.downtime,
                      extra: {
                        'productId': productId,
                        'jobOrder': jobOrder,
                        'prodId': prodId,
                      },
                    );
                  }
                : null,
          ),
          SizedBox(width: 8.w), // Reduced from 12.w
          _buildActionButton(
            icon: Icons.history_rounded,
            label: 'Logs',
            color: const Color(0xFF8B5CF6),
            isEnabled: jobOrder != null && productId != null,
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
          SizedBox(width: 8.w), // Reduced from 12.w
          _buildActionButton(
            icon: icon,
            label: label,
            color: color,
            isEnabled:
                isEnabled &&
                jobOrder != null &&
                productId != null &&
                prodId != null,
            isPrimary: true,
            onPressed:
                isEnabled &&
                    jobOrder != null &&
                    productId != null &&
                    prodId != null
                ? () async {
                    try {
                      await provider.performProductionAction(
                        prodId: prodId,
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
    required IconData icon,
    required String label,
    required Color color,
    bool isEnabled = true,
    bool isPrimary = false,
    Future<void> Function()? onPressed,
  }) {
    return Expanded(
      child: Material(
        color: isPrimary && isEnabled
            ? color
            : (isEnabled ? color.withOpacity(0.1) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(12.r), // Reduced from 16.r
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r), // Reduced from 16.r
          onTap: isEnabled
              ? () async {
                  final now = DateTime.now();
                  if (_lastTapTime == null ||
                      now.difference(_lastTapTime!) >
                          const Duration(milliseconds: 500)) {
                    _lastTapTime = now;
                    await onPressed?.call();
                  }
                }
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 8.w,
            ), // Reduced padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.sp, // Reduced from 22.sp
                  color: isPrimary && isEnabled
                      ? Colors.white
                      : (isEnabled ? color : const Color(0xFF94A3B8)),
                ),
                SizedBox(height: 4.h), // Reduced from 6.h
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp, // Reduced from 12.sp
                    fontWeight: FontWeight.w600,
                    color: isPrimary && isEnabled
                        ? Colors.white
                        : (isEnabled ? color : const Color(0xFF94A3B8)),
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    print('Normalizing date: $date');
    return DateTime(date.year, date.month, date.day);
  }
}
