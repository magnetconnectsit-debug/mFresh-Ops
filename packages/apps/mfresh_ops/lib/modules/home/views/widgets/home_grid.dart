import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

    final List<GridItemData> allItems = [
      GridItemData(
        title: 'Support Ticket',
        subtitle: 'Manage helpdesk',
        icon: Icons.support_agent_rounded,
        gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        route: AppRoutes.supportTickets,
        permissionKey: 'maintenance_panel',
      ),
      GridItemData(
        title: 'Task Scheduler',
        subtitle: 'Daily operations',
        icon: Icons.assignment_rounded,
        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        route: null,
        permissionKey: 'Task_Sheduler_Pannel',
      ),
      GridItemData(
        title: 'Inventory',
        subtitle: 'Stock & Items',
        icon: Icons.inventory_2_rounded,
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
        route: null,
        permissionKey: 'inventory_panel',
      ),
      GridItemData(
        title: 'Reports',
        subtitle: 'Analytics & Export',
        icon: Icons.analytics_rounded,
        gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        route: null,
        permissionKey: 'Report_Pannel',
      ),
    ];

    final items = allItems.where((item) {
      if (item.permissionKey == null) return true;
      return userPermissions.contains(item.permissionKey);
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.r,
        mainAxisSpacing: 16.r,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return _buildGridCard(items[index]);
      },
    );
    });
  }

  Widget _buildGridCard(GridItemData item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: item.gradient.first.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: () {
            if (item.route != null) {
              Get.toNamed(item.route!);
            } else {
              AppCommonToastMessage.show(
                message: '${item.title} is comming soon....',
                type: ToastType.info,
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      color: item.gradient.first.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 28.r),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyle.style_14_700(
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.subtitle,
                              style: AppTextStyle.style_10_400(
                                color: AppColors.grey300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? route;
  final String? permissionKey;

  GridItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.route,
    this.permissionKey,
  });
}
