import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';
import 'package:k2k/app/routes_name.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<SubMenuItem>? subItems;
  final String? logoPath;
  bool isExpanded;
  bool isSelected;

  MenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
    this.logoPath,
    this.isExpanded = false,
    this.isSelected = false,
  });
}

class SubMenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<SubMenuItem>? subItems;
  bool isExpanded;
  bool isSelected;

  SubMenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
    this.isExpanded = false,
    this.isSelected = false,
  });
}

class EnhancedMenuDrawer extends StatefulWidget {
  const EnhancedMenuDrawer({super.key});

  @override
  State<EnhancedMenuDrawer> createState() => _EnhancedMenuDrawerState();
}

class _EnhancedMenuDrawerState extends State<EnhancedMenuDrawer>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _bounceController;
  late AnimationController _slideController;
  late Animation<double> _logoAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;

  String currentLogo = 'assets/images/login_image_1.png';
  int selectedModuleIndex = 0;

  List<MenuItem> mainModules = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: '/homescreen',
      logoPath: 'assets/images/login_image_1.png',
    ),
    MenuItem(
      title: 'Falcon Facade',
      icon: Icons.precision_manufacturing_rounded,
      logoPath: 'assets/images/falcon.png',
      subItems: [
        SubMenuItem(title: 'Work Order', icon: Icons.work_outline_rounded),
        SubMenuItem(
          title: 'Job Order',
          icon: Icons.assignment_turned_in_rounded,
        ),
        SubMenuItem(
          title: 'Internal Work Order',
          icon: Icons.engineering_rounded,
        ),
        SubMenuItem(title: 'Production', icon: Icons.factory_rounded),
        SubMenuItem(title: 'Packing', icon: Icons.inventory_rounded),
        SubMenuItem(title: 'Dispatch', icon: Icons.local_shipping_rounded),
        SubMenuItem(title: 'QC Check', icon: Icons.verified_user_rounded),
        SubMenuItem(
          title: 'Master Data',
          icon: Icons.settings_applications_rounded,
          subItems: [
            SubMenuItem(title: 'Master Clients', icon: Icons.business_rounded),
            SubMenuItem(title: 'Master Products', icon: Icons.category_rounded),
          ],
        ),
      ],
    ),
    MenuItem(
      title: 'Konkrete Klinkers',
      icon: Icons.construction_rounded,
      logoPath: 'assets/images/konkrete_klinkers.png',
      subItems: [
        SubMenuItem(
          title: 'Work Orders',
          icon: Icons.work_outline_rounded,
          route: RouteNames.workorders,
        ),
        SubMenuItem(
          title: 'Job Order/Planning',
          icon: Icons.event_note_rounded,
          route: RouteNames.jobOrder,
        ),
        SubMenuItem(
          title: 'Production',
          icon: Icons.precision_manufacturing_rounded,
          route: RouteNames.production,
        ),
        SubMenuItem(
          title: 'QC Check',
          icon: Icons.fact_check_rounded,
          route: RouteNames.qcCheck,
        ),
        SubMenuItem(
          title: 'Packing',
          icon: Icons.all_inbox_rounded,
          route: RouteNames.packing,
        ),
        SubMenuItem(
          title: 'Dispatch',
          icon: Icons.local_shipping_rounded,
          route: RouteNames.dispatch,
        ),
        SubMenuItem(
          title: 'Inventory',
          icon: Icons.inventory_2_rounded,
          route: RouteNames.inventory,
        ),
        SubMenuItem(
          title: 'Stock Management',
          icon: Icons.storage_rounded,
          route: RouteNames.stockmanagement,
        ),
        SubMenuItem(
          title: 'Master Data',
          icon: Icons.dataset_rounded,
          subItems: [
            SubMenuItem(
              title: 'Plants',
              icon: Icons.domain_rounded,
              route: RouteNames.plants,
            ),
            SubMenuItem(
              title: 'Machines',
              icon: Icons.settings_rounded,
              route: RouteNames.machines,
            ),
            SubMenuItem(
              title: 'Clients',
              icon: Icons.people_rounded,
              route: RouteNames.clients,
            ),
            SubMenuItem(
              title: 'Projects',
              icon: Icons.folder_special_rounded,
              route: RouteNames.projects,
            ),
            SubMenuItem(
              title: 'Products',
              icon: Icons.inventory_2_rounded,
              route: RouteNames.products,
            ),
          ],
        ),
      ],
    ),
    MenuItem(
      title: 'Iron Smith',
      icon: Icons.hardware_rounded,
      logoPath: 'assets/images/iron_smith.png',
      subItems: [
        SubMenuItem(
          title: 'Work Order',
          icon: Icons.work_history_rounded,
          route: RouteNames.getAllIronWO,
        ),
        SubMenuItem(
          title: 'Job Order',
          icon: Icons.assignment_rounded,
          route: RouteNames.ironJobOrder,
        ),
        SubMenuItem(title: 'Production', icon: Icons.build_circle_rounded),
        SubMenuItem(title: 'QC Check', icon: Icons.rule_rounded),
        SubMenuItem(title: 'Packing', icon: Icons.move_to_inbox_rounded),
        SubMenuItem(title: 'Dispatch', icon: Icons.fire_truck_rounded),
        SubMenuItem(
          title: 'Dispatch Invoice',
          icon: Icons.receipt_long_rounded,
        ),
        SubMenuItem(title: 'Inventory', icon: Icons.warehouse_rounded),
        SubMenuItem(
          title: 'Master Data',
          icon: Icons.admin_panel_settings_rounded,
          subItems: [
            SubMenuItem(
              title: 'Machines',
              icon: Icons.precision_manufacturing_rounded,
              route: RouteNames.ismachine,
            ),
            SubMenuItem(
              title: 'Clients',
              icon: Icons.account_circle_rounded,
              route: RouteNames.isclients,
            ),
            SubMenuItem(
              title: 'Projects',
              icon: Icons.web_stories_rounded,
              route: RouteNames.isProjects,
            ),
            SubMenuItem(
              title: 'Shapes',
              icon: Icons.architecture_rounded,
              route: RouteNames.allshapes,
            ),
          ],
        ),
      ],
    ),
    MenuItem(
      title: 'Users',
      icon: Icons.group_rounded,
      subItems: [
        SubMenuItem(
          title: 'User Management',
          icon: Icons.manage_accounts_rounded,
          route: '/settings/users',
        ),
        SubMenuItem(title: 'Roles & Permissions', icon: Icons.security_rounded),
        SubMenuItem(
          title: 'Access Control',
          icon: Icons.admin_panel_settings_rounded,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start initial animations
    _logoAnimationController.forward();
    _slideController.forward();

    // Set Dashboard as selected initially
    mainModules[0].isSelected = true;
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _bounceController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectModule(int index) {
    if (selectedModuleIndex == index) return;

    setState(() {
      // Deselect all modules first
      for (var module in mainModules) {
        module.isSelected = false;
        module.isExpanded = false;
      }

      // Select current module
      selectedModuleIndex = index;
      mainModules[index].isSelected = true;

      // Update logo if module has one
      if (mainModules[index].logoPath != null) {
        currentLogo = mainModules[index].logoPath!;
      }
    });

    // Trigger bounce animation
    _bounceController.reset();
    _bounceController.forward();

    // Restart logo animation for visual feedback
    _logoAnimationController.reset();
    _logoAnimationController.forward();
  }

  void _toggleModuleExpansion(int index) {
    setState(() {
      mainModules[index].isExpanded = !mainModules[index].isExpanded;
    });

    if (mainModules[index].isExpanded) {
      _selectModule(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 320.w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F), // Deep black
              Color(0xFF1A1A1A), // Slightly lighter black
              Color(0xFF0F0F0F), // Back to deep black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: Column(
            children: [
              // Enhanced Logo Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value * _bounceAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              currentLogo,
                              width: 160.w,
                              height: 50.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    'INDUSTRIAL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Main Module Navigation
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    itemCount: mainModules.length,
                    itemBuilder: (context, index) {
                      final module = mainModules[index];
                      return _buildMainModuleItem(module, index);
                    },
                  ),
                ),
              ),

              // Premium Logout Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        confirmLogout(context);
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.power_settings_new_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
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

  Widget _buildMainModuleItem(MenuItem module, int index) {
    final isSelected = module.isSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              )
            : null,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (module.subItems != null) {
                  _toggleModuleExpansion(index);
                } else {
                  _selectModule(index);
                  Navigator.pop(context);
                  if (module.route != null) {
                    context.push(module.route!);
                  }
                }
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        module.icon,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        module.title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 16.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (module.subItems != null)
                      AnimatedRotation(
                        turns: module.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isSelected ? Colors.white : Colors.white60,
                          size: 24.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Sub-items with smooth expansion
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: module.subItems != null
                ? Container(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 12.h,
                    ),
                    child: Column(
                      children: module.subItems!
                          .map((subItem) => _buildSubMenuItem(subItem))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
            crossFadeState: module.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 400),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(SubMenuItem subItem) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print(
                  'Tapped SubMenuItem: ${subItem.title}, has subItems: ${subItem.subItems != null}',
                );
                if (subItem.subItems != null && subItem.subItems!.isNotEmpty) {
                  setState(() {
                    subItem.isExpanded = !subItem.isExpanded;
                  });
                } else {
                  Navigator.pop(context);
                  if (subItem.route != null) {
                    context.push(subItem.route!);
                  }
                }
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        subItem.icon,
                        color: Colors.white70,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        subItem.title,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (subItem.subItems != null)
                      AnimatedRotation(
                        turns: subItem.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white60,
                          size: 20.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Nested sub-items with smooth expansion
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: subItem.subItems != null && subItem.subItems!.isNotEmpty
              ? Container(
                  padding: EdgeInsets.only(
                    left: 32.w, // Indent nested sub-items further
                    right: 16.w,
                    bottom: 12.h,
                  ),
                  child: Column(
                    children: subItem.subItems!
                        .map(
                          (nestedSubItem) => _buildSubMenuItem(nestedSubItem),
                        )
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
          crossFadeState: subItem.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 400),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}
