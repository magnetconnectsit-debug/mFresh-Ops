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
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

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
              Obx(() => _buildTable(controller)),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(ConsumptionController controller) {
    final isTableLoading = controller.isLoading.value;
    final authRepo = Get.find<AuthRepository>();
    final hasReverse = authRepo.rxUserPermissions.contains('consumption_reverse');

    final items = isTableLoading
        ? List.generate(
            10,
            (index) => ConsumptionItemModel(
              id: index,
              consumedOn: '01-jan-2023',
              state: 'State_Dummy',
              district: 'District_Dummy',
              sourceType: 'Store',
              source: 'Source_Dummy',
              category: 'Category_Dummy',
              item: 'Loading Item',
              consumedQty: '0',
              mUnit: 'pcs',
              createdBy: 'User',
              isReversed: 0,
            ),
          )
        : controller.consumptionItems;

    if (items.isEmpty && !controller.isSearching.value) {
      return Padding(
        padding: EdgeInsets.all(32.r),
        child: Center(
          child: Text(
            'No consumption records found',
            style: AppTextStyle.style_14_400(color: AppColors.grey300),
          ),
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
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(Get.context!).size.width - 32.w,
                ),
                child: Skeletonizer(
                  enabled: isTableLoading,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      0: const IntrinsicColumnWidth(), // Consumed On
                      1: const IntrinsicColumnWidth(), // State
                      2: const IntrinsicColumnWidth(), // District
                      3: const IntrinsicColumnWidth(), // Source Type
                      4: const IntrinsicColumnWidth(), // Source
                      5: const IntrinsicColumnWidth(), // Category
                      6: const IntrinsicColumnWidth(), // Item
                      7: const IntrinsicColumnWidth(), // Consumed Qty
                      8: const IntrinsicColumnWidth(), // M_Unit
                      9: const IntrinsicColumnWidth(), // Created By
                      if (hasReverse) 10: const IntrinsicColumnWidth(), // Action
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
                          if (hasReverse) _buildHeaderCell('Action'),
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
                            if (hasReverse)
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                height: 18.h,
                                decoration: BoxDecoration(
                                  gradient: item.isReversed == 1
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFB0BEC5),
                                            Color(0xFF90A4AE),
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFE53935),
                                            Color(0xFFC62828),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: item.isReversed == 1
                                      ? null
                                      : () => _showReverseDialog(
                                            Get.context!,
                                            controller,
                                            item,
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    disabledForegroundColor: Colors.white70,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                  ),
                                  child: Text(
                                    item.isReversed == 1 ? 'Reversed' : 'Reverse',
                                    style: AppTextStyle.style_12_500(
                                      color: AppColors.white,
                                    ),
                                  ),
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
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPaginationButton('←', false, controller.previousPage),
                    ...List.generate(controller.totalPages.value, (index) {
                      final pageNumber = index + 1;
                      return _buildPaginationButton(
                        pageNumber.toString(),
                        controller.currentPage.value == pageNumber,
                        () => controller.goToPage(pageNumber),
                      );
                    }),
                    _buildPaginationButton('→', false, controller.nextPage),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Showing ${controller.totalEntries.value == 0 ? 0 : (controller.currentPage.value - 1) * controller.perPage.value + 1} to ${(controller.currentPage.value * controller.perPage.value).clamp(0, controller.totalEntries.value)} of ${controller.totalEntries.value} entries',
                style: AppTextStyle.style_12_400(color: AppColors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationButton(
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(
            color: isActive ? Colors.white : Colors.blue.shade600,
          ),
        ),
      ),
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
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
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
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
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
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
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
          const Spacer(),
          Obx(
            () => Container(
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.perPage.value,
                  dropdownColor: Colors.white,
                  style: AppTextStyle.style_12_500(color: AppColors.black),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 16.r,
                    color: Colors.grey.shade600,
                  ),
                  items: [10, 20, 50, 100].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text('$val per page'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.perPage.value = val;
                      controller.applyFilters();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
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
            Icon(
              Icons.calendar_today_outlined,
              size: 14.r,
              color: AppColors.grey300,
            ),
          ],
        ),
      ),
    );
  }

  void _showReverseDialog(
    BuildContext context,
    ConsumptionController controller,
    ConsumptionItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
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
                    border: Border.all(
                      color: const Color(0xFFF8BB86),
                      width: 4.w,
                    ),
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
                  style: AppTextStyle.style_14_600(
                    color: const Color(0xFF545454),
                  ).copyWith(fontSize: 22.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  'This will reverse the consumption and restore stock.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style_14_400(
                    color: const Color(0xFF545454),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        debugPrint('Yes, Reverse it! button tapped in Dialog');
                        controller.reverseConsumption(item);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD33333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Yes, Reverse it!',
                        style: AppTextStyle.style_14_600(
                          color: AppColors.white,
                        ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_14_600(
                          color: AppColors.white,
                        ),
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
