import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_common_export_button.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/allotment_controller.dart';
import '../../../widgets/common_sidebar.dart';

class AllotmentScreen extends StatelessWidget {
  const AllotmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllotmentController());

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
                  hintText: 'Search by Item, Source...',
                )
              : Text(
                  'Allotments',
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
          // Reset filters and refresh
          controller.fromDateController.clear();
          controller.toDateController.clear();
          await controller.onRefresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFiltersSection(context, controller),
              _buildActionButtons(controller),
              Obx(() {
                final isTableLoading = controller.isLoading.value;
                final items = isTableLoading
                  ? List.generate(
                      5,
                      (index) => AllotmentItemModel(
                        dateOfAllotment: 'Loading Date...',
                        itemName: 'Loading Item Name',
                        source: 'Loading Source',
                        destination: 'Loading Destination',
                        quantity: '0',
                        unit: 'units',
                        allotmentBy: 'Loading...',
                      )
                    )
                  : controller.allotmentItems;

                if (items.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(32.r),
                    child: Center(
                      child: Text('No allotments found', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
                    ),
                  );
                }

                return _buildTable(controller, isTableLoading, items);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(AllotmentController controller, bool isTableLoading, List<AllotmentItemModel> items) {
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
                      0: IntrinsicColumnWidth(), // Date Of Allotment
                      1: IntrinsicColumnWidth(), // Item Name
                      2: IntrinsicColumnWidth(), // Source
                      3: IntrinsicColumnWidth(), // Destination
                      4: IntrinsicColumnWidth(), // Quantity
                      5: IntrinsicColumnWidth(), // M_Unit
                      6: IntrinsicColumnWidth(), // Allotment By
                    },
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                    ),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: AppColors.white),
                        children: [
                          _buildHeaderCell('Date Of Allotment'),
                          _buildHeaderCell('Item Name'),
                          _buildHeaderCell('Source'),
                          _buildHeaderCell('Destination'),
                          _buildHeaderCell('Quantity'),
                          _buildHeaderCell('M_Unit'),
                          _buildHeaderCell('Allotment By'),
                        ],
                      ),
                      ...items.map((item) {
                        return TableRow(
                          children: [
                            _buildDataCell(item.dateOfAllotment),
                            _buildDataCell(item.itemName),
                            _buildDataCell(item.source),
                            _buildDataCell(item.destination),
                            _buildDataCell(item.quantity),
                            _buildDataCell(item.unit),
                            _buildDataCell(item.allotmentBy),
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
            'Showing 1 to ${controller.allotmentItems.length} of ${controller.allotmentItems.length} entries',
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
    AllotmentController controller,
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
                    'From Month',
                    controller.fromDateController,
                    () => controller.selectDate(
                      context,
                      controller.fromDateController,
                    ),
                  ),
                  _buildDatePickerField(
                    'To Month',
                    controller.toDateController,
                    () => controller.selectDate(
                      context,
                      controller.toDateController,
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

  Widget _buildActionButtons(AllotmentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          AppCommonButton(
            text: 'Apply',
            onPressed: () => controller.applyFilters(),
            height: 28.h,
            width: 80.w,
            textSize: 12.sp,
          ),
          SizedBox(width: 10.w),
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
}
