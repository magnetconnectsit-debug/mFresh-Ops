// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/add_role_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class AddRoleScreen extends StatelessWidget {
  final RoleItem? roleItem;

  const AddRoleScreen({super.key, this.roleItem});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<AddRoleController>()) {
      Get.delete<AddRoleController>();
    }
    final controller = Get.put(AddRoleController(roleItem: roleItem));

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
    AddRoleController controller,
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
          controller.isEditing.value ? 'Edit Role' : 'Add Role',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildBreadcrumbs(AddRoleController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            controller.isEditing.value ? 'Edit Role' : 'Add Role',
            style: AppTextStyle.style_16_700(color: AppColors.black),
          ),
        ),
        Flexible(
          child: Obx(
            () => Text(
              'Roles Master  /  ${controller.isEditing.value ? "Edit Role" : "Add Role"}',
              style: AppTextStyle.style_11_400(color: AppColors.grey400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AddRoleController controller) {
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
              'Role Information',
              style: AppTextStyle.style_14_700(color: AppColors.black),
            ),
            SizedBox(height: 16.h),
            AppCommonTextField(
              controller: controller.roleNameCtrl,
              titleText: 'Role Name *',
              hintText: 'Enter role name',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Role Name is required' : null,
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
                    text:
                        controller.isEditing.value ? 'Update Role' : 'Save Role',
                    variant: ButtonVariant.primary,
                    buttonColor: AppColors.primary,
                    isLoading: controller.isLoading.value,
                    height: 34.h,
                    width: 110.w,
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
