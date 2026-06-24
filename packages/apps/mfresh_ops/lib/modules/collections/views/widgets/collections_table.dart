import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/collections/controllers/collections_controller.dart';
import 'package:core/widgets/custom_app_loader.dart';

class CollectionsTable extends StatelessWidget {
  const CollectionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CollectionsController>();

    final double monthWidth = 60.w;
    final double dateWidth = 80.w;
    final double unitWidth = 90.w;

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          width: double.infinity,
          height: 300.h,
          child: const Center(child: CustomAppLoader()),
        );
      }

      if (controller.filteredCollections.isEmpty) {
        return const Center(child: Text('No data found'));
      }

      final stores = controller.storeNames;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Area
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCell('Month', width: monthWidth),
                    _buildHeaderCell('Date', width: dateWidth),
                    ...stores.map(
                      (store) => _buildHeaderCell(store, width: unitWidth),
                    ),
                    _buildHeaderCell('Other', width: unitWidth),
                    _buildHeaderCell('Total Actual', width: unitWidth),
                  ],
                ),
                // Data Rows
                ...controller.filteredCollections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final bool isEven = index % 2 == 0;

                  return Row(
                    children: [
                      _buildDataCell(row.month, width: monthWidth),
                      _buildDataCell(row.date, width: dateWidth),
                      ...stores.map((store) {
                        final actualValue = row.storeMetrics[store]?.actualNum;
                        return _buildUnitCell(
                          actualValue,
                          width: unitWidth,
                          isEven: isEven,
                          context: context,
                          date: row.date,
                          unitId: store,
                        );
                      }),
                      // Other
                      _buildUnitCell(
                        row.otherMetrics.actualNum,
                        width: unitWidth,
                        isEven: isEven,
                        context: context,
                        date: row.date,
                        unitId: 'Other',
                      ),
                      // Total
                      _buildDataCell(
                        row.totalMetrics.actual,
                        width: unitWidth,
                        color: AppColors
                            .collectionPink, // Pinkish highlight for totals
                        isBold: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.collectionHeader, // Dark blue header
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_10_500(color: AppColors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    Color color = AppColors.white,
    bool isBold = false,
  }) {
    return Container(
      width: width,
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.black),
      ),
      child: Center(
        child: Text(
          text,
          style: isBold
              ? AppTextStyle.style_10_500(color: AppColors.black)
              : AppTextStyle.style_10_400(color: AppColors.black),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildUnitCell(
    num? value, {
    required double width,
    required bool isEven,
    BuildContext? context,
    String? date,
    String? unitId,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    Color bgColor;
    String text = '';

    final bool isEmpty = value == null || value == 0;
    if (isEmpty) {
      bgColor = AppColors.collectionPink; // Pink for empty/inactive
    } else {
      bgColor = AppColors.grey50; // Solid grey for all data cells
      text = currencyFormat.format(value);
    }

    final bool isCurrentMonthVal = date != null && _isCurrentMonth(date);
    final bool isClickable =
        isEmpty && isCurrentMonthVal && context != null && unitId != null;

    Widget cell = Container(
      width: width,
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: AppColors.black),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_10_400(color: AppColors.black),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (isClickable) {
      return InkWell(
        onTap: () => _showUpdateDialog(context, date, unitId),
        child: cell,
      );
    }
    return cell;
  }

  bool _isCurrentMonth(String dateStr) {
    try {
      DateTime parsedDate;
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
      } else {
        parsedDate = DateFormat('dd-MMM-yyyy').parse(dateStr);
      }
      final now = DateTime.now();
      return parsedDate.year == now.year && parsedDate.month == now.month;
    } catch (e) {
      debugPrint('Error parsing date in _isCurrentMonth: $e');
      return false;
    }
  }

  void _showUpdateDialog(BuildContext context, String date, String unitId) {
    final TextEditingController actualController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Actual Collection',
                  style: AppTextStyle.style_14_700(color: AppColors.black),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Unit: $unitId  |  Date: $date',
                  style: AppTextStyle.style_10_400(color: AppColors.grey600),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: actualController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Actual Collection Value',
                    labelStyle: AppTextStyle.style_12_400(
                      color: AppColors.grey600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_12_600(
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final double value = double.parse(
                            actualController.text.trim(),
                          );
                          Get.back(); // Close dialog

                          final userController =
                              Get.find<CollectionsController>();
                          await userController.updateActualValue(
                            date: date,
                            unitId: unitId,
                            actual: value,
                          );
                        }
                      },
                      child: Text(
                        'Save',
                        style: AppTextStyle.style_12_600(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
