import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_common_export_button.dart';
import '../controllers/consumption_controller.dart';
import '../../../widgets/common_sidebar.dart';

class AllConsumptionScreen extends StatelessWidget {
  const AllConsumptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsumptionController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search Item, Source or Category...',
                  onChanged: (v) => controller.applyFilters(),
                )
              : Text(
                  'All Consumption',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFiltersSection(context, controller),
          _buildActionButtons(controller),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.consumptionItems.length,
                itemBuilder: (context, index) {
                  final item = controller.consumptionItems[index];
                  return _buildConsumptionCard(item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionCard(ConsumptionItemModel item) {
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
                item.consumedOn,
                style: AppTextStyle.style_10_600(color: AppColors.grey300),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.sourceType,
                  style: AppTextStyle.style_10_600(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item,
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.category,
                      style: AppTextStyle.style_10_600(color: AppColors.grey300),
                    ),
                  ],
                ),
              ),
              Text(
                item.quantity,
                style: AppTextStyle.style_14_700(color: AppColors.red),
              ),
            ],
          ),
          Divider(height: 24.h, color: AppColors.grey50),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.r, color: AppColors.info),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  '${item.source} (${item.district}, ${item.state})',
                  style: AppTextStyle.style_11_600(color: AppColors.black1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        'Filters',
        style: AppTextStyle.style_14_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, ConsumptionController controller) {
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
          Row(
            children: [
              Expanded(
                child: AppCommonTextField(
                  controller: controller.fromDateController,
                  titleText: 'From Date',
                  hintText: 'dd-mm-yyyy',
                  height: 32.h,
                  readOnly: true,
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 16.r),
                  onTap: () => controller.selectDate(context, controller.fromDateController),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppCommonTextField(
                  controller: controller.toDateController,
                  titleText: 'To Date',
                  hintText: 'dd-mm-yyyy',
                  height: 32.h,
                  readOnly: true,
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 16.r),
                  onTap: () => controller.selectDate(context, controller.toDateController),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<String>(
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
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<String>(
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
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<String>(
                    title: 'Store(s)',
                    hintText: 'Select Store',
                    isMultiSelect: true,
                    options: controller.storeOptions,
                    selectedValues: controller.selectedStores.toList(),
                    onMultiSelectChanged: (values) {
                      controller.selectedStores.assignAll(values);
                      controller.applyFilters();
                    },
                    height: 32.h,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ConsumptionController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: AppCommonExportButton(
              onExportExcel: () => controller.exportToExcel(),
              onExportPdf: () => controller.exportToPdf(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
