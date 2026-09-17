import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/completed_payment_controller.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/widgets/completed_payment_filter_card.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/widgets/completed_payment_table.dart';

class CompletedPaymentScreen extends StatelessWidget {
  const CompletedPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompletedPaymentController());

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
        title: Text(
          'Completed Payments',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              if (Get.isRegistered<AuthRepository>()) {
                await Get.find<AuthRepository>().fetchProfile();
              }
            } catch (_) {}
            controller.searchQuery.value = '';
            controller.currentPage.value = 1;
            await controller.fetchCompletedPayments();
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Filter Card
              CompletedPaymentFilterCard(controller: controller),
              SizedBox(height: 6.h),

              // Action Buttons (Payment Reminders button & Rows per Page)
              Row(
                children: [
                  SizedBox(
                    height: 24.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (Get.isRegistered<PaymentReminderController>()) {
                          final reminderController = Get.find<PaymentReminderController>();
                          reminderController.fetchPaymentReminders();
                        }
                        Get.offNamed(AppRoutes.paymentReminder);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A3B8),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        elevation: 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Payment Reminders', style: AppTextStyle.style_10_500(color: Colors.white)),
                          SizedBox(width: 3.w),
                          Icon(Icons.arrow_forward_ios, size: 10.sp, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => Container(
                      height: 24.h,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: controller.perPage.value,
                          isDense: true,
                          dropdownColor: Colors.white,
                          style: AppTextStyle.style_10_500(color: AppColors.black),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 14.r,
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
              SizedBox(height: 6.h),

              // Table
              CompletedPaymentTable(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
