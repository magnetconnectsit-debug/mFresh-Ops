import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/collections/controllers/old_collections_controller.dart';


class OldCollectionsTable extends StatefulWidget {
  const OldCollectionsTable({super.key});

  @override
  State<OldCollectionsTable> createState() => _OldCollectionsTableState();
}

class _OldCollectionsTableState extends State<OldCollectionsTable> {
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
    final controller = Get.find<OldCollectionsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: Obx(() {
                if (controller.filteredCollections.isEmpty && !controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.all(20.r),
                    child: const Text('No collections found.'),
                  );
                }

                if (controller.isLoading.value) {
                  return SizedBox(
                    width: Get.width - 32.w,
                    child: Padding(
                      padding: EdgeInsets.all(40.r),
                      child: const CustomAppLoader(),
                    ),
                  );
                }

                final itemsToRender = controller.paginatedItems;

                return Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey.shade300),
                  ),
                    columnWidths: {
                      0: FixedColumnWidth(95.w), // Date
                      1: FixedColumnWidth(85.w), // Unit
                      2: FixedColumnWidth(75.w), // Daily Cash
                      3: FixedColumnWidth(75.w), // Cash Collection
                      4: FixedColumnWidth(75.w), // Cash Deposit
                      5: FixedColumnWidth(95.w), // Action
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildHeaderCell('Date'),
                          _buildHeaderCell('Unit'),
                          _buildHeaderCell('Daily Cash'),
                          _buildHeaderCell('Cash Collection'),
                          _buildHeaderCell('Cash Deposit'),
                          _buildHeaderCell('Action'),
                        ],
                      ),
                      ...itemsToRender.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final key = '${item.id}_$index';
                        final isExpanded = _expandedRows.contains(key);

                        return TableRow(
                          children: [
                            _buildDataCell(AppDateUtils.formatToApiDate(item.date), isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.unit, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(item.dailyCash, isExpanded, () => _toggleRow(key)),
                            _buildSwitchCell(
                                value: item.isCashCollection,
                                onChanged: (val) => controller.toggleCashCollection(item, val)),
                            _buildSwitchCell(
                                value: item.isCashDeposit,
                                onChanged: (val) => controller.toggleCashDeposit(item, val)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              child: SizedBox(
                                height: 22.h,
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.showAddCommentSheet(item),
                                  icon: Icon(Icons.comment_outlined, size: 10.r, color: Colors.white),
                                  label: Text('Comment', style: AppTextStyle.style_10_500(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC3545),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final totalItems = controller.filteredCollections.length;
          final startItem = totalItems == 0 ? 0 : ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + 1;
          final endItem = (startItem + controller.itemsPerPage.value - 1).clamp(0, totalItems);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPaginationButton('←', false, controller.previousPage),
                      ...List.generate(controller.totalPages, (index) {
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
                SizedBox(height: 8.h),
                Text(
                  'Showing $startItem to $endItem of $totalItems entries',
                  style: AppTextStyle.style_12_400(color: AppColors.black),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black).copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, bool isExpanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSwitchCell({required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.h),
      child: SizedBox(
        height: 20.h,
        child: Transform.scale(
          scale: 0.6,
          alignment: Alignment.centerLeft,
          child: Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.red,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(color: isActive ? Colors.white : Colors.blue.shade600),
        ),
      ),
    );
  }
}
