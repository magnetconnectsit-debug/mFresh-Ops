// region SupportTicketsScreen
import 'package:core/constants/app_colors.dart';
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
    final authRepo = Get.find<AuthRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 35.h,
        title: Obx(
          () => controller.isSearching.value
              ? Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
                  child: AppCommonSearchBar(
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
                  ),
                )
              : Row(
                  children: [
                    Text(
                      "Support Tickets (${controller.totalTickets.value})",
                      style: AppTextStyle.style_16_700(color: AppColors.black),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.search, color: AppColors.black, size: 22.sp),
                      onPressed: () {
                        if (!controller.isSearching.value) {
                          controller.toggleSearch();
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshAll(),
          displacement: 40,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                      child: Obx(() {
                        final userPermissions = authRepo.rxUserPermissions;
                        final canViewFilter =
                            userPermissions.contains('filter_global');
                        final showSkeleton = controller.isLoading.value &&
                            controller.tickets.isEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (canViewFilter) ...[
                              Skeletonizer(
                                enabled: showSkeleton,
                                child: SupportFilterSection(
                                  controller: controller,
                                ),
                              ),
                              SizedBox(height: 3.h),
                            ],
                            Skeletonizer(
                              enabled: showSkeleton,
                              child: SupportActionButtons(
                                controller: controller,
                              ),
                            ),
                            SizedBox(height: 3.h),
                          ],
                        );
                      }),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Obx(() {
                      final userPermissions = authRepo.rxUserPermissions;
                      final canViewTable =
                          userPermissions.contains('maintenance_table');
                      if (!canViewTable) return const SizedBox.shrink();

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          10.w,
                          controller.isSearching.value ? 10.h : 0,
                          10.w,
                          0,
                        ),
                        child: SupportTicketsTable(controller: controller),
                      );
                    }),
                  ),
                ],
              ),
              Obx(() {
                if (controller.isLoading.value &&
                    !controller.isRefreshing.value) {
                  return const CustomAppLoader();
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion
