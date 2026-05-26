import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/consumption_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AllConsumptionScreen extends StatelessWidget {
  const AllConsumptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsumptionController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
      body: AppRefreshIndicator(
        onRefresh: () async {
          controller.fromDateController.clear();
          controller.toDateController.clear();
          controller.selectedUnits.clear();
          controller.selectedItems.clear();
          controller.selectedStores.clear();
          await controller.onRefresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFiltersSection(context, controller),
              _buildActionButtons(controller),
              Obx(
                () => _buildTable(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(ConsumptionController controller) {
    final isTableLoading = controller.isLoading.value;
    final items = isTableLoading
        ? List.generate(
            10,
            (index) => ConsumptionItemModel(
              consumedOn: '2023-01-01',
              state: 'State_Dummy',
              district: 'District_Dummy',
              sourceType: 'Store',
              source: 'Source_Dummy',
              category: 'Category_Dummy',
              item: 'Loading Item',
              consumedQty: '0',
              mUnit: 'pcs',
              createdBy: 'User',
            ),
          )
        : controller.consumptionItems;

    if (items.isEmpty && !controller.isSearching.value) {
      return Padding(
        padding: EdgeInsets.all(32.r),
        child: Center(
          child: Text('No consumption records found', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(Get.context!).size.width - 32.w),
              child: Skeletonizer(
                enabled: isTableLoading,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: IntrinsicColumnWidth(), // Consumed On
                    1: IntrinsicColumnWidth(), // State
                    2: IntrinsicColumnWidth(), // District
                    3: IntrinsicColumnWidth(), // Source Type
                    4: IntrinsicColumnWidth(), // Source
                    5: IntrinsicColumnWidth(), // Category
                    6: IntrinsicColumnWidth(), // Item
                    7: IntrinsicColumnWidth(), // Consumed Qty
                    8: IntrinsicColumnWidth(), // M_Unit
                    9: IntrinsicColumnWidth(), // Created By
                    10: IntrinsicColumnWidth(), // Action
                  },
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey.shade300),
                  ),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: AppColors.white),
                      children: [
                        _buildHeaderCell('Consumed On'),
                        _buildHeaderCell('State'),
                        _buildHeaderCell('District'),
                        _buildHeaderCell('Source Type'),
                        _buildHeaderCell('Source'),
                        _buildHeaderCell('Category'),
                        _buildHeaderCell('Item'),
                        _buildHeaderCell('Consumed Qty'),
                        _buildHeaderCell('M_Unit'),
                        _buildHeaderCell('Created By'),
                        _buildHeaderCell('Action'),
                      ],
                    ),
                    ...items.map((item) {
                      return TableRow(
                        children: [
                          _buildDataCell(item.consumedOn),
                          _buildDataCell(item.state),
                          _buildDataCell(item.district),
                          _buildDataCell(item.sourceType),
                          _buildDataCell(item.source),
                          _buildDataCell(item.category),
                          _buildDataCell(item.item),
                          _buildDataCell(item.consumedQty),
                          _buildDataCell(item.mUnit),
                          _buildDataCell(item.createdBy),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            height: 18.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE53935), Color(0xFFC62828)],
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: ElevatedButton(
                              onPressed: () => _showReverseDialog(Get.context!, controller, item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                              ),
                              child: Text('Reverse', style: AppTextStyle.style_12_500(color: AppColors.white)),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Showing 1 to ${controller.consumptionItems.length} of ${controller.allConsumptionItems.length} entries',
            style: AppTextStyle.style_14_400(color: AppColors.black),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildFiltersSection(
    BuildContext context,
    ConsumptionController controller,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          int crossAxis = isMobile ? 2 : 4;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4.w, top: 2.h, bottom: 8.h),
                child: Text(
                  'Filters',
                  style: AppTextStyle.style_14_600(color: AppColors.black),
                ),
              ),
              GridView(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  mainAxisExtent: 32.h,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDatePickerField(
                    'From Date',
                    controller.fromDateController,
                    () => controller.selectDate(
                      context,
                      controller.fromDateController,
                    ),
                  ),
                  _buildDatePickerField(
                    'To Date',
                    controller.toDateController,
                    () => controller.selectDate(
                      context,
                      controller.toDateController,
                    ),
                  ),
                  Obx(
                    () => MultiSelectDropdownWidget<String>(
                      label: 'Unit(s)',
                      selectedValues: controller.selectedUnits.toSet(),
                      items: controller.unitOptions
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
                        controller.selectedUnits.assignAll(values.toList());
                        controller.applyFilters();
                      },
                    ),
                  ),
                  Obx(
                    () => MultiSelectDropdownWidget<String>(
                      label: 'Item(s)',
                      selectedValues: controller.selectedItems.toSet(),
                      items: controller.itemOptions
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
                        controller.selectedItems.assignAll(values.toList());
                        controller.applyFilters();
                      },
                    ),
                  ),
                  Obx(
                    () => MultiSelectDropdownWidget<String>(
                      label: 'Store(s)',
                      selectedValues: controller.selectedStores.toSet(),
                      items: controller.storeOptions
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
                        controller.selectedStores.assignAll(values.toList());
                        controller.applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(ConsumptionController controller) {
    return Padding(
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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.grey50),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.grey50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return Text(
                    value.text.isEmpty ? label : value.text,
                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 14.r, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }

  void _showReverseDialog(BuildContext context, ConsumptionController controller, ConsumptionItemModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF8BB86), width: 4.w),
                  ),
                  child: Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFF8BB86),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Confirm Reverse',
                  style: AppTextStyle.style_14_600(color: const Color(0xFF545454)).copyWith(fontSize: 22.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  'This will reverse the consumption and restore stock.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style_14_400(color: const Color(0xFF545454)),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // TODO: Implement reverse action using controller
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD33333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Yes, Reverse it!',
                        style: AppTextStyle.style_14_600(color: AppColors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C757D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_14_600(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
