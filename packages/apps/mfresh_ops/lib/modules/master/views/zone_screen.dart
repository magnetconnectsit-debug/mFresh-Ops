// region Imports
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/zone_model.dart';
import 'package:mfresh_ops/modules/master/controllers/zone_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class ZoneScreen extends StatelessWidget {
  const ZoneScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ZoneController>()
        ? Get.find<ZoneController>()
        : Get.put(ZoneController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value && controller.zones.isEmpty) {
                return const Center(child: CustomAppLoader());
              }

              return AppRefreshIndicator(
                onRefresh: () => controller.fetchZones(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
    ZoneController controller,
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
      searchHintText: 'Search Zone...',
      searchBarWidth: 140.w,
      onSearchChanged: (v) {
        controller.searchQuery.value = v;
        controller.currentPage.value = 1;
      },
      onSearchClear: () {
        controller.resetSearch();
      },
      title: Text(
        'All Zone',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildActionBar(BuildContext context, ZoneController controller) {
    return Row(
      children: [
        AppCommonButton(
          text: '+ Zone',
          variant: ButtonVariant.primary,
          buttonColor: AppColors.primaryBlue,
          height: 26.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          borderRadius: 6.r,
          textSize: 11.sp,
          onPressed: () => _showAddEditZoneDialog(context, controller),
        ),
        SizedBox(width: 10.w),
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
              'Total: ${controller.filteredZones.length}',
              style: AppTextStyle.style_11_600(color: AppColors.grey600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(BuildContext context, ZoneController controller) {
    return Obx(() {
      final items = controller.paginatedZones;

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
              'No zones found',
              style: AppTextStyle.style_13_500(color: AppColors.grey400),
            ),
          ),
        );
      }

      final columns = [
        AppTableColumn<ZoneItem>(
          key: 'zone',
          title: 'Zone',
          sortable: true,
          width: 110.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.zone,
              style: AppTextStyle.style_11_500(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<ZoneItem>(
          key: 'status',
          title: 'Status',
          sortable: false,
          width: 95.w,
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
        AppTableColumn<ZoneItem>(
          key: 'action',
          title: 'Action',
          width: 75.w,
          sortable: false,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _showAddEditZoneDialog(
                    context,
                    controller,
                    zoneItem: item,
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
                  onTap: () => _handleDeleteZone(context, controller, item),
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

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: AppCommonTable<ZoneItem>(
            columns: columns,
            items: items,
            isLoading: controller.isLoading.value || controller.isSubmitting.value,
            onSort: (colKey, order) => controller.onSort(colKey, order),
            currentSortColumn: controller.sortColumn.value,
            currentSortOrder: controller.sortOrder.value,
            headingRowHeight: 24.h,
            headingRowColor: AppColors.blue50,
            headingTextStyle: AppTextStyle.style_11_700(color: AppColors.black),
            dataTextStyle: AppTextStyle.style_11_400(color: AppColors.black87),
          ),
        ),
      );
    });
  }

  Widget _buildFooterSection(ZoneController controller) {
    return Obx(() {
      final total = controller.filteredZones.length;
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
    ZoneController controller,
    ZoneItem item,
  ) async {
    if (item.isActive) {
      // Deactivating: ask for confirmation first
      final confirmed = await AppCommonDialogBox.showConfirm(
        context,
        title: 'Deactivate Zone',
        message: 'Are you sure you want to deactivate zone "${item.zone}"?',
        confirmText: 'Deactivate',
        cancelText: 'Cancel',
      );
      if (confirmed) {
        await controller.toggleZoneStatus(item);
      }
    } else {
      // Activating: toggle directly
      await controller.toggleZoneStatus(item);
    }
  }

  Future<void> _handleDeleteZone(
    BuildContext context,
    ZoneController controller,
    ZoneItem item,
  ) async {
    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Zone',
      message: 'Are you sure you want to delete zone "${item.zone}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDanger: true,
    );

    if (confirmed) {
      await controller.deleteZone(item.id);
    }
  }

  void _showAddEditZoneDialog(
    BuildContext context,
    ZoneController controller, {
    ZoneItem? zoneItem,
  }) {
    final isEdit = zoneItem != null;
    controller.zoneNameCtrl.text = zoneItem?.zone ?? '';
    controller.zoneStatusValue.value = zoneItem?.status ?? 1;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Zone' : 'Add Zone',
                          style: AppTextStyle.style_16_700(color: AppColors.black),
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
                    AppCommonTextField(
                      controller: controller.zoneNameCtrl,
                      labelText: 'Zone Name',
                      isRequired: true,
                      hintText: 'Enter zone name',
                      height: 32.h,
                    ),
                    SizedBox(height: 12.h),
                    Obx(() {
                      final isActive = controller.zoneStatusValue.value == 1;
                      return Row(
                        children: [
                          Text(
                            'Status: ',
                            style: AppTextStyle.style_12_500(
                              color: AppColors.black,
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
                                  controller.zoneStatusValue.value =
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
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppCommonButton(
                          text: 'Cancel',
                          variant: ButtonVariant.outline,
                          height: 32.h,
                          width: 80.w,
                          borderRadius: 4.r,
                          textSize: 12.sp,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        SizedBox(width: 8.w),
                        Obx(
                          () => AppCommonButton(
                            text: isEdit ? 'Update' : 'Save',
                            variant: ButtonVariant.primary,
                            buttonColor: AppColors.primary,
                            height: 32.h,
                            width: 85.w,
                            isLoading: controller.isSubmitting.value,
                            borderRadius: 4.r,
                            textSize: 12.sp,
                            onPressed: () async {
                              final name = controller.zoneNameCtrl.text.trim();
                              if (name.isEmpty) {
                                AppCommonToastMessage.show(
                                  message: 'Zone Name is required',
                                  type: ToastType.error,
                                );
                                return;
                              }
                              final status = controller.zoneStatusValue.value;
                              final bool success = isEdit
                                  ? await controller.updateZone(
                                      zoneItem.id,
                                      name,
                                      status,
                                    )
                                  : await controller.createZone(name, status);
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
              Obx(() {
                if (controller.isSubmitting.value) {
                  return Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.7),
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
