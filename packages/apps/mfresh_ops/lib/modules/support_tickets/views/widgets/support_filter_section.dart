// region SupportFilterSection
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';


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
        padding: EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 3.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey50),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            int crossAxis = isMobile ? 2 : 4;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // region Main Filter Grid
                GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 2.h,
                    mainAxisExtent: 24.h,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // region CATEGORY & SUB CATEGORY
                    if (canFilterCategory) ...[
                      MultiSelectDropdownWidget<SupportCategory>(
                        label: "Category",
                        isSingleSelect: true,
                        selectedValues: controller.selectedCategories.toSet(),
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
                          controller.selectedCategories.assignAll(values.toList());
                          if (values.isNotEmpty) {
                            controller.fetchSubCategories(
                              values.first.categoryId,
                            );
                          } else {
                            controller.subCategories.clear();
                            controller.selectedSubCategories.clear();
                          }
                          controller.applyFilters();
                        },
                      ),
                      MultiSelectDropdownWidget<SupportSubCategory>(
                        label: "Sub Category",
                        isLoading: controller.isSubCategoryLoading.value,
                        isSingleSelect: false,
                        selectedValues: controller.selectedSubCategories.toSet(),
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
                          controller.selectedSubCategories.assignAll(values.toList());
                          controller.applyFilters();
                        },
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

                    // region PROJECT
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

                    // region ACTION BUTTONS (RESET / SAVE FILTER)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: [
                          Expanded(
                            child: AppCommonButton(
                              text: "Reset",
                              width: double.infinity,
                              variant: ButtonVariant.outline,
                              borderColor: AppColors.red,
                              textColor: AppColors.red,
                              buttonColor: AppColors.white,
                              height: 22.h,
                              borderRadius: 4.r,
                              padding: EdgeInsets.zero,
                              onPressed: () => controller.resetFilters(),
                            ),
                          ),
                          if (canSaveFilter) ...[
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Obx(
                                () => AppCommonButton(
                                  text: "Save Filter",
                                  width: double.infinity,
                                  isLoading: controller.isSavingFilter.value,
                                  loaderSize: 10.r,
                                  gradientColors: const [
                                    AppColors.successDark,
                                    AppColors.green,
                                  ],
                                  height: 22.h,
                                  borderRadius: 4.r,
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _handleSaveFilter(
                                    context,
                                    controller,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // endregion
                  ],
                ),
                // endregion
                // region Quick Filters Dropdown
                if (canSaveFilter) ...[
                  SizedBox(height: 3.h),
                  Obx(() {
                    final filters = controller.quickFilters;
                    return AppCommonMultiSelectDropdown<QuickFilter>(
                      label: "Quick Filters",
                      hint: filters.isEmpty
                          ? "No saved filters"
                          : "Quick Filters",
                      isSingleSelect: true,
                      selectedValues: controller.selectedQuickFilter.value != null
                          ? {controller.selectedQuickFilter.value!}
                          : <QuickFilter>{},
                      items: filters
                          .map(
                            (f) => DropdownMenuItem<QuickFilter>(
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
                      onChanged: (values) {
                        if (values.isNotEmpty) {
                          controller.applyQuickFilter(values.first);
                        } else {
                          controller.selectedQuickFilter.value = null;
                        }
                      },
                    );
                  }),
                ],
                // endregion
              ],
            );
          },
        ),
      );
    });
  }

  // endregion

  // region Dialogs & Action Handlers
  void _handleSaveFilter(
    BuildContext context,
    SupportTicketsController controller,
  ) {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains('save_filter')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }
    _showSaveFilterDialog(context, controller);
  }

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
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.close,
                        color: AppColors.grey700,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              AppCommonTextField(
                controller: nameController,
                hintText: 'Filter name (e.g. IT Team)',
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: AppCommonButton(
                  text: 'Save',
                  useGradient: false,
                  buttonColor: AppColors.purple,
                  textSize: 14.sp,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  borderRadius: 8.r,
                  onPressed: () {
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
