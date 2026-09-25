import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/account_subscription_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/account_subscription_filters.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/account_subscription_table.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:core/widgets/app_common_search_bar.dart';

class AccountSubscriptionScreen extends StatelessWidget {
  const AccountSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountSubscriptionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: AppCommonAppBar(
        title: Obx(
          () => controller.isSearching.value
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                  child: AppCommonSearchBar(
                    controller: controller.searchCtrl,
                    hintText: 'Search...',
                    onChanged: (v) {
                      controller.applyFilters(debounce: true);
                    },
                  ),
                )
              : Text(
                  'All Account Logins',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        hasBackButton: false,
        showAppDrawer: true,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 45.h,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Obx(
                () => Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  color: AppColors.black,
                  size: 26.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  AccountSubscriptionFilters(controller: controller),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      SizedBox(
                        height: 24.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Get.toNamed(
                              AppRoutes.createAccountSubscription,
                            );
                            if (result == true) {
                              controller.fetchSubscriptions();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A3B8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            elevation: 1,
                          ),
                          child: Text(
                            'Create Accounts',
                            style: AppTextStyle.style_12_500(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Obx(
                        () => Container(
                          height: 24.h,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.perPage.value,
                              dropdownColor: Colors.white,
                              style: AppTextStyle.style_12_500(
                                color: AppColors.black,
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 16.r,
                                color: Colors.grey.shade600,
                              ),
                              items: [10, 20, 50, 100, 500, 1000]
                                  .map(
                                    (val) => DropdownMenuItem<int>(
                                      value: val,
                                      child: Text('$val per page'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.perPage.value = val;
                                  controller.currentPage.value = 1;
                                  controller.fetchSubscriptions();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.subscriptions.isEmpty) {
                        return const Center(child: CustomAppLoader());
                      }
                      return AccountSubscriptionTable(controller: controller);
                    }),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.subscriptions.isNotEmpty) {
                return const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Center(child: CustomAppLoader()),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
