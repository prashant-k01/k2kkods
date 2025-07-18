import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/common/widgets/menu_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      drawer: const EnhancedMenuDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(top: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsRow(),
                              SizedBox(height: 30.h),
                              _buildWorkOrderStatus(),
                            ],
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
      ),
    );
  }

Widget _buildAppBar() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
    child: Row(
      children: [
        // Left: Menu Button
        _buildMenuButton(),
        
        // Center: Logo (Centered by Spacer on both sides)
        Expanded(
          child: Center(child: _buildLogoAndTitle()),
        ),

        // Right: Notification Bell
        _buildActionButtons(),
      ],
    ),
  );
}

  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
      ),
    );
  }

Widget _buildLogoAndTitle() {
  return Container(
    width: 140.w, // Wider
    height: 56.h, // Taller
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        'assets/images/login_image_1.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.precision_manufacturing_outlined,
              color: Colors.white,
              size: 32.sp,
            ),
          );
        },
      ),
    ),
  );
}


  Widget _buildActionButtons() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 15.w),
      ],
    );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useColumnLayout = constraints.maxWidth < 800.w;
        if (useColumnLayout) {
          return Column(
            children: [
              _buildMainStatCard(),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Work Order Achieved',
                      value: '00',
                      subtitle: 'this week',
                      progress: 0.0,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Job Orders Achieved',
                      value: '00',
                      subtitle: 'this week',
                      progress: 0.0,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _buildMainStatCard()),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Work Order Achieved',
                  value: '00',
                  subtitle: 'this week',
                  progress: 0.0,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Job Orders Achieved',
                  value: '00',
                  subtitle: 'this week',
                  progress: 0.0,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildMainStatCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total Work Orders...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '+00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Report Generation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: const Color(0xFF22C55E),
                size: 16.sp,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderStatus() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Work Order Status',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          LayoutBuilder(
            builder: (context, constraints) {
              bool useColumnLayout = constraints.maxWidth < 600.w;
              if (useColumnLayout) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            'Total',
                            '00',
                            const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: _buildStatusItem(
                            'Complete',
                            '00',
                            const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            'Pending',
                            '00',
                            const Color(0xFFEF4444),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: _buildStatusItem(
                            'In Progress',
                            '00',
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    _buildStatusItem('Total', '00', const Color(0xFF6B7280)),
                    SizedBox(width: 40.w),
                    _buildStatusItem('Complete', '00', const Color(0xFF3B82F6)),
                    SizedBox(width: 40.w),
                    _buildStatusItem('Pending', '00', const Color(0xFFEF4444)),
                    SizedBox(width: 40.w),
                    _buildStatusItem(
                      'In Progress',
                      '00',
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
