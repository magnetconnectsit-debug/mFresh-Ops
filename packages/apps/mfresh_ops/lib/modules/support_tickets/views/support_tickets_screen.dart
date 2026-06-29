// region SupportTicketsScreen
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

import 'widgets/support_tickets_header.dart';
import 'widgets/support_filter_section.dart';
import 'widgets/support_action_buttons.dart';
import 'widgets/support_tickets_table.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  // region build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportTicketsController>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      resizeToAvoidBottomInset: false,
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  focusNode: controller.searchFocusNode,
                  hintText: 'Search tickets locally...',
                  onChanged: (v) => controller.searchQuery.value = v,
                  autofocus: true,
                  onClose: () {
                    controller.searchController.clear();
                    controller.searchQuery.value = '';
                    controller.toggleSearch();
                  },
                )
              : Text(
                  "All Support Tickets",
                  style: AppTextStyle.style_18_700(color: Colors.black),
                ),
        ),
      ),
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: Obx(() {
          final authRepo = Get.find<AuthRepository>();
          final userPermissions = authRepo.rxUserPermissions;

          final canViewTable = userPermissions.contains('maintenance_table');
          final canViewFilter = userPermissions.contains('maintenance_filter');

          // Use skeletonizer for initial loading
          final showSkeleton =
              controller.isLoading.value && controller.tickets.isEmpty;

          return RefreshIndicator(
            onRefresh: () => controller.refreshAll(),
            displacement: 40,
            // Required for NestedScrollView: trigger from any scroll depth
            notificationPredicate: (notification) => notification.depth >= 0,
            child: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SupportTicketsHeader(
                                controller: controller,
                                showSkeleton: showSkeleton,
                                canViewFilter: canViewFilter,
                              ),
                              SizedBox(height: 6.h),
                              if (canViewFilter) ...[
                                Skeletonizer(
                                  enabled: showSkeleton,
                                  child: SupportFilterSection(
                                    controller: controller,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                              ],
                              Skeletonizer(
                                enabled: showSkeleton,
                                child: SupportActionButtons(
                                  controller: controller,
                                ),
                              ),
                              SizedBox(height: 6.h),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: canViewTable
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(
                            10.w,
                            controller.isSearching.value ? 10.h : 0,
                            10.w,
                            0,
                          ),
                          child: SupportTicketsTable(controller: controller),
                        )
                      : const SizedBox.shrink(),
                ),
                // Show custom app loader overlay only if not refreshing
                if (controller.isLoading.value &&
                    !controller.isRefreshing.value)
                  const CustomAppLoader(),
              ],
            ),
          );
        }),
      ),
    );
  }
  // endregion
}
// endregion
