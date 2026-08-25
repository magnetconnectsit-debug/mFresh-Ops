import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/models/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class PaymentReminderFilterCard extends StatelessWidget {
  final PaymentReminderController controller;

  const PaymentReminderFilterCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<TaskProject>(
                    label: 'Project',
                    selectedValues: controller.selectedProjects.toSet(),
                    items: controller.projects
                        .map<DropdownMenuItem<TaskProject>>(
                          (e) => DropdownMenuItem<TaskProject>(
                            value: e,
                            child: Text(
                              e.projectName,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedProjects.assignAll(values);
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<SupportUnit>(
                    label: 'Unit',
                    selectedValues: controller.selectedUnits.toSet(),
                    items: controller.units
                        .map<DropdownMenuItem<SupportUnit>>(
                          (e) => DropdownMenuItem<SupportUnit>(
                            value: e,
                            child: Text(
                              e.unitName,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedUnits.assignAll(values);
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<TaskGroup>(
                    label: 'S Group',
                    selectedValues: controller.selectedGroups.toSet(),
                    items: controller.groups
                        .map<DropdownMenuItem<TaskGroup>>(
                          (e) => DropdownMenuItem<TaskGroup>(
                            value: e,
                            child: Text(
                              e.roleName,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedGroups.assignAll(values);
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<PaymentReminderUser>(
                    label: 'Assignee',
                    selectedValues: controller.selectedAssignees.toSet(),
                    items: controller.users
                        .map<DropdownMenuItem<PaymentReminderUser>>(
                          (e) => DropdownMenuItem<PaymentReminderUser>(
                            value: e,
                            child: Text(
                              e.name ?? '-',
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedAssignees.assignAll(values);
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
