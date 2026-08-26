import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class CommonShortcutHeader extends StatelessWidget implements PreferredSizeWidget {
  const CommonShortcutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(
            builder: (context) => InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(Icons.menu, color: AppColors.black, size: 24.sp),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  if (Get.currentRoute != AppRoutes.home) {
                    Get.offAllNamed(AppRoutes.home);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppImages.logo,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'mFresh Ops',
                        style: AppTextStyle.style_14_700(color: AppColors.primaryOrange),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            final authRepo = Get.find<AuthRepository>();
            final userPermissions = authRepo.rxUserPermissions;
            if (!userPermissions.contains('header_ticket_btn')) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _buildShortcutButton(
                label: 'Ticket',
                onTap: () {
                  if (Get.currentRoute != AppRoutes.supportTickets) {
                    Get.toNamed(AppRoutes.supportTickets);
                  }
                },
                color: const Color(0xFFE3F2FD),
                textColor: const Color(0xFF1976D2),
              ),
            );
          }),
          Obx(() {
            final authRepo = Get.find<AuthRepository>();
            final userPermissions = authRepo.rxUserPermissions;
            if (!userPermissions.contains('header_task_btn')) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _buildShortcutButton(
                label: 'Tasks',
                onTap: () {
                  if (Get.currentRoute != AppRoutes.dailyTasks) {
                    Get.toNamed(AppRoutes.dailyTasks);
                  }
                },
                color: const Color(0xFFF3E5F5),
                textColor: const Color(0xFF7B1FA2),
              ),
            );
          }),
          _buildShortcutIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              if (Get.currentRoute != AppRoutes.notifications) {
                Get.toNamed(AppRoutes.notifications);
              }
            },
            color: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFE65100),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: AppTextStyle.style_12_600(color: textColor),
        ),
      ),
    );
  }

  Widget _buildShortcutIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(45.h);
}
