import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/view_responsibilities_controller.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/views/widgets/simple_html_renderer.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class ViewResponsibilitiesScreen extends StatelessWidget {
  const ViewResponsibilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<ViewResponsibilitiesController>()) {
      Get.delete<ViewResponsibilitiesController>();
    }
    final controller = Get.put(ViewResponsibilitiesController());

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
          'View Responsibility',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 4.h, bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Box (Role + Language)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Wrap(
                  spacing: 24.w,
                  runSpacing: 8.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ROLE',
                          style: AppTextStyle.style_12_700(color: AppColors.grey700),
                        ),
                        SizedBox(width: 8.w),

                        Flexible(
                          child: Obx(
                            () => ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 240.w),
                              child: MultiSelectDropdownWidget<int>(
                                hint: 'Select Role',
                                isSingleSelect: true,
                                showSearch: true,
                                height: 30.h,
                                selectedValues: controller.selectedRoleId.value != null
                                    ? {controller.selectedRoleId.value!}
                                    : {},
                                items: controller.roles.map((r) {
                                  return DropdownMenuItem<int>(
                                    value: r.id,
                                    child: Text(
                                      r.roleName,
                                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (selectedSet) {
                                  if (selectedSet.isNotEmpty) {
                                    controller.onRoleSelected(selectedSet.first);
                                  } else {
                                    controller.onRoleSelected(null);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LANGUAGE',
                          style: AppTextStyle.style_12_700(color: AppColors.grey700),
                        ),
                        SizedBox(width: 8.w),

                        Flexible(
                          child: Obx(
                            () => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => controller.onLanguageChanged('english'),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: 'english',
                                        groupValue: controller.selectedLanguage.value,
                                        activeColor: const Color(0xFF2563EB),
                                        onChanged: (v) => controller.onLanguageChanged('english'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Text(
                                        'English',
                                        style: AppTextStyle.style_12_500(color: AppColors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                InkWell(
                                  onTap: () => controller.onLanguageChanged('odia'),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: 'odia',
                                        groupValue: controller.selectedLanguage.value,
                                        activeColor: const Color(0xFF2563EB),
                                        onChanged: (v) => controller.onLanguageChanged('odia'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Text(
                                        'Odia',
                                        style: AppTextStyle.style_12_500(color: AppColors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Main Content Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          color: const Color(0xFF2563EB),
                          size: 18.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Guidelines & Responsibilities',
                          style: AppTextStyle.style_14_700(color: AppColors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 16.h),

                    Obx(() {
                      if (controller.isLoading.value) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.guidelinesText.value.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Center(
                            child: Text(
                              'No guidelines found for the selected role and language',
                              style: AppTextStyle.style_14_500(color: AppColors.grey300),
                            ),
                          ),
                        );
                      }

                      return SimpleHtmlRenderer(
                        htmlContent: controller.guidelinesText.value,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
