import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/allotment_controller.dart';
import 'package:mfresh_ops/data/models/inventory/allotment_item_model.dart';
import '../../../widgets/common_sidebar.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class AllotmentScreen extends StatefulWidget {
  const AllotmentScreen({super.key});

  @override
  State<AllotmentScreen> createState() => _AllotmentScreenState();
}

class _AllotmentScreenState extends State<AllotmentScreen> {
  final Set<String> _expandedRows = {};

  void _toggleRow(String key) {
    setState(() {
      if (_expandedRows.contains(key)) {
        _expandedRows.remove(key);
      } else {
        _expandedRows.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllotmentController());

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      if (!userPermissions.contains('allotments_report')) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            hasBackButton: false,
            showAppDrawer: true,
            title: Text(
              'Allotments',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
          ),
          drawer: const CommonSidebar(),
          body: Center(
            child: Text(
              'You do not have permission to view this page.',
              style: AppTextStyle.style_14_400(color: AppColors.grey300),
            ),
          ),
        );
      }

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
                          allotmentId: 0,
                          dateOfAllotment: 'Loading Date...',
                          itemName: 'Loading Item Name',
                          source: 'Loading Source',
                          destination: 'Loading Destination',
                          quantity: '0',
                          unit: 'units',
                          allotmentBy: 'Loading...',
                          isReversed: 0,
                          reverseStatus: 'Active',
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
    });
  }

  Widget _buildTable(
    AllotmentController controller,
    bool isTableLoading,
    List<AllotmentItemModel> items,
  ) {
    final authRepo = Get.find<AuthRepository>();
    final hasReverse = authRepo.rxUserPermissions.contains('allotment_reverse');

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
                      if (hasReverse) 0: FixedColumnWidth(95.w), // Action
                      if (hasReverse) ...{
                        1: FixedColumnWidth(125.w), // Date Of Allotment
                        2: FixedColumnWidth(125.w), // Item Name
                        3: FixedColumnWidth(130.w), // Source
                        4: FixedColumnWidth(130.w), // Destination
                        5: FixedColumnWidth(75.w),  // Quantity
                        6: FixedColumnWidth(70.w),  // M_Unit
                        7: FixedColumnWidth(100.w), // Allotment By
                      } else ...{
                        0: FixedColumnWidth(125.w), // Date Of Allotment
                        1: FixedColumnWidth(125.w), // Item Name
                        2: FixedColumnWidth(130.w), // Source
                        3: FixedColumnWidth(130.w), // Destination
                        4: FixedColumnWidth(75.w),  // Quantity
                        5: FixedColumnWidth(70.w),  // M_Unit
                        6: FixedColumnWidth(100.w), // Allotment By
                      }
                    },
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                    ),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: AppColors.white),
                        children: [
                          if (hasReverse) _buildHeaderCell('Action'),
                          _buildHeaderCell('Date Of Allotment'),
                          _buildHeaderCell('Item Name'),
                          _buildHeaderCell('Source'),
                          _buildHeaderCell('Destination'),
                          _buildHeaderCell('Quantity'),
                          _buildHeaderCell('M_Unit'),
                          _buildHeaderCell('Allotment By'),
                        ],
                      ),
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final key = '${item.allotmentId}_$index';
                        final isExpanded = _expandedRows.contains(key);

                        return TableRow(
                          children: [
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
                                  onPressed: isTableLoading || item.isReversed == 1
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
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    item.isReversed == 1 ? 'Reversed' : 'Reverse',
                                    style: AppTextStyle.style_10_500(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            _buildDataCell(item.dateOfAllotment, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.itemName, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.source, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.destination, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.quantity, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.unit, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.allotmentBy, isExpanded, () => _toggleRow(key)),
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

  void _showReverseDialog(BuildContext context, AllotmentController controller, AllotmentItemModel item) {
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
                  'This will reverse the allotment and restore stock.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style_14_400(color: const Color(0xFF545454)),
                ),
                SizedBox(height: 24.h),
                Obx(() {
                  final isReversing = controller.isReversing.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isReversing
                            ? null
                            : () async {
                                await controller.reverseAllotment(item);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD33333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          elevation: 0,
                        ),
                        child: isReversing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Yes, Reverse it!',
                                style: AppTextStyle.style_14_600(color: AppColors.white),
                              ),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: isReversing ? null : () => Navigator.of(context).pop(),
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
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black).copyWith(fontSize: 11.sp),
      ),
    );
  }

  Widget _buildDataCell(String text, bool isExpanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
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
    final authRepo = Get.find<AuthRepository>();
    final hasExport = authRepo.rxUserPermissions.contains('Allotment_Report_export');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4),
      child: Row(
        children: [
          if (hasExport)
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
                  items: [10, 20, 50, 100, 500, 1000].map((int val) {
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
}
