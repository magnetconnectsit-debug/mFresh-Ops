import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/widgets/payment_reminder_filter_card.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/widgets/payment_reminder_table.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/create_payment_reminder_screen.dart';
import 'package:core/widgets/app_common_search_bar.dart';

class PaymentReminderScreen extends StatelessWidget {
  const PaymentReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentReminderController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 45.h,
        title: Obx(
          () => controller.isSearching.value
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                  child: AppCommonSearchBar(
                    controller: controller.searchController,
                    hintText: 'Search payment reminders...',
                    onChanged: (v) {
                      controller.searchQuery.value = v;
                    },
                  ),
                )
              : Text(
                  'Payment Reminder',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
                size: 26.sp,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.searchQuery.value = '';
            controller.currentPage.value = 1;
            await controller.fetchPaymentReminders();
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              PaymentReminderFilterCard(controller: controller),
              SizedBox(height: 12.h),
              
              // Action Buttons (Add Reminder & Rows per Page)
              Row(
                children: [
                  SizedBox(
                    height: 24.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const CreatePaymentReminderScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A3B8),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        elevation: 1,
                      ),
                      child: Text('Add Reminder', style: AppTextStyle.style_12_500(color: Colors.white)),
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
                          style: AppTextStyle.style_12_500(color: AppColors.black),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 16.r,
                            color: Colors.grey.shade600,
                          ),
                          items: [10, 20, 50, 100, 500, 1000].map((int val) {
                            return DropdownMenuItem<int>(
                              value: val,
                              child: Text('$val per page'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.perPage.value = val;
                              controller.currentPage.value = 1;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Table
              PaymentReminderTable(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
