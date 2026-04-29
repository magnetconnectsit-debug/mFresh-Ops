import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_common_export_button.dart';
import '../controllers/unit_inventory_controller.dart';
import '../../../widgets/common_sidebar.dart';

class UnitInventoryScreen extends StatelessWidget {
  const UnitInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnitInventoryController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => controller.isSearching.value
            ? AppCommonSearchBar(
                controller: controller.searchController,
                hintText: 'Search Unit or Item...',
                onChanged: (v) => controller.applyFilters(),
              )
            : Text(
                'All Unit Inventory',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              )),
        actions: [
          Obx(() => IconButton(
                onPressed: () => controller.toggleSearch(),
                icon: Icon(controller.isSearching.value
                    ? Icons.close
                    : Icons.search),
              )),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        children: [
          _buildFiltersSection(),
          _buildActionButtons(context),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.unitInventoryItems.length,
                itemBuilder: (context, index) {
                  final item = controller.unitInventoryItems[index];
                  return _buildUnitCard(item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard(UnitInventoryModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.unitName,
                style: AppTextStyle.style_12_700(color: AppColors.primary),
              ),
              Text(
                item.itemName,
                style: AppTextStyle.style_14_700(color: AppColors.black),
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.grey50),
          Row(
            children: [
              _buildBalanceInfo('Opening', item.openingBalance, AppColors.grey300),
              _buildBalanceInfo('Receipt', item.receipt, AppColors.info),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildBalanceInfo('Consumption', item.consumption, AppColors.red),
              _buildBalanceInfo('Closing', item.closingBalance, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.style_10_600(color: AppColors.grey300),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTextStyle.style_12_700(color: color),
          ),
        ],
      ),
    );
  }




  Widget _buildFiltersSection() {
    final controller = Get.find<UnitInventoryController>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => AppCommonDropdown<String>(
                  title: 'Unit(s)',
                  hintText: 'Select Unit',
                  isMultiSelect: true,
                  options: controller.unitOptions,
                  selectedValues: controller.selectedUnits.toList(),
                  onMultiSelectChanged: (values) {
                    controller.selectedUnits.assignAll(values);
                    controller.applyFilters();
                  },
                  height: 32.h,
                )),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(() => AppCommonDropdown<String>(
                  title: 'Item(s)',
                  hintText: 'Select Item',
                  isMultiSelect: true,
                  options: controller.itemOptions,
                  selectedValues: controller.selectedItems.toList(),
                  onMultiSelectChanged: (values) {
                    controller.selectedItems.assignAll(values);
                    controller.applyFilters();
                  },
                  height: 32.h,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final controller = Get.find<UnitInventoryController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Add Item',
              AppColors.primary,
              Icons.add,
              () => _showAddInventorySheet(context),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppCommonExportButton(
              onExportExcel: () => controller.exportToExcel(),
              onExportPdf: () => controller.exportToPdf(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 36.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.r),
        label: Text(
          label,
          style: AppTextStyle.style_12_600(color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
      ),
    );
  }

  void _showAddInventorySheet(BuildContext context) {
    // Add item logic
  }


}
