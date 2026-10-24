// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/view_responsibilities_controller.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/views/widgets/simple_html_renderer.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class ViewResponsibilitiesScreen extends StatelessWidget {
  const ViewResponsibilitiesScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<ViewResponsibilitiesController>()) {
      Get.delete<ViewResponsibilitiesController>();
    }
    final controller = Get.put(ViewResponsibilitiesController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterContainer(controller),
                  SizedBox(height: 8.h),
                  _buildContentCard(controller),
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
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      title: Text(
        'View Responsibility',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildFilterContainer(ViewResponsibilitiesController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoleDropdown(controller),
                SizedBox(height: 4.h),
                _buildLanguageSelector(controller),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: _buildRoleDropdown(controller),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: _buildLanguageSelector(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoleDropdown(ViewResponsibilitiesController controller) {
    return Obx(
      () => AppCommonMultiSelectDropdown<int>(
        label: 'Select Role',
        hint: 'Role',
        isSingleSelect: true,
        showSearch: true,
        height: 30.h,
        menuMaxHeight: 320.h,
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
    );
  }

  Widget _buildLanguageSelector(ViewResponsibilitiesController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Language:',
          style: AppTextStyle.style_11_600(color: AppColors.grey700),
        ),
        SizedBox(width: 6.w),
        Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => controller.onLanguageChanged('english'),
                borderRadius: BorderRadius.circular(4.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'english',
                      groupValue: controller.selectedLanguage.value,
                      activeColor: AppColors.primary,
                      onChanged: (v) =>
                          controller.onLanguageChanged('english'),
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'English',
                      style: AppTextStyle.style_12_500(color: AppColors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: () => controller.onLanguageChanged('odia'),
                borderRadius: BorderRadius.circular(4.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'odia',
                      groupValue: controller.selectedLanguage.value,
                      activeColor: AppColors.primary,
                      onChanged: (v) => controller.onLanguageChanged('odia'),
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    SizedBox(width: 3.w),
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
      ],
    );
  }

  Widget _buildContentCard(ViewResponsibilitiesController controller) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: AppColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Guidelines & Responsibilities',
                style: AppTextStyle.style_14_700(color: AppColors.black),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: AppColors.borderColor),
          SizedBox(height: 14.h),
          Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CustomAppLoader()),
              );
            }

            if (controller.guidelinesText.value.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: Text(
                    'No guidelines found for the selected role and language',
                    style: AppTextStyle.style_13_500(color: AppColors.grey400),
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
    );
  }
  // endregion
}
// endregion
