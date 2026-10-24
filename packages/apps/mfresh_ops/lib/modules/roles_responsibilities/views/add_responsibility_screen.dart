// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/add_responsibility_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class AddResponsibilityScreen extends StatelessWidget {
  final ResponsibilityItem? responsibilityItem;

  const AddResponsibilityScreen({super.key, this.responsibilityItem});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<AddResponsibilityController>()) {
      Get.delete<AddResponsibilityController>();
    }
    final controller = Get.put(
      AddResponsibilityController(responsibilityItem: responsibilityItem),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBreadcrumbs(controller),
                  SizedBox(height: 12.h),
                  _buildFormCard(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AddResponsibilityController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      title: Obx(
        () => Text(
          controller.isEditing.value
              ? 'Edit Responsibility'
              : 'Add Responsibility',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildBreadcrumbs(AddResponsibilityController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            controller.isEditing.value
                ? 'Edit Responsibility'
                : 'Add Responsibility',
            style: AppTextStyle.style_16_700(color: AppColors.black),
          ),
        ),
        Flexible(
          child: Obx(
            () => Text(
              'Responsibility Master  /  ${controller.isEditing.value ? "Edit" : "Add"}',
              style: AppTextStyle.style_11_400(color: AppColors.grey400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AddResponsibilityController controller) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responsibility Details',
              style: AppTextStyle.style_14_700(color: AppColors.black),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => AppCommonMultiSelectDropdown<int>(
                label: 'Select Role *',
                hint: 'Role(s)',
                showSelectAll: false,
                showSearch: true,
                isSingleSelect: true,
                selectedValues: controller.selectedRoleIds.toSet(),
                items: controller.roles.map((r) {
                  return DropdownMenuItem<int>(
                    value: r.id,
                    child: Text(
                      r.roleName,
                      style:
                          AppTextStyle.style_12_400(color: AppColors.grey900),
                    ),
                  );
                }).toList(),
                onChanged: (selectedSet) {
                  controller.selectedRoleIds.assignAll(selectedSet);
                },
              ),
            ),
            SizedBox(height: 16.h),
            AppCommonTextField(
              controller: controller.guidelinesEnglishCtrl,
              titleText: 'Guidelines in English',
              hintText: 'Enter or paste guidelines in English...',
              maxLines: 6,
            ),
            SizedBox(height: 16.h),
            AppCommonTextField(
              controller: controller.guidelinesOdiaCtrl,
              titleText: 'Guidelines in Odia',
              hintText: 'Enter or paste guidelines in Odia...',
              maxLines: 6,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppCommonButton(
                  text: 'Cancel',
                  variant: ButtonVariant.outline,
                  height: 34.h,
                  width: 90.w,
                  borderRadius: 4.r,
                  textSize: 12.sp,
                  onPressed: () => Get.back(),
                ),
                SizedBox(width: 10.w),
                Obx(
                  () => AppCommonButton(
                    text: controller.isEditing.value
                        ? 'Update Responsibility'
                        : 'Save Responsibility',
                    variant: ButtonVariant.primary,
                    buttonColor: AppColors.primary,
                    isLoading: controller.isLoading.value,
                    height: 34.h,
                    width: 150.w,
                    borderRadius: 4.r,
                    textSize: 12.sp,
                    onPressed: controller.submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // endregion
}
// endregion
