import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/add_responsibility_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AddResponsibilityScreen extends StatelessWidget {
  final ResponsibilityItem? responsibilityItem;

  const AddResponsibilityScreen({super.key, this.responsibilityItem});

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
      appBar: AppCommonAppBar(
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
            style: AppTextStyle.style_18_700(color: AppColors.black),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 4.h,
            bottom: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Role *',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(width: 40.w),
                          Expanded(
                            child: Obx(
                              () => MultiSelectDropdownWidget<int>(
                                hint: 'Select Role(s)',
                                selectedValues: controller.selectedRoleIds
                                    .toSet(),
                                items: controller.roles.map((r) {
                                  return DropdownMenuItem<int>(
                                    value: r.id,
                                    child: Text(
                                      r.roleName,
                                      style: AppTextStyle.style_12_400(
                                        color: AppColors.grey900,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (selectedSet) {
                                  controller.selectedRoleIds.assignAll(
                                    selectedSet,
                                  );
                                },
                                showSearch: true,
                                showSelectAll: false,
                                isSingleSelect: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guidelines in English',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: controller.guidelinesEnglishCtrl,
                            maxLines: 6,
                            minLines: 4,
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Paste guidelines in English...',
                              hintStyle: AppTextStyle.style_12_400(
                                color: AppColors.grey300,
                              ),
                              contentPadding: EdgeInsets.all(10.r),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF2562B),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guidelines in Odia',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: controller.guidelinesOdiaCtrl,
                            maxLines: 6,
                            minLines: 4,
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Paste guidelines in Odia...',
                              hintStyle: AppTextStyle.style_12_400(
                                color: AppColors.grey300,
                              ),
                              contentPadding: EdgeInsets.all(10.r),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF2562B),
                                  width: 1.5,
                                ),
                              ),
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
                              text: controller.isEditing.value
                                  ? 'Update'
                                  : 'Save',
                              variant: ButtonVariant.primary,
                              buttonColor: const Color(0xFFF2562B),
                              isSmall: true,
                              isLoading: controller.isLoading.value,
                              height: 34.h,
                              width: 100.w,
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
