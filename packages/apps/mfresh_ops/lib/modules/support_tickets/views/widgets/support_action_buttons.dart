// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
// endregion

// region SupportActionButtons Widget
class SupportActionButtons extends StatelessWidget {
  // region Properties
  final SupportTicketsController controller;
  // endregion

  // region Constructor
  const SupportActionButtons({super.key, required this.controller});
  // endregion

  // region Main Build
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
              AppCommonButton(
                icon: Icons.add,
                height: 22.h,
                text: "Create Ticket",
                gradientColors: const [
                  AppColors.secondaryBlue,
                  AppColors.primaryBlue,
                ],
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                onPressed: _handleCreateTicket,
              ),
              SizedBox(width: 4.w),
            ],
            AppCommonExportButton(
              onExportExcel: () => controller.exportTickets(),
            ),
            if (canBulkEdit) ...[
              Obx(() {
                final isDisabled = controller.selectedTickets.isEmpty;
                return Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: AppCommonButton(
                    icon: Icons.edit_document,
                    height: 22.h,
                    text: "Bulk Edit",
                    gradientColors: const [
                      AppColors.mediumblue,
                      AppColors.blue,
                    ],
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    onPressed: isDisabled ? null : _handleBulkEdit,
                  ),
                );
              }),
            ],
          ],
        ),
      );
    });
  }
  // endregion

  // region Dialogs & Action Handlers
  void _handleCreateTicket() {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains(
      'add_maintenance',
    )) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }
    Get.toNamed(AppRoutes.createSupportTicket);
  }

  void _handleBulkEdit() {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains('bulk_edit')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }
    _showBulkEditDialog();
  }

  void _showBulkEditDialog() {
    controller.resetBulkEdit();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: AppColors.surface,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
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
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.close,
                        size: 20.r,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                children: [
                  _buildBulkDropdownRow<SupportUnit>(
                    label: "Units",
                    isEnabled: controller.bulkEnableUnit,
                    selectedValue: controller.bulkSelectedUnit,
                    options: controller.unitOptions,
                    onChanged: (val) => controller.bulkSelectedUnit.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<String>(
                    label: "Priority",
                    isEnabled: controller.bulkEnablePriority,
                    selectedValue: controller.bulkSelectedPriority,
                    options: controller.priorityOptions,
                    onChanged: (val) =>
                        controller.bulkSelectedPriority.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<String>(
                    label: "Status",
                    isEnabled: controller.bulkEnableStatus,
                    selectedValue: controller.bulkSelectedStatus,
                    options: controller.statusOptions,
                    onChanged: (val) =>
                        controller.bulkSelectedStatus.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<SupportCategory>(
                    label: "Category",
                    isEnabled: controller.bulkEnableCategory,
                    selectedValue: controller.bulkSelectedCategory,
                    options: controller.categoryOptions,
                    onChanged: (val) {
                      controller.bulkSelectedCategory.value = val;
                      if (val != null) {
                        controller.fetchBulkSubCategories(val.categoryId);
                      }
                    },
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => _buildBulkDropdownRow<SupportSubCategory>(
                      label: "Sub-Cat",
                      isEnabled: controller.bulkEnableSubCategory,
                      selectedValue: controller.bulkSelectedSubCategory,
                      options: controller.bulkSubCategories
                          .map(
                            (e) => DropdownOption(
                              value: e,
                              label: e.subCategoryName,
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          controller.bulkSelectedSubCategory.value = val,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<AssigneeModel>(
                    label: "Assignee",
                    isEnabled: controller.bulkEnableAssignee,
                    selectedValue: controller.bulkSelectedAssignee,
                    options: controller.assigneeOptions,
                    onChanged: (val) =>
                        controller.bulkSelectedAssignee.value = val,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => AppCommonButton(
                    text: "Update",
                    isLoading: controller.isLoading.value,
                    useGradient: false,
                    buttonColor: AppColors.successDark,
                    textSize: 14.sp,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    borderRadius: 6.r,
                    onPressed: () => controller.submitBulkEdit(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Section & Component Builders
  Widget _buildBulkDropdownRow<T>({
    required String label,
    required RxBool isEnabled,
    required Rxn<T> selectedValue,
    required List<DropdownOption<T>> options,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: isEnabled.value,
            onChanged: (val) {
              isEnabled.value = val ?? false;
              if (!isEnabled.value) selectedValue.value = null;
            },
            activeColor: AppColors.primary,
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
          child: Obx(() {
            final hasMatchingValue =
                selectedValue.value != null &&
                options.any((opt) => opt.value == selectedValue.value);
            final effectiveValue = hasMatchingValue
                ? selectedValue.value
                : null;

            return AppCommonDropdown<T>(
              key: ValueKey('${isEnabled.value}_$effectiveValue'),
              hintText: "Select",
              value: effectiveValue,
              height: 34.h,
              fillColor: isEnabled.value ? AppColors.white : AppColors.surface,
              borderColor: AppColors.borderColor,
              items: options.map((opt) {
                return DropdownMenuItem<T>(
                  value: opt.value,
                  child: Text(
                    opt.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.style_12_400(
                      color: isEnabled.value
                          ? AppColors.grey900
                          : AppColors.grey300,
                    ),
                  ),
                );
              }).toList(),
              onChanged: isEnabled.value ? onChanged : null,
            );
          }),
        ),
      ],
    );
  }

  // endregion
}

// endregion
