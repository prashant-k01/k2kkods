import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<SubMenuItem>? subItems;
  bool isExpanded;

  MenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
    this.isExpanded = false,
  });
}

class SubMenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<SubMenuItem>? subItems; // Added nested sub-items support
  bool isExpanded;

  SubMenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
    this.isExpanded = false,
  });
}

class MenuSection {
  final String? heading;
  final List<MenuItem> items;

  MenuSection({this.heading, required this.items});
}

class EnhancedMenuDrawer extends StatefulWidget {
  const EnhancedMenuDrawer({super.key});

  @override
  State<EnhancedMenuDrawer> createState() => _EnhancedMenuDrawerState();
}

class _EnhancedMenuDrawerState extends State<EnhancedMenuDrawer>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;

  List<MenuSection> menuSections = [
    // Main Dashboard Section
    MenuSection(
      heading: null,
      items: [
        MenuItem(
          title: 'Dashboard',
          icon: Icons.dashboard_outlined,
          route: '/homescreen',
        ),
      ],
    ),
    // Data Management Section
    MenuSection(
      heading: "FALCON FACADE",
      items: [
        MenuItem(title: 'Work Order', icon: Icons.work_outline),
        MenuItem(title: 'Job Order', icon: Icons.work_outline),
        MenuItem(title: 'Internal Work Order', icon: Icons.assignment_outlined),
        MenuItem(title: 'Production', icon: Icons.assignment_outlined),
        MenuItem(title: 'Packing', icon: Icons.assignment_outlined),
        MenuItem(title: 'Dispatch', icon: Icons.assignment_outlined),
        MenuItem(title: 'QC check', icon: Icons.assignment_outlined),
        MenuItem(
          title: 'Master Data',
          icon: Icons.settings_outlined,
          subItems: [
            SubMenuItem(
              title: 'Master Clients',
              icon: Icons.factory_outlined,
              route: '/settings/plant',
              isExpanded: false,
              subItems: [
                SubMenuItem(
                  title: 'Client',
                  icon: Icons.add_business,
                  route: '/settings/plant/add-client',
                  isExpanded: false,
                ),
                SubMenuItem(
                  title: 'Projects',
                  icon: Icons.file_copy_sharp,
                  route: '/settings/plant/view-clients',
                  isExpanded: false,
                ),
              ],
            ),
            SubMenuItem(
              title: 'Master Products',
              icon: Icons.inventory,
              route: '/settings/users',
              isExpanded: false,
              subItems: [
                SubMenuItem(
                  title: 'Systems',
                  icon: Icons.add_box,
                  route: '/settings/products/add',
                  isExpanded: false,
                ),
                SubMenuItem(
                  title: 'Product Systems',
                  icon: Icons.category,
                  route: '/settings/products/categories',
                  isExpanded: false,
                ),
                SubMenuItem(
                  title: 'Products',
                  icon: Icons.inventory_2,
                  route: '/settings/products/inventory',
                  isExpanded: false,
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    MenuSection(
      heading: "KONKRETE KLINKERS",
      items: [
        MenuItem(
          title: 'Work Orders',
          icon: Icons.person_outline,
          route: '/profile',
        ),
        MenuItem(
          title: 'Job Order/Planning',
          icon: Icons.shopping_bag_outlined,
          route: '/productexplore',
        ),
        MenuItem(
          title: 'Production',
          icon: Icons.bookmarks_outlined,
          route: '/my-bookings',
        ),
        MenuItem(
          title: 'QC Check',
          icon: Icons.miscellaneous_services_outlined,
          route: '/myservices',
        ),
        MenuItem(
          title: 'Packing',
          icon: Icons.shopping_cart_outlined,
          route: '/cart',
        ),
        MenuItem(
          title: 'Dispatch',
          icon: Icons.shopping_cart_outlined,
          route: '/cart',
        ),
        MenuItem(
          title: 'Inventory',
          icon: Icons.shopping_cart_outlined,
          route: '/cart',
        ),
        MenuItem(
          title: 'Stock Management',
          icon: Icons.shopping_cart_outlined,
          route: '/cart',
        ),
        MenuItem(
          title: "Master Data",
          icon: Icons.file_copy_outlined,
          subItems: [
            SubMenuItem(
              title: 'Plants',
              icon: Icons.factory_outlined,
              route: '',
              isExpanded: false,
              subItems: [
                SubMenuItem(
                  title: 'Plants',
                  icon: Icons.add_business,
                  route: RouteNames.plants,
                  isExpanded: false,
                ),
                SubMenuItem(
                  title: 'Machines',
                  icon: Icons.visibility,
                  route: '/settings/plant/view-clients',
                  isExpanded: false,
                ),
              ],
            ),
            SubMenuItem(
              title: 'Clients',
              icon: Icons.person_outline_rounded,
              route: RouteNames.clients,
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Projects',
              icon: Icons.assignment_outlined,
              route: RouteNames.projects,
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Products',
              icon: Icons.inventory_2_outlined,
              route: RouteNames.products,
              isExpanded: false,
            ),
          ],
        ),
      ],
    ),

    MenuSection(
      heading: "IRON SMITH",
      items: [
        MenuItem(title: 'Work Order', icon: Icons.work_outline),
        MenuItem(title: 'Job Order/planning', icon: Icons.assignment_outlined),
        MenuItem(title: 'Production', icon: Icons.assignment_outlined),
        MenuItem(title: 'QC Check', icon: Icons.assignment_outlined),
        MenuItem(title: 'Packing', icon: Icons.assignment_outlined),
        MenuItem(title: 'Dispatch', icon: Icons.assignment_outlined),
        MenuItem(title: 'Dispatch Invoice', icon: Icons.assignment_outlined),
        MenuItem(title: 'Inventory', icon: Icons.assignment_outlined),
        MenuItem(
          title: 'Master Data',
          icon: Icons.assignment_outlined,
          subItems: [
            SubMenuItem(
              title: 'Machines',
              icon: Icons.factory_outlined,
              route: '/settings/plant',
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Clients',
              icon: Icons.add_business,
              route: '/settings/plant/add-client',
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Projects',
              icon: Icons.visibility,
              route: '/settings/plant/view-clients',
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Shapes',
              icon: Icons.visibility,
              route: '/settings/plant/view-clients',
              isExpanded: false,
            ),
          ],
        ),
      ],
    ),
    MenuSection(
      heading: "USERS",
      items: [
        MenuItem(
          title: 'Users',
          icon: Icons.work_outline,
          route: '/settings/users',
          subItems: [
            SubMenuItem(
              title: 'Users',
              icon: Icons.supervised_user_circle_outlined,
              route: '/settings/plant',
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Clients',
              icon: Icons.add_business,
              route: '/settings/plant/add-client',
              isExpanded: false,
            ),
            SubMenuItem(
              title: 'Projects',
              icon: Icons.file_copy_sharp,
              route: '/settings/plant/view-clients',
              isExpanded: false,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SizedBox(
        width: 300.w,
        child: Drawer(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Column(
            children: [
              // Logo Section - Reduced padding
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Image.asset(
                        'assets/images/login_image_1.png',
                        width: 140.w,
                        height: 40.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.precision_manufacturing_outlined,
                            size: 28.sp,
                            color: Colors.white,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Menu Sections - Reduced spacing
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  itemCount: menuSections.length,
                  itemBuilder: (context, sectionIndex) {
                    final section = menuSections[sectionIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Heading - Reduced spacing
                        if (section.heading != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            margin: EdgeInsets.only(
                              top: sectionIndex == 0 ? 0 : 8.h,
                            ),
                            child: Text(
                              section.heading!,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        // Section Items
                        ...section.items
                            .map((item) => _buildMenuItem(item, isDark, 0))
                            .toList(),
                      ],
                    );
                  },
                ),
              ),

              // Logout Button
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Add logout functionality
                        // context.go('/login');
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildMenuItem(MenuItem item, bool isDark, int level) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: item.isExpanded
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: item.isExpanded
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                item.icon,
                color: item.isExpanded
                    ? const Color(0xFF3B82F6)
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                size: 18.sp,
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: item.isExpanded
                    ? const Color(0xFF3B82F6)
                    : (isDark ? Colors.white : Colors.grey.shade800),
                fontSize: 15.sp,
                fontWeight: item.isExpanded ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            trailing: item.subItems != null
                ? AnimatedRotation(
                    turns: item.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      size: 18.sp,
                    ),
                  )
                : null,
            onTap: () {
              if (item.subItems != null) {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              } else {
                Navigator.pop(context);
                if (item.route != null) {
                  context.push(item.route!);
                }
                FocusScope.of(context).unfocus();
              }
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 2.h,
            ),
            dense: true,
          ),
        ),
        if (item.subItems != null && item.isExpanded)
          Container(
            margin: EdgeInsets.only(left: 16.w, right: 6.w),
            child: Column(
              children: item.subItems!
                  .map(
                    (subItem) => _buildSubMenuItem(subItem, isDark, level + 1),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(SubMenuItem subItem, bool isDark, int level) {
    double leftPadding = (level * 12.0).w;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 1.h),
          decoration: BoxDecoration(
            color: subItem.isExpanded
                ? (isDark
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade100)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: subItem.isExpanded
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : const Color(0xFF3B82F6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                subItem.icon,
                color: subItem.isExpanded
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF3B82F6).withOpacity(0.7),
                size: 14.sp,
              ),
            ),
            title: Text(
              subItem.title,
              style: TextStyle(
                color: subItem.isExpanded
                    ? const Color(0xFF3B82F6)
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                fontSize: 14.sp,
                fontWeight: subItem.isExpanded
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            trailing: subItem.subItems != null
                ? AnimatedRotation(
                    turns: subItem.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      size: 16.sp,
                    ),
                  )
                : null,
            onTap: () {
              if (subItem.subItems != null) {
                setState(() {
                  subItem.isExpanded = !subItem.isExpanded;
                });
              } else {
                Navigator.pop(context);
                if (subItem.route != null) {
                  context.push(subItem.route!);
                }
                FocusScope.of(context).unfocus();
              }
            },
            contentPadding: EdgeInsets.only(
              left: leftPadding,
              right: 8.w,
              top: 1.h,
              bottom: 1.h,
            ),
            dense: true,
          ),
        ),
        // Nested sub-items
        if (subItem.subItems != null && subItem.isExpanded)
          Container(
            margin: EdgeInsets.only(left: 12.w),
            child: Column(
              children: subItem.subItems!
                  .map(
                    (nestedSubItem) =>
                        _buildSubMenuItem(nestedSubItem, isDark, level + 1),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
