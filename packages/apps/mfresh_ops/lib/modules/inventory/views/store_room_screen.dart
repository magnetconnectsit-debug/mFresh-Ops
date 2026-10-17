import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/store_room_controller.dart';
import 'package:mfresh_ops/data/models/inventory/store_room_model.dart';
import '../../../widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class StoreRoomScreen extends StatelessWidget {
  const StoreRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreRoomController());

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
              'Store Rooms',
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
                  text: 'Add Store',
                  buttonColor: AppColors.primaryBlue,
                  height: 24.h,
                  width: 110.w,
                  textSize: 11.sp,
                  onPressed: () => _showAddDialog(context, controller),
                ),
                SizedBox(width: 12.w),
                AppCommonExportButton(
                  onExportExcel: () => controller.exportToExcel(),
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
                  final stores = isLoading
                      ? List.generate(
                          10,
                          (index) => StoreRoomModel(
                            id: 0,
                            storeName: 'Loading Store Name',
                          ),
                        )
                      : controller.paginatedStores;

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
                    AppTableColumn<StoreRoomModel>(
                      key: 'Sl No',
                      title: 'Sl No',
                      width: 65.w,
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
                    AppTableColumn<StoreRoomModel>(
                      key: 'Store Name',
                      title: 'Store Name',
                      width: 200.w,
                      valueGetter: (item) => item.storeName,
                    ),
                    AppTableColumn<StoreRoomModel>(
                      key: 'Action',
                      title: 'Action',
                      width: 70.w,
                      sortable: false,
                      cellBuilder: (context, item, index, isExpanded) {
                        if (isLoading) return const SizedBox.shrink();
                        return Center(
                          child: InkWell(
                            onTap: () =>
                                _showEditDialog(context, controller, item),
                            child: Icon(
                              Icons.edit_square,
                              color: AppColors.primary,
                              size: 16.r,
                            ),
                          ),
                        );
                      },
                    ),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AppCommonTable<StoreRoomModel>(
                          items: stores,
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
                          emptyText: 'No stores found',
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

  void _showAddDialog(BuildContext context, StoreRoomController controller) {
    controller.prepareAddDialog();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
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
                        'Add Store Room',
                        style: AppTextStyle.style_18_700(color: AppColors.black),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.grey500,
                          size: 20.r,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AppCommonTextField(
                    labelText: 'Store Name',
                    controller: controller.storeNameController,
                    hintText: 'Enter store name',
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(
                          () => MultiSelectDropdownWidget<String>(
                            label: 'Select State',
                            isSingleSelect: true,
                            selectedValues:
                                controller.selectedStateId.value != null
                                ? {controller.selectedStateId.value!}
                                : {},
                            items: controller.stateOptions
                                .map<DropdownMenuItem<String>>(
                                  (opt) => DropdownMenuItem<String>(
                                    value: opt.value,
                                    child: Text(
                                      opt.label,
                                      style: AppTextStyle.style_12_400(
                                        color: AppColors.grey900,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (values) {
                              controller.onStateSelected(
                                values.isNotEmpty ? values.first : null,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(
                          () => MultiSelectDropdownWidget<String>(
                            label: 'Select District',
                            isSingleSelect: true,
                            selectedValues:
                                controller.selectedDistrictId.value != null
                                ? {controller.selectedDistrictId.value!}
                                : {},
                            items: controller.districtOptions
                                .map<DropdownMenuItem<String>>(
                                  (opt) => DropdownMenuItem<String>(
                                    value: opt.value,
                                    child: Text(
                                      opt.label,
                                      style: AppTextStyle.style_12_400(
                                        color: AppColors.grey900,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (values) {
                              controller.selectedDistrictId.value =
                                  values.isNotEmpty ? values.first : null;
                            },
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
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final success = await controller.addStore();
                                  if (success && dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                    controller.fetchStoreRooms();
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
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StoreRoomController controller,
    StoreRoomModel store,
  ) {
    controller.prepareEditDialog(store);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
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
                        'Edit Store Room',
                        style: AppTextStyle.style_18_700(color: AppColors.black),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.grey500,
                          size: 20.r,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AppCommonTextField(
                    labelText: 'Store Name',
                    controller: controller.storeNameController,
                    hintText: 'Enter store name',
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(
                          () => MultiSelectDropdownWidget<String>(
                            label: 'Select State',
                            isSingleSelect: true,
                            selectedValues:
                                controller.selectedStateId.value != null
                                ? {controller.selectedStateId.value!}
                                : {},
                            items: controller.stateOptions
                                .map<DropdownMenuItem<String>>(
                                  (opt) => DropdownMenuItem<String>(
                                    value: opt.value,
                                    child: Text(
                                      opt.label,
                                      style: AppTextStyle.style_12_400(
                                        color: AppColors.grey900,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (values) {
                              controller.onStateSelected(
                                values.isNotEmpty ? values.first : null,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(
                          () => MultiSelectDropdownWidget<String>(
                            label: 'Select District',
                            isSingleSelect: true,
                            selectedValues:
                                controller.selectedDistrictId.value != null
                                ? {controller.selectedDistrictId.value!}
                                : {},
                            items: controller.districtOptions
                                .map<DropdownMenuItem<String>>(
                                  (opt) => DropdownMenuItem<String>(
                                    value: opt.value,
                                    child: Text(
                                      opt.label,
                                      style: AppTextStyle.style_12_400(
                                        color: AppColors.grey900,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (values) {
                              controller.selectedDistrictId.value =
                                  values.isNotEmpty ? values.first : null;
                            },
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
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final success = await controller.editStore(
                                    store.id,
                                  );
                                  if (success && dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                    controller.fetchStoreRooms();
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
      ),
    );
  }
}
