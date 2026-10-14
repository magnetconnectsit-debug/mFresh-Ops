import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_table_pagination.dart';
import '../controllers/measurement_controller.dart';
import 'package:mfresh_ops/data/models/inventory/measurement_model.dart';
import '../../../widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MeasurementController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 45.h,
        title: Row(
          children: [
            Text(
              'Measurements',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
            const Spacer(),
            AppCommonSearchBar(
              width: 140.w,
              controller: controller.searchController,
              onChanged: (v) => controller.applyFilters(),
              hintText: 'Search',
            ),
          ],
        ),
      ),
      drawer: const CommonSidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                AppCommonButton(
                  text: 'Add Measurement',
                  buttonColor: AppColors.primaryBlue,
                  onPressed: () => _showAddDialog(context, controller),
                  height: 24.h,
                  textSize: 11.sp,
                ),
              ],
            ),
          ),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => controller.onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Obx(() {
                  final isLoading = controller.isLoading.value;
                  final items = isLoading
                      ? List.generate(
                          10,
                          (index) => MeasurementModel(
                            id: index,
                            measurementUnit: 'Loading Measurement $index',
                          ),
                        )
                      : controller.paginatedItems;

                  final sortColumn = controller.sortColumn.value;
                  final isAsc = controller.sortAscending.value;
                  final currentSortOrder = sortColumn.isEmpty
                      ? AppTableSortOrder.none
                      : (isAsc
                          ? AppTableSortOrder.ascending
                          : AppTableSortOrder.descending);

                  final startItem = controller.totalEntries == 0
                      ? 0
                      : ((controller.currentPage.value - 1) *
                              controller.perPage.value) +
                          1;
                  final endItem =
                      (controller.currentPage.value * controller.perPage.value)
                          .clamp(0, controller.totalEntries);

                  final columns = [
                    AppTableColumn<MeasurementModel>(
                      key: 'Sl No',
                      title: 'Sl No',
                      width: 70.w,
                      sortable: false,
                      cellBuilder: (context, item, index, isExpanded) {
                        return Text(
                          '${startItem + index}',
                          style: AppTextStyle.style_11_500(
                            color: AppColors.black,
                          ),
                        );
                      },
                    ),
                    AppTableColumn<MeasurementModel>(
                      key: 'Measurement',
                      title: 'Measurement',
                      width: 200.w,
                      valueGetter: (item) => item.measurementUnit,
                    ),
                    AppTableColumn<MeasurementModel>(
                      key: 'Action',
                      title: 'Action',
                      width: 80.w,
                      sortable: false,
                      cellBuilder: (context, item, index, isExpanded) {
                        if (isLoading) return const SizedBox.shrink();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () =>
                                  _showEditDialog(context, controller, item),
                              child: Icon(
                                Icons.edit_square,
                                color: AppColors.primary,
                                size: 16.r,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: () =>
                                  _showDeleteDialog(context, controller, item),
                              child: Icon(
                                Icons.delete,
                                color: AppColors.red,
                                size: 16.r,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AppCommonTable<MeasurementModel>(
                          items: items,
                          columns: columns,
                          currentSortColumn: sortColumn,
                          currentSortOrder: currentSortOrder,
                          onSort: (columnKey, sortOrder) =>
                              controller.sortBy(columnKey),
                          isLoading: isLoading,
                          headingRowColor: AppColors.blue50,
                          headingTextStyle: AppTextStyle.style_11_700(
                            color: AppColors.black,
                          ),
                          dataTextStyle: AppTextStyle.style_11_500(
                            color: AppColors.black,
                          ),
                          borderColor: AppColors.borderColor,
                          headingRowHeight: 20.h,
                          cellVerticalPadding: 1.h,
                          cellHorizontalPadding: 4.w,
                          emptyText: 'No measurements found',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (!isLoading && controller.totalEntries > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          child: AppTablePagination(
                            startItem: startItem,
                            endItem: endItem,
                            totalItems: controller.totalEntries,
                            currentPage: controller.currentPage.value,
                            totalPages: controller.totalPages,
                            onPageChanged: (page) => controller.goToPage(page),
                            onPreviousPage: controller.previousPage,
                            onNextPage: controller.nextPage,
                          ),
                        ),
                      SizedBox(height: 32.h),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showAddDialog(BuildContext context, MeasurementController controller) {
    controller.measurementNameController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
                      'Add Measurement',
                      style: AppTextStyle.style_18_700(color: AppColors.black),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close, color: AppColors.grey500, size: 20.r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppCommonTextField(
                  controller: controller.measurementNameController,
                  labelText: 'Measurement Name',
                  hintText: 'e.g. Litre',
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: 'Cancel',
                      buttonColor: AppColors.black200,
                      height: 32.h,
                      width: 90.w,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => AppCommonButton(
                        text: 'Submit',
                        buttonColor: AppColors.primaryBlue,
                        width: 100.w,
                        height: 32.h,
                        isLoading: controller.isSubmitting.value,
                        onPressed: () async {
                          final success = await controller.addMeasurement();
                          if (success && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
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
      ),
    );
  }

  void _showEditDialog(BuildContext context, MeasurementController controller, MeasurementModel model) {
    controller.measurementNameController.text = model.measurementUnit;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
                      'Edit Measurement',
                      style: AppTextStyle.style_18_700(color: AppColors.black),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close, color: AppColors.grey500, size: 20.r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppCommonTextField(
                  controller: controller.measurementNameController,
                  labelText: 'Measurement Name',
                  hintText: 'e.g. Litre',
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: 'Cancel',
                      buttonColor: AppColors.black200,
                      height: 32.h,
                      width: 90.w,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => AppCommonButton(
                        text: 'Update',
                        buttonColor: AppColors.primaryBlue,
                        width: 100.w,
                        height: 32.h,
                        isLoading: controller.isSubmitting.value,
                        onPressed: () async {
                          final success = await controller.editMeasurement(model, controller.measurementNameController.text.trim());
                          if (success && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
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
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MeasurementController controller, MeasurementModel model) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
                      'Delete Measurement',
                      style: AppTextStyle.style_18_700(color: AppColors.black),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close, color: AppColors.grey500, size: 20.r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Are you sure you want to delete "${model.measurementUnit}"?',
                  style: AppTextStyle.style_14_400(color: AppColors.black),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: 'Cancel',
                      buttonColor: AppColors.black200,
                      height: 32.h,
                      width: 90.w,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => AppCommonButton(
                        text: 'Delete',
                        buttonColor: AppColors.red,
                        width: 100.w,
                        height: 32.h,
                        isLoading: controller.isLoading.value,
                        onPressed: () async {
                          final success = await controller.deleteMeasurement(model);
                          if (success && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
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
      ),
    );
  }

}
