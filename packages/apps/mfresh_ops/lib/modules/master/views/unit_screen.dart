// region Imports
import 'dart:math';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/master/unit_master_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/unit_controller.dart';
import 'package:mfresh_ops/modules/master/views/widgets/edit_unit_manager_dialog.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region UnitScreen
class UnitScreen extends StatelessWidget {
  const UnitScreen({super.key});

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
    final controller = Get.isRegistered<UnitController>()
        ? Get.find<UnitController>()
        : Get.put(UnitController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value && controller.units.isEmpty) {
                return const Center(child: CustomAppLoader());
              }

              return AppRefreshIndicator(
                onRefresh: () => controller.fetchUnits(),
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
                      SizedBox(height: 16.h),
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
    UnitController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      title: Text(
        'Units Master',
        style: AppTextStyle.style_16_600(color: AppColors.black),
      ),
      showSearchBar: true,
      searchHintText: 'Search units...',
      searchController: controller.searchCtrl,
      onSearchChanged: (val) => controller.onSearchChanged(val),
      onSearchClear: () {
        controller.searchCtrl.clear();
        controller.onSearchChanged('');
      },
      topHeader: const CommonShortcutHeader(),
    );
  }
  // endregion

  // region Section Builders - Action Bar
  Widget _buildActionBar(
    BuildContext context,
    UnitController controller,
  ) {
    final canManage = _hasPermission(AppPermissions.masterPanel);

    return Row(
      children: [
        if (canManage)
          AppCommonButton(
            text: '+ Create Unit',
            onPressed: () {
              controller.initCreateUnit();
              Get.toNamed(AppRoutes.masterUnitEdit);
            },
          ),
        if (canManage) SizedBox(width: 10.w),
        Obx(
          () => AppCommonExportButton(
            isLoading: controller.isExporting.value,
            onExportExcel: () => controller.exportExcel(),
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
              'Total: ${controller.filteredUnits.length}',
              style: AppTextStyle.style_11_600(color: AppColors.grey600),
            ),
          ),
        ),
      ],
    );
  }
  // endregion

  // region Section Builders - Table Section
  Widget _buildTableSection(
    BuildContext context,
    UnitController controller,
  ) {
    return Obx(() {
      final items = controller.paginatedUnits;

      if (items.isEmpty && !controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Center(
            child: Text(
              'No units found.',
              style: AppTextStyle.style_13_500(color: AppColors.grey400),
            ),
          ),
        );
      }

      final columns = [
        AppTableColumn<UnitMasterItem>(
          key: 'unit_image',
          title: 'Unit Image',
          sortable: false,
          width: 65.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            final imgUrl = item.unitImgUrl;
            return Center(
              child: (imgUrl != null &&
                      imgUrl.isNotEmpty &&
                      !imgUrl.endsWith('/NA'))
                  ? AppImageView(
                      imageUrl: imgUrl,
                      width: 20.r,
                      height: 20.r,
                      borderRadius: 4.r,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.bathroom_outlined,
                        size: 13.sp,
                        color: AppColors.grey300,
                      ),
                    ),
            );
          },
        ),
        AppTableColumn<UnitMasterItem>(
          key: 'unit',
          title: 'Unit',
          sortable: true,
          width: 95.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.qrcodeId,
            style: AppTextStyle.style_11_600(color: AppColors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<UnitMasterItem>(
          key: 'model',
          title: 'Model',
          sortable: true,
          width: 140.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.unitcategory,
            style: AppTextStyle.style_11_400(color: AppColors.grey400),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<UnitMasterItem>(
          key: 'city',
          title: 'City',
          sortable: true,
          width: 75.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.unitLocation,
            style: AppTextStyle.style_11_400(color: AppColors.grey400),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<UnitMasterItem>(
          key: 'operating_hrs',
          title: 'Operating Hrs',
          sortable: true,
          width: 110.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.openTiming,
            style: AppTextStyle.style_11_400(color: AppColors.grey400),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<UnitMasterItem>(
          key: 'inauguration_date',
          title: 'Inauguration Date',
          sortable: true,
          width: 115.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.formattedInaugurationDate,
            style: AppTextStyle.style_11_400(color: AppColors.grey400),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<UnitMasterItem>(
          key: 'action',
          title: 'Action',
          sortable: false,
          width: 95.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1st Action Button: Edit Unit Manager Details Dialog
              InkWell(
                onTap: () {
                  if (!_hasPermission(AppPermissions.masterPanel)) {
                    AppCommonToastMessage.show(
                      message:
                          'You do not have permission to edit unit details.',
                      type: ToastType.warning,
                    );
                    return;
                  }
                  controller.initManagerDetails(item);
                  showDialog(
                    context: context,
                    builder: (ctx) => const EditUnitManagerDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey200),
                    borderRadius: BorderRadius.circular(4.r),
                    color: AppColors.white,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.edit_note_outlined,
                      size: 14.sp,
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // 2nd Action Button: Full Unit Edit Screen
              InkWell(
                onTap: () {
                  if (!_hasPermission(AppPermissions.masterPanel)) {
                    AppCommonToastMessage.show(
                      message:
                          'You do not have permission to edit units.',
                      type: ToastType.warning,
                    );
                    return;
                  }
                  controller.initUnitEdit(item);
                  Get.toNamed(AppRoutes.masterUnitEdit);
                },
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  height: 22.h,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey200),
                    borderRadius: BorderRadius.circular(4.r),
                    color: AppColors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 11.sp,
                        color: AppColors.grey400,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Edit',
                        style: AppTextStyle.style_10_500(
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ];

      return AppCommonTable<UnitMasterItem>(
        columns: columns,
        items: items,
        isLoading: controller.isLoading.value,
        onSort: (colKey, order) => controller.onSort(colKey, order),
        currentSortColumn: controller.sortColumn.value,
        currentSortOrder: controller.sortOrder.value,
      );
    });
  }
  // endregion

  // region Section Builders - Footer Section
  Widget _buildFooterSection(UnitController controller) {
    return Obx(() {
      final total = controller.filteredUnits.length;
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
        totalPages:
            (total / controller.perPage.value).ceil().clamp(1, 9999),
        onPageChanged: (page) => controller.onPageChanged(page),
      );
    });
  }
  // endregion
}
// endregion
