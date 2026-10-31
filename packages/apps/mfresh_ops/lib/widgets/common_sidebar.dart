// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:services/storage_service.dart';
// endregion

// region CommonSidebar Widget
class CommonSidebar extends StatelessWidget {
  const CommonSidebar({super.key});

  // region Helpers
  bool _hasPerm(String key) {
    if (!Get.isRegistered<AuthRepository>()) return false;
    return AppPermissions.has(
      Get.find<AuthRepository>().rxUserPermissions,
      key,
    );
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final user = Get.find<StorageService>().getUser();
    final userName = user?.name ?? 'Ops Manager';
    final userRole =
        (user?.roleName != null && user!.roleName!.trim().isNotEmpty)
        ? user.roleName!
        : 'Operations Team';
    final userImageUrl = user?.imageUrl;
    final topPadding = MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              final authRepo = Get.find<AuthRepository>();
              final userPermissions = authRepo.rxUserPermissions;
              bool hasPerm(String key) =>
                  AppPermissions.has(userPermissions, key);

              final supportTicketSubItems = [
                // if (hasPerm(AppPermissions.supportTicketDashboard))
                //   'Support Ticket Dashboard',
                if (hasPerm(AppPermissions.maintenancePanel)) 'Support Ticket',
                if (hasPerm(AppPermissions.mTemplate)) 'M_Template',
                if (hasPerm(AppPermissions.mProjects)) 'M_Projects',
                if (hasPerm(AppPermissions.mSubCategory)) 'M_Sub Category',
                if (hasPerm(AppPermissions.maintenanceCategory)) 'M_Category',
              ];

              final showTaskScheduler = hasPerm(
                AppPermissions.taskSchedulerPanel,
              );
              final taskSubItems = [
                if (hasPerm(AppPermissions.allTask)) 'All Task',
                if (hasPerm(AppPermissions.dailyTask)) 'Daily Task',
                if (hasPerm(AppPermissions.dailyTaskByMonth))
                  'Daily Task By Month',
              ];

              final showInventory = hasPerm(AppPermissions.inventoryPanel);
              final inventorySubItems = [
                if (hasPerm(AppPermissions.storeInventoryStock))
                  'Store Inventory',
                if (hasPerm(AppPermissions.unitInventoryStock))
                  'Unit Inventory',
                if (hasPerm(AppPermissions.invOrderPanel)) 'Inventory Orders',
                if (hasPerm(AppPermissions.invOrderLogPanel)) 'Order Logs',
                if (hasPerm(AppPermissions.consumptionReport)) 'Usage',
                if (hasPerm(AppPermissions.allotmentsReport)) 'Transfer',
                if (hasPerm(AppPermissions.measurementsPanel)) 'M_Measurements',
                if (hasPerm(AppPermissions.inventoryItem)) 'M_Items',
                if (hasPerm(AppPermissions.storeRoom)) 'M_Store',
                if (hasPerm(AppPermissions.unitAuditReport)) 'Audit Report',
                if (hasPerm(AppPermissions.auditItemRank)) 'Audit Item Rank',
              ];

              final infoDirectorySubItems = [
                if (hasPerm(AppPermissions.cDirectoryPanel))
                  'Contact Directory',
                if (hasPerm(AppPermissions.assetPanel) ||
                    hasPerm(AppPermissions.assetsProductDetails))
                  'Assets & Products',
                if (hasPerm(AppPermissions.accountSubscriptionPanel) ||
                    hasPerm(AppPermissions.accountDetails))
                  'Account Details',
                if (hasPerm(AppPermissions.assetCategoryPanel))
                  'Asset Category',
                if (hasPerm(AppPermissions.brandDetails)) 'Brands',
                if (hasPerm(AppPermissions.companyDetails)) 'Companies',
              ];

              final paymentSchedulerSubItems = [
                if (hasPerm(AppPermissions.paymentReminderPannel)) ...[
                  'Scheduler',
                  'Completed Schedulers',
                ],
              ];

              final rolesSubItems = [
                if (hasPerm(AppPermissions.rolesMaster)) 'Roles Master',
                if (hasPerm(AppPermissions.responsibilitiesMaster))
                  'Responsibilities',
                if (hasPerm(AppPermissions.viewResponsibilities))
                  'View Responsibilities',
              ];

              return CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CollapsibleDrawerHeaderDelegate(
                      topPadding: topPadding,
                      userName: userName,
                      userRole: userRole,
                      userImageUrl: userImageUrl,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasPerm(AppPermissions.dashboardPanel))
                            _buildMenuItem(
                              icon: Icons.dashboard_outlined,
                              activeIcon: Icons.dashboard,
                              title: 'Revenue Report',
                              route: AppRoutes.dashboard,
                              currentRoute: currentRoute,
                            ),
                          _buildMenuItem(
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home,
                            title: 'Home',
                            route: AppRoutes.home,
                            currentRoute: currentRoute,
                          ),

                          if ((hasPerm(AppPermissions.maintenancePanel) ||
                                  hasPerm(
                                    AppPermissions.supportTicketDashboard,
                                  )) &&
                              supportTicketSubItems.isNotEmpty)
                            _buildExpandableMenuItem(
                              icon: Icons.support_agent_outlined,
                              title: 'Support Ticket',
                              subItems: supportTicketSubItems,
                              currentRoute: currentRoute,
                            ),

                          if (showTaskScheduler && taskSubItems.isNotEmpty)
                            _buildExpandableMenuItem(
                              icon: Icons.task_alt_outlined,
                              title: 'Task Scheduler',
                              subItems: taskSubItems,
                              currentRoute: currentRoute,
                            ),

                          if (showInventory && inventorySubItems.isNotEmpty)
                            _buildExpandableMenuItem(
                              icon: Icons.inventory_2_outlined,
                              title: 'Inventory',
                              subItems: inventorySubItems,
                              currentRoute: currentRoute,
                            ),

                          if (hasPerm(AppPermissions.trackingPanel) ||
                              hasPerm(AppPermissions.attendanceLog) ||
                              hasPerm(AppPermissions.selfieAttendance))
                            _buildExpandableMenuItem(
                              icon: Icons.location_on_outlined,
                              title: 'Attendance',
                              subItems: [
                                if (hasPerm(AppPermissions.trackingPanel))
                                  'Attendance',
                                if (hasPerm(AppPermissions.attendanceLog))
                                  'Report',
                                if (hasPerm(AppPermissions.selfieAttendance))
                                  'Selfie Attendance',
                              ],
                              currentRoute: currentRoute,
                            ),

                          if (hasPerm(AppPermissions.collectionsDepositsPanel))
                            _buildExpandableMenuItem(
                              icon: Icons.attach_money_outlined,
                              title: 'Collections & Deposits',
                              subItems: [
                                if (hasPerm(AppPermissions.collectionPanel))
                                  'Admin Collections',
                                if (hasPerm(
                                  AppPermissions.normalAdminCollection,
                                ))
                                  'Collections',
                                if (hasPerm(AppPermissions.depositPanel))
                                  'Deposits',
                              ],
                              currentRoute: currentRoute,
                            ),

                          if (infoDirectorySubItems.isNotEmpty)
                            _buildExpandableMenuItem(
                              icon: Icons.contact_phone_outlined,
                              title: 'Info Directory',
                              subItems: infoDirectorySubItems,
                              currentRoute: currentRoute,
                            ),

                          if (hasPerm(AppPermissions.paymentReminderPannel) &&
                              paymentSchedulerSubItems.isNotEmpty)
                            _buildExpandableMenuItem(
                              icon: Icons.payment_outlined,
                              title: 'Payment Scheduler',
                              subItems: paymentSchedulerSubItems,
                              currentRoute: currentRoute,
                            ),

                          if (hasPerm(
                                AppPermissions.rolesResponsibilityPanel,
                              ) &&
                              rolesSubItems.isNotEmpty)
                            _buildExpandableMenuItem(
                              icon: Icons.badge_outlined,
                              title: 'Roles & Responsibilities',
                              subItems: rolesSubItems,
                              currentRoute: currentRoute,
                            ),

                          _buildMenuItem(
                            icon: Icons.person_outline,
                            activeIcon: Icons.person,
                            title: 'Profile',
                            route: AppRoutes.profile,
                            currentRoute: currentRoute,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          Divider(height: 1.h, color: AppColors.borderColor),
          _buildLogoutItem(context, currentRoute),
          _buildVersionInfo(),
        ],
      ),
    );
  }
  // endregion

  // region Menu Item Builders
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
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
      leading: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? AppColors.primary : AppColors.grey300,
        size: 20.r,
      ),
      title: Text(
        title,
        style: isSelected
            ? AppTextStyle.style_14_600(color: AppColors.primary)
            : AppTextStyle.style_14_500(color: AppColors.black),
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
    final GlobalKey expansionTileKey = GlobalKey();

    return Theme(
      data: Theme.of(Get.context!).copyWith(
        dividerColor: Colors.transparent,
        visualDensity: const VisualDensity(vertical: -2),
      ),
      child: ExpansionTile(
        key: expansionTileKey,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        onExpansionChanged: (expanded) {
          if (expanded) {
            Future.delayed(const Duration(milliseconds: 250), () {
              if (expansionTileKey.currentContext != null) {
                Scrollable.ensureVisible(
                  expansionTileKey.currentContext!,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: 0.1,
                );
              }
            });
          }
        },
        leading: Icon(icon, color: AppColors.grey300, size: 20.r),
        title: Text(
          title,
          style: AppTextStyle.style_14_500(color: AppColors.black),
        ),
        iconColor: AppColors.grey300,
        collapsedIconColor: AppColors.grey300,
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
        children: subItems
            .map(
              (item) => ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                contentPadding: EdgeInsets.only(left: 60.w),
                title: Text(
                  item,
                  style: AppTextStyle.style_13_400(color: AppColors.black),
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
                  } else if (item == 'Daily Task Filter' ||
                      item == 'Daily Task By Month') {
                    Get.toNamed(AppRoutes.dailyTaskFilter);
                  } else if (item == 'My Routes') {
                    Get.toNamed(AppRoutes.liveTracking);
                  } else if (item == 'Attendance') {
                    Get.toNamed(AppRoutes.staffTracking);
                  } else if (item == 'Log' || item == 'Report') {
                    Get.toNamed(AppRoutes.attendanceLog);
                  } else if (item == 'Selfie Attendance' ||
                      item == 'Selfie Attendance Report') {
                    if (!_hasPerm(AppPermissions.selfieAttendance)) {
                      AppCommonToastMessage.show(
                        message:
                            'You do not have permission to view Selfie Attendance.',
                        type: ToastType.warning,
                      );
                      return;
                    }
                    Get.toNamed(AppRoutes.selfieAttendanceReport);
                  } else if (item == 'Store Inventory') {
                    Get.toNamed(AppRoutes.storeInventory);
                  } else if (item == 'Unit Inventory') {
                    Get.toNamed(AppRoutes.unitInventory);
                  } else if (item == 'Inventory Orders') {
                    Get.toNamed(AppRoutes.inventoryOrders);
                  } else if (item == 'Order Logs') {
                    Get.toNamed(AppRoutes.orderReceiveLogs);
                  } else if (item == 'Consumption' || item == 'Usage') {
                    Get.toNamed(AppRoutes.allConsumption);
                  } else if (item == 'Allotments' || item == 'Transfer') {
                    Get.toNamed(AppRoutes.allotments);
                  } else if (item == 'M_Measurements') {
                    Get.toNamed(AppRoutes.measurements);
                  } else if (item == 'M_Items') {
                    Get.toNamed(AppRoutes.items);
                  } else if (item == 'M_Store') {
                    Get.toNamed(AppRoutes.storeRooms);
                  } else if (item == 'Audit Report') {
                    Get.toNamed(AppRoutes.auditReport);
                  } else if (item == 'Audit Item Rank' ||
                      item == 'M_Audit_Items_List') {
                    Get.toNamed(AppRoutes.auditItemRanks);
                  } else if (item == 'Collections') {
                    Get.toNamed(AppRoutes.collections);
                  } else if (item == 'Admin Collections') {
                    Get.toNamed(AppRoutes.adminCollections);
                  } else if (item == 'Deposits') {
                    Get.toNamed(AppRoutes.deposits);
                  } else if (item == 'Assets & Products') {
                    Get.toNamed(AppRoutes.assetsProducts);
                  } else if (item == 'Account Details') {
                    Get.toNamed(AppRoutes.accountSubscription);
                  } else if (item == 'Asset Category') {
                    Get.toNamed(AppRoutes.assetCategory);
                  } else if (item == 'Contact Directory' ||
                      item == 'Contacts') {
                    Get.toNamed(AppRoutes.infoDirectory);
                  } else if (item == 'MContact_Brands' || item == 'Brands') {
                    Get.toNamed(AppRoutes.contactBrands);
                  } else if (item == 'MContact_Companies' ||
                      item == 'Companies') {
                    Get.toNamed(AppRoutes.contactCompanies);
                  } else if (item == 'Scheduler') {
                    Get.toNamed(AppRoutes.paymentReminder);
                  } else if (item == 'Completed Schedulers') {
                    Get.toNamed(AppRoutes.completedPayments);
                  } else if (item == 'Roles Master') {
                    Get.toNamed(AppRoutes.rolesMaster);
                  } else if (item == 'Responsibilities') {
                    Get.toNamed(AppRoutes.responsibilitiesMaster);
                  } else if (item == 'View Responsibilities') {
                    Get.toNamed(AppRoutes.viewResponsibilities);
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
  // endregion

  // region Logout & Action Handlers
  Widget _buildLogoutItem(BuildContext context, String currentRoute) {
    return _buildMenuItem(
      icon: Icons.logout_outlined,
      activeIcon: Icons.logout,
      title: 'Logout',
      route: AppRoutes.login,
      currentRoute: currentRoute,
      onTap: () => _handleLogout(context),
    );
  }

  void _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(
        canPop: false,
        child: Center(child: CustomAppLoader()),
      ),
    );
    try {
      await Get.find<AuthRepository>().logout();
    } catch (e) {
      // Handled in repository
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Widget _buildVersionInfo() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '1.0.0';
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h, top: 6.h),
          child: Text(
            'Version $version',
            style: AppTextStyle.style_12_400(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  // endregion
}
// endregion

// region Collapsible Header Delegate
class _CollapsibleDrawerHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String userName;
  final String? userRole;
  final String? userImageUrl;

  _CollapsibleDrawerHeaderDelegate({
    required this.topPadding,
    required this.userName,
    this.userRole,
    this.userImageUrl,
  });

  @override
  double get maxExtent => topPadding + 116.h;

  @override
  double get minExtent => topPadding + 56.h;

  @override
  bool shouldRebuild(covariant _CollapsibleDrawerHeaderDelegate oldDelegate) {
    return oldDelegate.userName != userName ||
        oldDelegate.userRole != userRole ||
        oldDelegate.userImageUrl != userImageUrl ||
        oldDelegate.topPadding != topPadding;
  }

  // region Collapsible Duty Pill Builder
  Widget _buildCollapsedDutyPill(bool isTracking) {
    return GestureDetector(
      onTap: () async {
        await TrackingService.to.toggleTracking();
      },
      child: Container(
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.12),
              blurRadius: 4.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.r,
              height: 7.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTracking ? const Color(0xFF10B981) : AppColors.red,
                boxShadow: isTracking
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.6),
                          blurRadius: 4.r,
                        ),
                      ]
                    : null,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              isTracking ? 'ON' : 'OFF',
              style: AppTextStyle.style_10_700(
                color: isTracking ? const Color(0xFF10B981) : AppColors.red,
              ),
            ),
            SizedBox(width: 5.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28.w,
              height: 16.h,
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: isTracking
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE2E8F0),
              ),
              alignment: isTracking
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 12.r,
                height: 12.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // endregion

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double scrollRange = (maxExtent - minExtent).clamp(
      0.001,
      double.infinity,
    );
    final double progress = (shrinkOffset / scrollRange).clamp(0.0, 1.0);

    return Obx(() {
      final isTracking = TrackingService.to.isTracking.value;

      // Avatar sizing: 42.r -> 34.r
      final double avatarSize = 42.r - (8.r * progress);

      // Avatar top centering
      final double avatarTopExpanded = topPadding + 10.h;
      final double avatarTopCollapsed = topPadding + ((56.h - 34.r) / 2);
      final double avatarTop =
          avatarTopExpanded +
          (avatarTopCollapsed - avatarTopExpanded) * progress;

      // Name top centering
      final double nameTopExpanded = topPadding + 12.h;
      final double nameTopCollapsed = topPadding + ((56.h - 18.sp) / 2);
      final double nameTop =
          nameTopExpanded + (nameTopCollapsed - nameTopExpanded) * progress;

      // Name left position
      final double nameLeftExpanded = 14.w + 42.r + 10.w;
      final double nameLeftCollapsed = 14.w + 34.r + 10.w;
      final double nameLeft =
          nameLeftExpanded + (nameLeftCollapsed - nameLeftExpanded) * progress;

      // Subtitle fade
      final double subtitleOpacity = (1.0 - progress * 2.8).clamp(0.0, 1.0);

      // Expanded Duty Card fade & slide
      final double dutyCardOpacity = (1.0 - progress * 2.0).clamp(0.0, 1.0);
      final double dutyCardOffset = -8.h * progress;

      // Collapsed Duty Switch fade in
      final double collapsedDutyOpacity = ((progress - 0.4) / 0.6).clamp(
        0.0,
        1.0,
      );

      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: progress > 0.1
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.15 * progress),
                    blurRadius: 8.r * progress,
                    offset: Offset(0, 3.h * progress),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Background Accent Circle ──
            Positioned(
              right: -16.w,
              top: -16.h,
              child: Container(
                width: 76.r,
                height: 76.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            // ── Avatar ──
            Positioned(
              left: 14.w,
              top: avatarTop,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: (userImageUrl != null && userImageUrl!.isNotEmpty)
                          ? AppImageView(
                              imageUrl: userImageUrl,
                              fit: BoxFit.cover,
                              errorWidget: Icon(
                                Icons.person,
                                size: (avatarSize * 0.65).clamp(16.0, 26.0),
                                color: AppColors.primary,
                              ),
                            )
                          : Container(
                              color: AppColors.white,
                              child: Icon(
                                Icons.person,
                                size: (avatarSize * 0.65).clamp(16.0, 26.0),
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  if (isTracking)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 9.r,
                        height: 9.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.8),
                              blurRadius: 4.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── User Name & Role ──
            Positioned(
              left: nameLeft,
              top: nameTop,
              right: progress > 0.4 ? 96.w : 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: AppTextStyle.style_16_600(
                      color: AppColors.white,
                    ).copyWith(fontSize: (15.0 - 1.5 * progress).sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitleOpacity > 0.01)
                    Opacity(
                      opacity: subtitleOpacity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Text(
                          userRole ?? 'Operations Team',
                          style: AppTextStyle.style_11_400(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Collapsed Duty Toggle (Right side of compact bar) ──
            if (collapsedDutyOpacity > 0.01)
              Positioned(
                right: 12.w,
                top: topPadding + ((56.h - 28.h) / 2),
                child: Opacity(
                  opacity: collapsedDutyOpacity,
                  child: IgnorePointer(
                    ignoring: progress < 0.5,
                    child: _buildCollapsedDutyPill(isTracking),
                  ),
                ),
              ),

            // ── Expanded Duty Card (Bottom of expanded header) ──
            if (dutyCardOpacity > 0.01)
              Positioned(
                left: 14.w,
                right: 14.w,
                top: topPadding + 62.h + dutyCardOffset,
                child: Opacity(
                  opacity: dutyCardOpacity,
                  child: IgnorePointer(
                    ignoring: progress > 0.5,
                    child: GestureDetector(
                      onTap: () async {
                        await TrackingService.to.toggleTracking();
                      },
                      child: Container(
                        height: 38.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 4.r,
                              offset: Offset(0, 1.5.h),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isTracking
                                    ? const Color(0xFF10B981)
                                    : AppColors.red,
                                boxShadow: isTracking
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.5),
                                          blurRadius: 4.r,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isTracking ? 'ON DUTY' : 'OFF DUTY',
                                    style: AppTextStyle.style_11_700(
                                      color: isTracking
                                          ? const Color(0xFF10B981)
                                          : AppColors.red,
                                    ),
                                  ),
                                  Text(
                                    isTracking
                                        ? 'Duty active'
                                        : 'Offline. Tap switch to start.',
                                    style: AppTextStyle.style_9_400(
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 34.w,
                              height: 20.h,
                              padding: EdgeInsets.all(2.r),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: isTracking
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFE2E8F0),
                              ),
                              alignment: isTracking
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 16.r,
                                height: 16.r,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
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
      );
    });
  }
}

// endregion
