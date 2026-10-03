import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:core/constants/app_colors.dart';

class SupportActionButtons extends StatelessWidget {
  final SupportTicketsController controller;

  const SupportActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;
      final canAddTicket = userPermissions.contains('add_maintenance');
      final canBulkEdit = userPermissions.contains('bulk_edit');

      return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (canAddTicket) ...[
            _actionButton(
              label: "Create Ticket",
              colors: const [AppColors.secondaryBlue, AppColors.primaryBlue],
              onTap: () => Get.toNamed(AppRoutes.createSupportTicket),
            ),
            SizedBox(width: 4.w),
          ],
          _actionButton(
            label: "Excel",
            iconWidget: FaIcon(
              FontAwesomeIcons.fileExcel,
              size: 13.r,
              color: AppColors.white,
            ),
            colors: const [AppColors.secondaryGreen, AppColors.primaryGreen],
            onTap: () => controller.exportTickets(),
          ),
          if (canBulkEdit) ...[
            Obx(() {
              final isDisabled = controller.selectedTickets.isEmpty;
              return Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: _actionButton(
                  label: "Bulk Edit",
                  colors: const [AppColors.mediumblue, AppColors.blue],
                  onTap: () => _showBulkEditDialog(controller),
                  isDisabled: isDisabled,
                ),
              );
            }),
          ],
        ],
      ),
    );
    });
  }

  Widget _actionButton({
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isDisabled = false,
    IconData? icon,
    Widget? iconWidget,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? colors.map((c) => c.withValues(alpha: 0.4)).toList()
                : colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) ...[
              iconWidget,
              SizedBox(width: 4.w),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 14.r,
                color: isDisabled
                    ? AppColors.white.withValues(alpha: 0.6)
                    : AppColors.white,
              ),
              SizedBox(width: 3.w),
            ],
            Text(
              label,
              style: AppTextStyle.style_11_600(
                color: isDisabled
                    ? AppColors.white.withValues(alpha: 0.6)
                    : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkEditDialog(SupportTicketsController controller) {
    controller.resetBulkEdit();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxWidth: 400.w),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bulk Update Tickets",
                    style: AppTextStyle.style_18_700(color: AppColors.grey900),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: AppColors.grey100),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                children: [
                  _buildBulkDropdownRow<SupportUnit>(
                    "Units",
                    controller.bulkEnableUnit,
                    controller.bulkSelectedUnit,
                    controller.unitOptions,
                    (val) => controller.bulkSelectedUnit.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<String>(
                    "Priority",
                    controller.bulkEnablePriority,
                    controller.bulkSelectedPriority,
                    controller.priorityOptions,
                    (val) => controller.bulkSelectedPriority.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<String>(
                    "Status",
                    controller.bulkEnableStatus,
                    controller.bulkSelectedStatus,
                    controller.statusOptions,
                    (val) => controller.bulkSelectedStatus.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<SupportCategory>(
                    "Category",
                    controller.bulkEnableCategory,
                    controller.bulkSelectedCategory,
                    controller.categoryOptions,
                    (val) {
                      controller.bulkSelectedCategory.value = val;
                      if (val != null) {
                        controller.fetchBulkSubCategories(val.categoryId);
                      }
                    },
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => _buildBulkDropdownRow<SupportSubCategory>(
                      "Sub-Cat",
                      controller.bulkEnableSubCategory,
                      controller.bulkSelectedSubCategory,
                      controller.bulkSubCategories
                          .map(
                            (e) => DropdownOption(
                              value: e,
                              label: e.subCategoryName,
                            ),
                          )
                          .toList(),
                      (val) => controller.bulkSelectedSubCategory.value = val,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<AssigneeModel>(
                    "Assignee",
                    controller.bulkEnableAssignee,
                    controller.bulkSelectedAssignee,
                    controller.assigneeOptions,
                    (val) => controller.bulkSelectedAssignee.value = val,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => controller.submitBulkEdit(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successDark,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "Update",
                      style: AppTextStyle.style_14_600(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulkDropdownRow<T>(
    String label,
    RxBool isEnabled,
    Rxn<T> selectedValue,
    List<DropdownOption<T>> options,
    Function(T?) onChanged,
  ) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: isEnabled.value,
            onChanged: (val) {
              isEnabled.value = val ?? false;
              if (!isEnabled.value) selectedValue.value = null;
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(
          width: 65.w,
          child: Text(
            label,
            style: AppTextStyle.style_12_500(color: AppColors.grey900),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Obx(
            () => Container(
              height: 34.h,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: selectedValue.value,
                  isExpanded: true,
                  isDense: true,
                  hint: Text(
                    "Select",
                    style: AppTextStyle.style_12_400(color: AppColors.grey200),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16.r,
                    color: AppColors.grey200,
                  ),
                  items: options.map((opt) {
                    return DropdownMenuItem<T>(
                      value: opt.value,
                      child: Text(
                        opt.label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.style_12_400(
                          color: AppColors.grey900,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: isEnabled.value ? onChanged : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
