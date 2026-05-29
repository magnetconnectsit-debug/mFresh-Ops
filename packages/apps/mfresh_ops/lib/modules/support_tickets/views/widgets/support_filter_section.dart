// region SupportFilterSection
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';

import 'multi_select_dropdown.dart';

// region SupportFilterSection Class
class SupportFilterSection extends StatelessWidget {
  final SupportTicketsController controller;

  const SupportFilterSection({super.key, required this.controller});

  // region build
  @override
  Widget build(BuildContext context) {
    return _buildFilterSection(context, controller);
  }

  // endregion

  // region _buildFilterSection
  Widget _buildFilterSection(
    BuildContext context,
    SupportTicketsController controller,
  ) {
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canFilterUnit = userPermissions.contains(
        'filter_unit_suport_ticket',
      );
      final canFilterGlobal = userPermissions.contains('filter_global');
      final canFilterCategory = userPermissions.contains(
        'filter_category_support_ticket',
      );
      final canFilterStatus = userPermissions.contains(
        'filter_status_suport_ticket',
      );
      final canFilterProject = userPermissions.contains('filter_project');
      final canFilterAssignee = userPermissions.contains('filter_assignee');
      final canSaveFilter = userPermissions.contains('save_filter');

      return Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey50),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            int crossAxis = isMobile ? 2 : 4;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // region Quick Filters Row
                if (canSaveFilter) ...[
                  Obx(() {
                    final filters = controller.quickFilters;
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 26.h,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FF),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: const Color(0xFFBFD0FF)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<QuickFilter>(
                                value: controller.selectedQuickFilter.value,
                                isExpanded: true,
                                isDense: true,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.bookmark_border,
                                      size: 14.r,
                                      color: const Color(0xFF5B7FFF),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      filters.isEmpty
                                          ? 'No saved filters'
                                          : 'Quick Filters',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF5B7FFF),
                                      ),
                                    ),
                                  ],
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16.r,
                                  color: const Color(0xFF5B7FFF),
                                ),
                                items: filters
                                    .map(
                                      (f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(
                                          f.name,
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.grey900,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.applyQuickFilter(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // region Save Filter Button
                        Obx(
                          () => InkWell(
                            onTap: controller.isSavingFilter.value
                                ? null
                                : () =>
                                      _showSaveFilterDialog(context, controller),
                            child: Container(
                              height: 26.h,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: controller.isSavingFilter.value
                                      ? [
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ]
                                      : [AppColors.successDark, AppColors.green],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: controller.isSavingFilter.value
                                  ? SizedBox(
                                      width: 12.r,
                                      height: 12.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Save Filter',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // endregion
                      ],
                    );
                  }),
                  SizedBox(height: 10.h),
                ],
                // endregion

                // region Main Filter Grid
                GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 5.w,
                    mainAxisExtent: 34.h,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // region ASSIGNEE (multi-select)
                    if (canFilterAssignee) ...[
                      MultiSelectDropdownWidget<AssigneeModel>(
                        label: "Assignee",
                        selectedValues: controller.selectedAssignees.toSet(),
                        items: controller.assigneeOptions
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.value,
                                child: Text(
                                  opt.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          controller.selectedAssignees.assignAll(
                            values.toList(),
                          );
                          controller.applyFilters();
                        },
                        showSearch: true,
                      ),
                    ],
                    // endregion

                    // region PRIORITY (multi-select)
                    MultiSelectDropdownWidget<String>(
                      label: "Priority",
                      selectedValues: controller.selectedPriorities.toSet(),
                      items: [
                        DropdownMenuItem(
                          value: "Low",
                          child: Text(
                            "Low",
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Medium",
                          child: Text(
                            "Medium",
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "High",
                          child: Text(
                            "High",
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Top Priority",
                          child: Text(
                            "Top Priority",
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (values) {
                        controller.selectedPriorities.assignAll(
                          values.toList(),
                        );
                        controller.applyFilters();
                      },
                    ),
                    // endregion

                    // region CATEGORY
                    if (canFilterCategory) ...[
                      MultiSelectDropdownWidget<SupportCategory>(
                        label: "Category",
                        isSingleSelect: true,
                        selectedValues: controller.selectedCategories.isNotEmpty
                            ? {controller.selectedCategories.first}
                            : {},
                        items: controller.categoryOptions
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.value,
                                child: Text(
                                  opt.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          if (values.isNotEmpty) {
                            controller.selectedCategories.assignAll([
                              values.first,
                            ]);
                            controller.fetchSubCategories(
                              values.first.categoryId,
                            );
                          } else {
                            controller.selectedCategories.clear();
                          }
                          controller.applyFilters();
                        },
                      ),
                      // endregion

                      // region SUB CATEGORY
                      MultiSelectDropdownWidget<SupportSubCategory>(
                        label: "Sub Category",
                        isSingleSelect: true,
                        selectedValues:
                            controller.selectedSubCategory.value != null
                            ? {controller.selectedSubCategory.value!}
                            : {},
                        items: controller.subCategoryOptions
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.value,
                                child: Text(
                                  opt.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          controller.selectedSubCategory.value =
                              values.isNotEmpty ? values.first : null;
                          controller.applyFilters();
                        },
                      ),
                    ],
                    // endregion

                    // region UNIT (multi-select)
                    if (canFilterUnit) ...[
                      MultiSelectDropdownWidget<SupportUnit>(
                        label: "Unit",
                        selectedValues: controller.selectedUnits.toSet(),
                        items: controller.unitOptions
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.value,
                                child: Text(
                                  opt.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          controller.selectedUnits.assignAll(values.toList());
                          controller.applyFilters();
                        },
                        showSearch: true,
                      ),
                    ],
                    // endregion

                    // region STATUS (multi-select)
                    if (canFilterStatus) ...[
                      MultiSelectDropdownWidget<String>(
                        label: "Status",
                        selectedValues: controller.selectedStatuses.toSet(),
                        items: [
                          DropdownMenuItem(
                            value: "0",
                            child: Text(
                              "New",
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "1",
                            child: Text(
                              "WIP",
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "4",
                            child: Text(
                              "Hold",
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "5",
                            child: Text(
                              "Awaited",
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "2",
                            child: Text(
                              "Resolved",
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "3",
                            child: Text(
                              "Closed",
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (values) {
                          controller.selectedStatuses.assignAll(
                            values.toList(),
                          );
                          controller.applyFilters();
                        },
                      ),
                    ],
                    // endregion

                    // region PROJECT (multi-select)
                    if (canFilterProject) ...[
                      MultiSelectDropdownWidget<SupportProject>(
                        label: "Project",
                        selectedValues: controller.selectedProjects.toSet(),
                        items: controller.projectOptions
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.value,
                                child: Text(
                                  opt.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          controller.selectedProjects.assignAll(
                            values.toList(),
                          );
                          controller.applyFilters();
                        },
                      ),
                    ],
                    // endregion

                    // region GLOBAL SEARCH
                    if (canFilterGlobal) ...[
                      TextField(
                        controller: controller.searchController,
                        readOnly: true,
                        onTap: () {
                          if (!controller.isSearching.value) {
                            controller.toggleSearch();
                          }
                        },
                        style: AppTextStyle.style_12_400(
                          color: AppColors.grey900,
                        ),
                        decoration: InputDecoration(
                          labelText: "Global",
                          hintText: "Search...",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: AppTextStyle.style_12_400(
                            color: AppColors.grey200,
                          ),
                          hintStyle: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                    // endregion
                  ],
                ),
                // endregion

                // region APPLY & RESET FILTER BUTTONS
                Container(
                  margin: EdgeInsets.only(top: 2.h, bottom: 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8.r),
                            onTap: () => controller.resetFilters(),
                            child: Container(
                              height: 28.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "RESET FILTER",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8.r),
                            onTap: () => controller.applyFilters(),
                            child: Container(
                              height: 28.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4FAAD9), Color(0xFF2E89C1)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "APPLY FILTER",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // endregion
              ],
            );
          },
        ),
      );
    });
  }

  // endregion

  // region _showSaveFilterDialog
  void _showSaveFilterDialog(
    BuildContext context,
    SupportTicketsController controller,
  ) {
    final nameController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Save Filter',
                    style: AppTextStyle.style_16_700(color: AppColors.grey900),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Filter name (e.g. IT Team)',
                  hintStyle: AppTextStyle.style_12_400(
                    color: AppColors.grey200,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      AppCommonToastMessage.show(
                        message: 'Please enter a filter name',
                        type: ToastType.error,
                      );
                      return;
                    }
                    Get.back();
                    controller.saveCurrentFilter(name);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E44AD),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Save',
                      style: AppTextStyle.style_14_600(color: Colors.white),
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

  // endregion
}

// endregion
