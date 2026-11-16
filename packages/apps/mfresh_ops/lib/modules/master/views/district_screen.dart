// region Imports
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/master/district_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/district_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class DistrictScreen extends StatelessWidget {
  const DistrictScreen({super.key});

  // region RBAC Permissions Helper
  bool _hasPermission(String key) {
    if (!Get.isRegistered<AuthRepository>()) return false;
    final permissions = Get.find<AuthRepository>().rxUserPermissions;
    return AppPermissions.has(permissions, key);
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DistrictController>()
        ? Get.find<DistrictController>()
        : Get.put(DistrictController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value && controller.districts.isEmpty) {
                return const Center(child: CustomAppLoader());
              }

              return AppRefreshIndicator(
                onRefresh: () => controller.fetchDistricts(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionBar(context, controller),
                      SizedBox(height: 10.h),
                      _buildTableSection(context, controller),
                      SizedBox(height: 12.h),
                      _buildFooterSection(controller),
                    ],
                  ),
                ),
              );
            }),
            Obx(() {
              if (controller.isSubmitting.value) {
                return Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: AppColors.black.withValues(alpha: 0.25),
                      child: const Center(child: CustomAppLoader()),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DistrictController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      showSearchBar: true,
      searchController: controller.searchCtrl,
      searchHintText: 'Search District...',
      searchBarWidth: 150.w,
      onSearchChanged: (v) {
        controller.searchQuery.value = v;
        controller.currentPage.value = 1;
      },
      onSearchClear: () {
        controller.resetSearch();
      },
      title: Text(
        'All District',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }

  // endregion

  // region Section Builders
  Widget _buildActionBar(BuildContext context, DistrictController controller) {
    final canManage = _hasPermission(AppPermissions.masterPanel);

    return Row(
      children: [
        if (canManage)
          AppCommonButton(
            text: '+ District',
            onPressed: () => _showAddEditDistrictDialog(context, controller),
          ),
        if (canManage) SizedBox(width: 10.w),
        Obx(
          () => AppCommonExportButton(
            onExportExcel: () => controller.exportToExcel(),
            isLoading: controller.isExporting.value,
          ),
        ),
        const Spacer(),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderColor, width: 1.r),
            ),
            child: Text(
              'Total: ${controller.filteredDistricts.length}',
              style: AppTextStyle.style_11_600(color: AppColors.grey600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(
    BuildContext context,
    DistrictController controller,
  ) {
    final canManage = _hasPermission(AppPermissions.masterPanel);

    return Obx(() {
      final items = controller.paginatedDistricts;

      if (items.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Center(
            child: Text(
              'No districts found',
              style: AppTextStyle.style_13_500(color: AppColors.grey400),
            ),
          ),
        );
      }

      final columns = [
        AppTableColumn<DistrictItem>(
          key: 'district',
          title: 'District',
          sortable: true,
          width: 73.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.districtName,
              style: AppTextStyle.style_11_500(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<DistrictItem>(
          key: 'state',
          title: 'State',
          sortable: true,
          width: 60.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.stateName ?? '-',
              style: AppTextStyle.style_11_500(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            );
          },
        ),

        AppTableColumn<DistrictItem>(
          key: 'zone',
          title: 'Zone',
          sortable: true,
          width: 63.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.zoneName ?? '-',
              style: AppTextStyle.style_11_500(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            );
          },
        ),

        AppTableColumn<DistrictItem>(
          key: 'status',
          title: 'Status',
          sortable: false,
          width: 97.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20.h,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: CupertinoSwitch(
                      value: item.isActive,
                      activeTrackColor: AppColors.blue500,
                      onChanged: (val) {
                        _handleToggleStatus(context, controller, item);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  item.isActive ? 'Active' : 'Inactive',
                  style: AppTextStyle.style_11_500(
                    color: item.isActive ? AppColors.black : AppColors.grey400,
                  ),
                ),
              ],
            );
          },
        ),
        if (canManage)
          AppTableColumn<DistrictItem>(
            key: 'action',
            title: 'Action',
            sortable: false,
            width: 65.w,
            alignment: Alignment.centerLeft,
            cellBuilder: (context, item, index, isExpanded) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showAddEditDistrictDialog(
                      context,
                      controller,
                      districtItem: item,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14.sp,
                        color: AppColors.blue500,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () =>
                        _handleDeleteDistrict(context, controller, item),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.delete_outline,
                        size: 14.sp,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ];

      return AppCommonTable<DistrictItem>(
        columns: columns,
        items: items,
        isLoading:
            controller.isLoading.value || controller.isSubmitting.value,
        onSort: (colKey, order) => controller.onSort(colKey, order),
        currentSortColumn: controller.sortColumn.value,
        currentSortOrder: controller.sortOrder.value,
      );
    });
  }

  Widget _buildFooterSection(DistrictController controller) {
    return Obx(() {
      final total = controller.filteredDistricts.length;
      final start = total == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final end = min(
        controller.currentPage.value * controller.perPage.value,
        total,
      );

      return AppTablePagination(
        startItem: start,
        endItem: end,
        totalItems: total,
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
        onPageChanged: (page) => controller.currentPage.value = page,
      );
    });
  }

  // endregion

  // region Dialogs & Action Handlers
  Future<void> _handleToggleStatus(
    BuildContext context,
    DistrictController controller,
    DistrictItem item,
  ) async {
    if (!_hasPermission(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    if (item.isActive) {
      final confirmed = await AppCommonDialogBox.showConfirm(
        context,
        title: 'Deactivate District',
        message: 'Are you sure you want to deactivate "${item.districtName}"?',
        confirmText: 'Deactivate',
        cancelText: 'Cancel',
      );
      if (confirmed) {
        await controller.toggleDistrictStatus(item);
      }
    } else {
      await controller.toggleDistrictStatus(item);
    }
  }

  Future<void> _handleDeleteDistrict(
    BuildContext context,
    DistrictController controller,
    DistrictItem item,
  ) async {
    if (!_hasPermission(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete District',
      message: 'Are you sure you want to delete "${item.districtName}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDanger: true,
    );

    if (confirmed) {
      await controller.deleteDistrict(item.id);
    }
  }

  void _showAddEditDistrictDialog(
    BuildContext context,
    DistrictController controller, {
    DistrictItem? districtItem,
  }) {
    if (!_hasPermission(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    final isEdit = districtItem != null;
    controller.districtNameCtrl.text = districtItem?.districtName ?? '';
    controller.selectedStateId.value = districtItem?.stateId;
    controller.districtStatusValue.value = districtItem?.status ?? 1;

    // Fetch states if not already loaded
    if (controller.states.isEmpty) {
      controller.fetchStates();
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 440.w),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.r),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit District' : 'Add District',
                            style: AppTextStyle.style_16_700(
                              color: AppColors.black,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.close,
                                size: 18.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      // 1. District Name Field (First)
                      AppCommonTextField(
                        controller: controller.districtNameCtrl,
                        labelText: 'District Name',
                        isRequired: true,
                        hintText: 'Enter district name',
                      ),
                      SizedBox(height: 12.h),
                      // 2. State Dropdown and Status in the same row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Obx(
                              () => AppCommonMultiSelectDropdown<int>(
                                label: 'Select State *',
                                hint: 'Select State',
                                isSingleSelect: true,
                                showSearch: true,
                                selectedValues:
                                    controller.selectedStateId.value == null
                                    ? {}
                                    : {controller.selectedStateId.value!},
                                items: controller.states
                                    .map(
                                      (state) => DropdownMenuItem<int>(
                                        value: state.id,
                                        child: Text(
                                          state.stateName,
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.grey900,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  controller.selectedStateId.value =
                                      val.isEmpty ? null : val.first;
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          // Status toggle in same row (bottom-aligned to match dropdown input box)
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Obx(() {
                              final isActive =
                                  controller.districtStatusValue.value == 1;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Status: ',
                                    style: AppTextStyle.style_12_500(
                                      color: AppColors.grey700,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: CupertinoSwitch(
                                        value: isActive,
                                        activeTrackColor: AppColors.blue500,
                                        onChanged: (val) {
                                          controller.districtStatusValue.value =
                                              val ? 1 : 0;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: AppTextStyle.style_11_500(
                                      color: isActive
                                          ? AppColors.black
                                          : AppColors.grey400,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppCommonButton(
                            text: 'Cancel',
                            variant: ButtonVariant.outline,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => AppCommonButton(
                              text: isEdit ? 'Update' : 'Save',
                              isLoading: controller.isSubmitting.value,
                              onPressed: () async {
                                final name = controller.districtNameCtrl.text
                                    .trim();
                                final stateId =
                                    controller.selectedStateId.value;
                                if (name.isEmpty) {
                                  AppCommonToastMessage.show(
                                    message: 'Please enter district name.',
                                    type: ToastType.warning,
                                  );
                                  return;
                                }
                                if (stateId == null) {
                                  AppCommonToastMessage.show(
                                    message: 'Please select a state.',
                                    type: ToastType.warning,
                                  );
                                  return;
                                }

                                bool success = false;
                                if (isEdit) {
                                  success = await controller.updateDistrict(
                                    id: districtItem.id,
                                    stateId: stateId,
                                    districtName: name,
                                    status:
                                        controller.districtStatusValue.value,
                                  );
                                } else {
                                  success = await controller.createDistrict(
                                    stateId: stateId,
                                    districtName: name,
                                    status:
                                        controller.districtStatusValue.value,
                                  );
                                }

                                if (success && ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.isSubmitting.value) {
                  return Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Center(child: CustomAppLoader()),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  // endregion
}

// endregion
