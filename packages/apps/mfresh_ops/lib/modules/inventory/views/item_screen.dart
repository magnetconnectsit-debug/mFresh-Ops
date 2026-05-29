import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/item_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'widgets/inventory_item_dialog.dart';

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Text(
          'Items',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        actions: [
          SizedBox(width: 16.w),
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
                    onPressed: () => showItemFormDialog(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Text(
                      'Add Items',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
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
                  final items = isTableLoading 
                    ? List.generate(
                        10, 
                        (index) => ItemModel(
                          siNo: index + 1,
                          itemName: 'Loading Item Name',
                          itemId: 'Loading ID',
                          measurement: 'Loading...',
                          category: '',
                          lowQuantityStore: '',
                          lowQuantityUnit: '',
                        )
                      )
                    : controller.filteredItems;

                  if (items.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(32.r),
                      child: Center(
                        child: Text('No items found', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32.w),
                          child: Skeletonizer(
                            enabled: isTableLoading,
                            child: Table(
                              columnWidths: const {
                                0: IntrinsicColumnWidth(), // Sl No
                                1: IntrinsicColumnWidth(), // Item Name
                                2: IntrinsicColumnWidth(), // Item ID
                                3: IntrinsicColumnWidth(), // Measurement
                                4: IntrinsicColumnWidth(), // Action
                              },
                              border: TableBorder.all(color: AppColors.grey50, width: 1),
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: AppColors.white),
                                  children: [
                                    _buildHeaderCell('Sl No'),
                                    _buildHeaderCell('Item Name'),
                                    _buildHeaderCell('Item ID'),
                                    _buildHeaderCell('Measurement'),
                                    _buildHeaderCell('Action'),
                                  ],
                                ),
                                ...items.map((item) {
                                  return TableRow(
                                    decoration: const BoxDecoration(color: AppColors.white),
                                    children: [
                                      _buildDataCell(item.siNo.toString()),
                                      _buildDataCell(item.itemName),
                                      _buildDataCell(item.itemId),
                                      _buildDataCell(item.measurement),
                                      isTableLoading ? _buildDataCell('') : _buildEditButton(context, controller, item),
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
                      'Showing 1 to ${controller.filteredItems.length} of ${controller.filteredItems.length} entries',
                      style: AppTextStyle.style_14_400(color: AppColors.black),
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
    ItemController controller,
    ItemModel item,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Center(
        child: InkWell(
          onTap: () => showItemFormDialog(context, controller, item: item),
          child: Icon(
            Icons.edit_square,
            color: AppColors.primary,
            size: 16.r,
          ),
        ),
      ),
    );
  }
}
