// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/assign_service_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/assign_service_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region AssignServiceScreen
class AssignServiceScreen extends GetView<AssignServiceController> {
  const AssignServiceScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
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
                onRefresh: () => controller.fetchAssignsIndex(),
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
    AssignServiceController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      title: Text(
        'Assign Services',
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
    AssignServiceController controller,
  ) {
    final authRepo = Get.find<AuthRepository>();
    final canManage = authRepo.rxUserPermissions.contains(
      AppPermissions.masterPanel,
    );

    return Row(
      children: [
        if (canManage)
          AppCommonButton(
            text: '+ Create Assign Service',
            onPressed: () {
              controller.initForCreate();
              Get.toNamed(AppRoutes.masterAssignServiceCreateEdit);
            },
          ),
        if (canManage) SizedBox(width: 10.w),
        Obx(
          () => AppCommonExportButton(
            isLoading: controller.isExporting.value,
            onExportExcel: controller.exportToExcel,
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
    AssignServiceController controller,
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
        AppTableColumn<AssignUnitItem>(
          key: 'unit_image',
          title: 'Unit Image',
          sortable: false,
          width: 75.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            final imgUrl = item.unitImgUrl;
            final hasImg = imgUrl != null &&
                imgUrl.isNotEmpty &&
                !imgUrl.endsWith('/NA') &&
                imgUrl != 'NA';

            if (!hasImg) {
              return Center(
                child: Container(
                  width: 22.r,
                  height: 22.r,
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
            }

            return Center(
              child: InkWell(
                onTap: () {
                  AppImageView.showFullScreen(
                    context,
                    imageUrl: imgUrl,
                    title: item.qrcodeId.isNotEmpty
                        ? '${item.qrcodeId} - Unit Image'
                        : 'Unit Image',
                  );
                },
                borderRadius: BorderRadius.circular(4.r),
                child: AppImageView(
                  imageUrl: imgUrl,
                  width: 22.r,
                  height: 22.r,
                  borderRadius: 4.r,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        AppTableColumn<AssignUnitItem>(
          key: 'unit',
          title: 'Unit',
          sortable: true,
          width: 90.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.qrcodeId,
            style: AppTextStyle.style_11_600(color: AppColors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssignUnitItem>(
          key: 'model',
          title: 'Model',
          sortable: true,
          width: 140.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.unitcategory ?? 'NA',
            style: AppTextStyle.style_11_400(color: AppColors.grey800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssignUnitItem>(
          key: 'city',
          title: 'City',
          sortable: true,
          width: 80.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.unitLocation ?? 'NA',
            style: AppTextStyle.style_11_400(color: AppColors.grey800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssignUnitItem>(
          key: 'operating_hrs',
          title: 'Operating Hrs',
          sortable: false,
          width: 180.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.fullAdd ?? 'NA',
            style: AppTextStyle.style_11_400(color: AppColors.grey800),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        AppTableColumn<AssignUnitItem>(
          key: 'inauguration_date',
          title: 'Inaguration Date',
          sortable: true,
          width: 110.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.formattedInaugurationDate,
            style: AppTextStyle.style_11_400(color: AppColors.grey800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssignUnitItem>(
          key: 'action',
          title: 'Action',
          sortable: false,
          width: 65.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Center(
              child: InkWell(
                onTap: () => _handleEditAssignService(item),
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  width: 22.h,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1.r,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 13.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            );
          },
        ),
      ];

      return AppCommonTable<AssignUnitItem>(
        columns: columns,
        items: items,
        isLoading: controller.isLoading.value,
        onSort: (key, order) => controller.sort(key, order),
        currentSortColumn: controller.sortColumn.value,
        currentSortOrder: controller.sortOrder.value,
      );
    });
  }
  // endregion

  // region Section Builders - Footer Section
  Widget _buildFooterSection(AssignServiceController controller) {
    return Obx(() {
      final total = controller.filteredUnits.length;
      if (total == 0) return const SizedBox.shrink();

      final start =
          ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final end = (start + controller.perPage.value - 1 > total)
          ? total
          : (start + controller.perPage.value - 1);

      return AppTablePagination(
        startItem: start,
        endItem: end,
        totalItems: total,
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
        onPageChanged: (page) => controller.changePage(page),
      );
    });
  }
  // endregion

  // region Dialogs & Action Handlers
  void _handleEditAssignService(AssignUnitItem item) {
    final authRepo = Get.find<AuthRepository>();
    if (!authRepo.rxUserPermissions.contains(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to edit assign services.',
        type: ToastType.warning,
      );
      return;
    }

    if (item.assignments.isNotEmpty) {
      // Data already in memory: initialize in 0ms and navigate immediately
      controller.initForEditFromUnitAssignments(item);
      Get.toNamed(AppRoutes.masterAssignServiceCreateEdit);
    } else {
      // Initialize synchronously first, navigate immediately, and load in background if needed
      controller.initForEdit(item);
      Get.toNamed(AppRoutes.masterAssignServiceCreateEdit);
      controller.loadAndInitForEdit(item);
    }
  }

  // endregion
}
// endregion
