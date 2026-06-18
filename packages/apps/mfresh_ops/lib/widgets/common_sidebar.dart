import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:core/core.dart';
import 'package:services/storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';

class CommonSidebar extends StatelessWidget {
  const CommonSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final userName =
        Get.find<StorageService>().getUser()?.name ?? 'Ops Manager';

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.person,
                      size: 40.r,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    userName,
                    style: AppTextStyle.style_18_600(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final authRepo = Get.find<AuthRepository>();
            if (!authRepo.rxUserPermissions.contains('duty_punch')) {
              return const SizedBox.shrink();
            }
            final isTracking = TrackingService.to.isTracking.value;
            return Container(
              color: isTracking
                  ? const Color(0xFF10B981).withValues(alpha: 0.05)
                  : Colors.red.withValues(alpha: 0.05),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTracking ? const Color(0xFF10B981) : Colors.red,
                      boxShadow: isTracking
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                blurRadius: 6.r,
                                spreadRadius: 2.r,
                              )
                            ]
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTracking ? 'ON DUTY' : 'OFF DUTY',
                          style: AppTextStyle.style_14_700(
                            color: isTracking ? const Color(0xFF10B981) : Colors.red,
                          ),
                        ),
                        Text(
                          isTracking ? 'Location sharing active' : 'Offline. Tap to start.',
                          style: AppTextStyle.style_10_400(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isTracking,
                    activeTrackColor: const Color(0xFF10B981),
                    activeThumbColor: Colors.white,
                    onChanged: (val) {
                      TrackingService.to.toggleTracking();
                    },
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final authRepo = Get.find<AuthRepository>();
              final userPermissions = authRepo.rxUserPermissions;
              final showInventory = userPermissions.contains('inventory_panel');
              
              final showTaskScheduler = userPermissions.contains('Task_Sheduler_Pannel');
              final taskSubItems = [
                if (userPermissions.contains('All_Task')) 'All Task',
                if (userPermissions.contains('Daily_Task')) 'Daily Task',
              ];
              
              final inventorySubItems = [
                if (userPermissions.contains('store_inventory_stock'))
                  'Store Inventory',
                if (userPermissions.contains('unit_inventory_stock'))
                  'Unit Inventory',
                if (userPermissions.contains('consumption_report'))
                  'Consumption',
                if (userPermissions.contains('allotments_report'))
                  'Allotments',
                if (userPermissions.contains('measurements_panel'))
                  'M_Measurements',
                if (userPermissions.contains('inventory_item'))
                  'M_Items',
                if (userPermissions.contains('store_room'))
                  'M_Store',
              ];

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Home',
                    route: AppRoutes.home,
                    currentRoute: currentRoute,
                  ),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    title: 'Profile',
                    route: AppRoutes.profile,
                    currentRoute: currentRoute,
                  ),

                  // Tracking Expandable Section
                  if (userPermissions.contains('tracking_panel'))
                    _buildExpandableMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Tracking',
                      subItems: [
                        'My Routes',
                        'Staff Tracking',
                      ],
                      currentRoute: currentRoute,
                    ),

                  _buildExpandableMenuItem(
                    icon: Icons.support_agent_outlined,
                    title: 'Support Ticket',
                    subItems: [
                      'Support Ticket',
                    ],
                    currentRoute: currentRoute,
                  ),

                  // Task Scheduler Expandable Section
                  if (showTaskScheduler && taskSubItems.isNotEmpty)
                    _buildExpandableMenuItem(
                      icon: Icons.task_alt_outlined,
                      title: 'Task Scheduler',
                      subItems: taskSubItems,
                      currentRoute: currentRoute,
                    ),

                  // Inventory Expandable Section
                  if (showInventory && inventorySubItems.isNotEmpty)
                    _buildExpandableMenuItem(
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory',
                      subItems: inventorySubItems,
                      currentRoute: currentRoute,
                    ),
                ],
              );
            }),
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.logout_outlined,
            activeIcon: Icons.logout,
            title: 'Logout',
            route: AppRoutes.login,
            currentRoute: currentRoute,
            onTap: () async {
              try {
                await Get.find<AuthRepository>().logout();
              } catch (e) {
                // Already handled in repository but we can show toast if needed
              }
              Get.offAllNamed(AppRoutes.login);
            },
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
                child: Text(
                  'Version $version',
                  style: AppTextStyle.style_14_500(color: AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required String currentRoute,
    VoidCallback? onTap,
  }) {
    final bool isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? AppColors.primary : AppColors.grey300,
      ),
      title: Text(
        title,
        style: isSelected
            ? AppTextStyle.style_16_600(color: AppColors.primary)
            : AppTextStyle.style_16_500(color: AppColors.black),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      onTap:
          onTap ??
          () {
            if (!isSelected) {
              Get.back(); // Close drawer
              Get.toNamed(route);
            } else {
              Get.back(); // Close drawer
            }
          },
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required List<String> subItems,
    required String currentRoute,
  }) {
    // Determine if any sub-item is active (not applicable yet)
    final bool isExpanded = false;

    return Theme(
      data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.grey300, size: 24.r),
        title: Text(
          title,
          style: AppTextStyle.style_16_500(color: AppColors.black),
        ),
        iconColor: AppColors.grey300,
        collapsedIconColor: AppColors.grey300,
        initiallyExpanded: isExpanded,
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
        children: subItems
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.only(left: 72.w),
                visualDensity: VisualDensity.compact,
                title: Text(
                  item,
                  style: AppTextStyle.style_14_400(color: AppColors.black),
                ),
                onTap: () {
                  Get.back(); // Close drawer
                  if (item == 'Support Ticket Dashboard') {
                    Get.toNamed(AppRoutes.supportDashboard);
                  } else if (item == 'Support Ticket') {
                    Get.toNamed(AppRoutes.supportTickets);
                  } else if (item == 'M_Category') {
                    Get.toNamed(AppRoutes.supportCategory);
                  } else if (item == 'M_Sub Category') {
                    Get.toNamed(AppRoutes.supportSubCategory);
                  } else if (item == 'M_Projects') {
                    Get.toNamed(AppRoutes.supportProjects);
                  } else if (item == 'M_Template') {
                    Get.toNamed(AppRoutes.supportTemplate);
                  } else if (item == 'All Task') {
                    Get.toNamed(AppRoutes.allTasks);
                  } else if (item == 'Daily Task') {
                    Get.toNamed(AppRoutes.dailyTasks);
                  } else if (item == 'My Routes') {
                    Get.toNamed(AppRoutes.liveTracking);
                  } else if (item == 'Staff Tracking') {
                    Get.toNamed(AppRoutes.staffTracking);
                  } else if (item == 'Store Inventory') {
                    Get.toNamed(AppRoutes.storeInventory);
                  } else if (item == 'Unit Inventory') {
                    Get.toNamed(AppRoutes.unitInventory);
                  } else if (item == 'Consumption') {
                    Get.toNamed(AppRoutes.allConsumption);
                  } else if (item == 'Allotments') {
                    Get.toNamed(AppRoutes.allotments);
                  } else if (item == 'M_Measurements') {
                    Get.toNamed(AppRoutes.measurements);
                  } else if (item == 'M_Items') {
                    Get.toNamed(AppRoutes.items);
                  } else if (item == 'M_Store') {
                    Get.toNamed(AppRoutes.storeRooms);
                  } else {
                    AppCommonToastMessage.show(
                      message: '$item screen coming soon',
                      type: ToastType.info,
                    );
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
