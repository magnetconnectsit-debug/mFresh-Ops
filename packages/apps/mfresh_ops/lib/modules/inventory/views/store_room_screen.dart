import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_export_button.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/store_room_controller.dart';
import '../../../widgets/common_sidebar.dart';

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
        title: Text(
          'Store Rooms',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
        actions: [SizedBox(width: 16.w)],
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
                            siNo: index + 1,
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
                      Skeletonizer(
                        enabled: isTableLoading,
                        child: Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(), // Sl No
                            1: FlexColumnWidth(1), // Store Name
                            2: IntrinsicColumnWidth(), // Action
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
                                  _buildDataCell(store.siNo.toString()),
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
          onTap: () => _showEditDialog(context, controller, store, index),
          child: Icon(Icons.edit_square, color: AppColors.primary, size: 16.r),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, StoreRoomController controller) {
    controller.storeNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Add Store Room', style: AppTextStyle.style_14_700()),
        content: AppCommonTextField(
          controller: controller.storeNameController,
          titleText: 'Store Name',
          hintText: 'Enter store name',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Add',
            onPressed: () => controller.addStore(),
            width: 80.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StoreRoomController controller,
    StoreRoomModel store,
    int index,
  ) {
    controller.storeNameController.text = store.storeName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Edit Store Room', style: AppTextStyle.style_14_700()),
        content: AppCommonTextField(
          controller: controller.storeNameController,
          titleText: 'Store Name',
          hintText: 'Enter store name',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Update',
            onPressed: () => controller.editStore(
              index,
              controller.storeNameController.text,
            ),
            width: 80.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }
}
