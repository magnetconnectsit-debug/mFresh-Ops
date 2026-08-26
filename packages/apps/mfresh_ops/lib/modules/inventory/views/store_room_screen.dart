import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/store_room_controller.dart';
import 'package:mfresh_ops/data/models/inventory/store_room_model.dart';
import '../../../widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

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
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  onChanged: (v) => controller.applyFilters(),
                  hintText: 'Search Store Rooms...',
                )
              : Text(
                  'Store Rooms',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
              ),
            ),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  height: 28.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _showAddDialog(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Text(
                      'Add Store',
                      style: AppTextStyle.style_12_600(color: AppColors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  height: 28.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => controller.exportToExcel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Text(
                      'Export Excel',
                      style: AppTextStyle.style_12_600(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => controller.onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(() {
                  final isTableLoading = controller.isLoading.value;
                  final stores = isTableLoading
                      ? List.generate(
                          10,
                          (index) => StoreRoomModel(
                            id: 0,
                            storeName: 'Loading Store Name',
                          ),
                        )
                      : controller.filteredStores;

                  if (stores.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(32.r),
                      child: Center(
                        child: Text(
                          'No stores found',
                          style: AppTextStyle.style_14_400(
                            color: AppColors.grey300,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 32.w,
                          ),
                          child: Skeletonizer(
                            enabled: isTableLoading,
                            child: Table(
                              columnWidths: {
                                0: FixedColumnWidth(50.w),   // Sl No
                                1: FixedColumnWidth(180.w),  // Store Name
                                2: FixedColumnWidth(70.w),   // Action
                              },
                              border: TableBorder.all(
                                color: AppColors.grey50,
                                width: 1,
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                  ),
                                  children: [
                                    _buildHeaderCell('Sl No'),
                                    _buildHeaderCell('Store Name'),
                                    _buildHeaderCell('Action'),
                                  ],
                                ),
                                ...stores.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final store = entry.value;
                                  return TableRow(
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                    ),
                                    children: [
                                      _buildDataCell((index + 1).toString()),
                                      _buildDataCell(store.storeName),
                                      isTableLoading
                                          ? _buildDataCell('')
                                          : _buildEditButton(
                                              context,
                                              controller,
                                              store,
                                              index,
                                            ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Showing 1 to ${controller.filteredStores.length} of ${controller.filteredStores.length} entries',
                        style: AppTextStyle.style_14_400(
                          color: AppColors.black,
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

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    StoreRoomController controller,
    StoreRoomModel store,
    int index,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Center(
        child: InkWell(
          onTap: () => _showEditDialog(context, controller, store),
          child: Icon(Icons.edit_square, color: AppColors.primary, size: 16.r),
        ),
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
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Store Room',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'Store Name',
                      style: AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                  TextFormField(
                    controller: controller.storeNameController,
                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Enter store name',
                      hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: const BorderSide(
                          color: Color(0xffF15A24),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Select State',
                      style: AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Select District',
                      style: AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      isSingleSelect: true,
                      selectedValues: controller.selectedStateId.value != null
                          ? {controller.selectedStateId.value!}
                          : {},
                      items: controller.stateOptions
                          .map<DropdownMenuItem<String>>(
                            (opt) => DropdownMenuItem<String>(
                              value: opt.value,
                              child: Text(
                                opt.label,
                                style: AppTextStyle.style_12_400(color: AppColors.grey900),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.onStateSelected(values.isNotEmpty ? values.first : null);
                      },
                    )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      isSingleSelect: true,
                      selectedValues: controller.selectedDistrictId.value != null
                          ? {controller.selectedDistrictId.value!}
                          : {},
                      items: controller.districtOptions
                          .map<DropdownMenuItem<String>>(
                            (opt) => DropdownMenuItem<String>(
                              value: opt.value,
                              child: Text(
                                opt.label,
                                style: AppTextStyle.style_12_400(color: AppColors.grey900),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.selectedDistrictId.value = values.isNotEmpty ? values.first : null;
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey300,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(() => AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    height: 36.h,
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
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
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
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: SingleChildScrollView(
          child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Store Room',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'Store Name',
                      style: AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                  TextFormField(
                    controller: controller.storeNameController,
                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Enter store name',
                      hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: const BorderSide(
                          color: Color(0xffF15A24),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Select State',
                      style: AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Select District',
                      style: AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      isSingleSelect: true,
                      selectedValues: controller.selectedStateId.value != null
                          ? {controller.selectedStateId.value!}
                          : {},
                      items: controller.stateOptions
                          .map<DropdownMenuItem<String>>(
                            (opt) => DropdownMenuItem<String>(
                              value: opt.value,
                              child: Text(
                                opt.label,
                                style: AppTextStyle.style_12_400(color: AppColors.grey900),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.onStateSelected(values.isNotEmpty ? values.first : null);
                      },
                    )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      isSingleSelect: true,
                      selectedValues: controller.selectedDistrictId.value != null
                          ? {controller.selectedDistrictId.value!}
                          : {},
                      items: controller.districtOptions
                          .map<DropdownMenuItem<String>>(
                            (opt) => DropdownMenuItem<String>(
                              value: opt.value,
                              child: Text(
                                opt.label,
                                style: AppTextStyle.style_12_400(color: AppColors.grey900),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.selectedDistrictId.value = values.isNotEmpty ? values.first : null;
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey300,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(() => AppCommonButton(
                    text: 'Update',
                    width: 100.w,
                    height: 36.h,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final success = await controller.editStore(store.id);
                            if (success && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              controller.fetchStoreRooms();
                            }
                          },
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
