import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:services/services.dart';
import 'package:core/core.dart' hide AppRoutes;

class CommonSidebar extends StatelessWidget {
  const CommonSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.white,
                    child: Icon(Icons.person, size: 40.r, color: AppColors.primary),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Ops Manager',
                    style: AppTextStyle.style_18_600(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
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
                _buildExpandableMenuItem(
                  icon: Icons.task_outlined,
                  title: 'Task Scheduler',
                  subItems: [
                    'All Task',
                    'Daily Task',
                  ],
                  currentRoute: currentRoute,
                ),
                _buildExpandableMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Support Ticket',
                  subItems: [
                    'Support Ticket Dashboard',
                    'Support Ticket',
                    'M_Category',
                    'M_Sub Category',
                    'M_Projects',
                  ],
                  currentRoute: currentRoute,
                ),
                
                // Inventory Expandable Section
                _buildExpandableMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  subItems: [
                    'Store Inventory',
                    'Unit Inventory',
                    'Consumption',
                    'Allotments',
                    'M_Measurements',
                    'M_Items',
                    'M_Store',
                  ],
                  currentRoute: currentRoute,
                ),
              ],
            ),
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
          SizedBox(height: 20.h),
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
      onTap: onTap ?? () {
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
      data: Theme.of(Get.context!).copyWith(
        dividerColor: Colors.transparent,
      ),
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
        children: subItems.map((item) => ListTile(
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
            } else if (item == 'All Task') {
              Get.toNamed(AppRoutes.allTasks);
            } else if (item == 'Daily Task') {
              Get.toNamed(AppRoutes.dailyTasks);
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
        )).toList(),
      ),
    );
  }
}
