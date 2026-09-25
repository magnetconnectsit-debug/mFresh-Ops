import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/add_role_controller.dart';

class AddRoleScreen extends StatelessWidget {
  final RoleItem? roleItem;

  const AddRoleScreen({super.key, this.roleItem});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<AddRoleController>()) {
      Get.delete<AddRoleController>();
    }
    final controller = Get.put(AddRoleController(roleItem: roleItem));

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
          () => Text(
            controller.isEditing.value ? 'Edit Role' : 'Add Role',
            style: AppTextStyle.style_18_700(color: AppColors.black),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 4.h, bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      controller.isEditing.value ? 'Edit Role' : 'Add Role',
                      style: AppTextStyle.style_18_700(color: AppColors.black),
                    ),
                  ),
                  Flexible(
                    child: Obx(
                      () => Text(
                        'Roles Master  /  ${controller.isEditing.value ? "Edit Role" : "Add Role"}',
                        style: AppTextStyle.style_12_400(color: AppColors.grey400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
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

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role Name *',
                            style: AppTextStyle.style_12_600(color: AppColors.black),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: TextFormField(
                              controller: controller.roleNameCtrl,
                              style: AppTextStyle.style_12_400(color: AppColors.grey900),
                              decoration: InputDecoration(
                                hintText: 'Enter role name',
                                hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: const BorderSide(color: Color(0xFFF2562B), width: 1.5),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Role Name is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppCommonButton(
                            text: 'Cancel',
                            variant: ButtonVariant.outline,
                            isSmall: true,
                            height: 34.h,
                            width: 90.w,
                            onPressed: () => Get.back(),
                          ),
                          SizedBox(width: 12.w),
                          Obx(
                            () => AppCommonButton(
                              text: controller.isEditing.value ? 'Update Role' : 'Save Role',
                              variant: ButtonVariant.primary,
                              buttonColor: const Color(0xFFF2562B),
                              isSmall: true,
                              isLoading: controller.isLoading.value,
                              height: 34.h,
                              width: 110.w,
                              onPressed: controller.submit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
