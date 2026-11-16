// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/data/models/collections/admin_collection_model.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
// endregion

// region View
class AdminCollectionsTable extends StatelessWidget {
  const AdminCollectionsTable({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCollectionsController>();

    final double monthWidth = 60.w;
    final double dateWidth = 80.w;
    final double subColWidth = 70.w;
    final double unitWidth = subColWidth * 3; // Actual, Dashboard, Difference

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
                    _buildHeaderCell('Month', width: monthWidth, height: 48.h, hasLeftBorder: true),
                    _buildHeaderCell('Date', width: dateWidth, height: 48.h),
                    ...stores.map((store) => _buildStoreHeader(store, unitWidth, subColWidth)),
                    _buildStoreHeader('Other', unitWidth, subColWidth),
                    _buildStoreHeader('Total', unitWidth, subColWidth),
                  ],
                ),
                // Data Rows
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: controller.filteredCollections.asMap().entries.map((entry) {
                        final row = entry.value;

                        return Row(
                          children: [
                            _buildDataCell(row.month, width: monthWidth, color: AppColors.white, hasLeftBorder: true),
                            _buildDataCell(row.date, width: dateWidth, color: AppColors.white),
                            ...stores.map((store) {
                              return _buildMetricCells(
                                row.storeMetrics[store],
                                subColWidth,
                                context: context,
                                date: row.date,
                                unitId: store,
                              );
                            }),
                            // Other
                            _buildMetricCells(row.otherMetrics, subColWidth, context: context, date: row.date, unitId: 'Other'),
                            // Total
                            _buildMetricCells(row.totalMetrics, subColWidth, isTotal: true),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  // endregion

  // region Header Builders
  Widget _buildStoreHeader(String title, double totalWidth, double subWidth) {
    return Column(
      children: [
        _buildHeaderCell(title, width: totalWidth, height: 24.h, isInside: false),
        Row(
          children: [
            _buildHeaderCell('Actual', width: subWidth, height: 24.h, isInside: true),
            _buildHeaderCell('Revenue Report', width: subWidth, height: 24.h, isInside: true),
            _buildHeaderCell('Difference', width: subWidth, height: 24.h, isInside: false),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(
    String text, {
    required double width,
    required double height,
    bool isInside = false,
    bool hasLeftBorder = false,
  }) {
    final borderColor = isInside ? const Color(0xFF475569) : AppColors.borderColor;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.collectionHeader, // Dark blue header
        border: Border(
          left: hasLeftBorder
              ? const BorderSide(color: AppColors.borderColor, width: 1.0)
              : BorderSide.none,
          bottom: const BorderSide(color: AppColors.black, width: 1.0),
          right: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_10_500(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  // endregion

  // region Metric & Data Builders
  Widget _buildMetricCells(
    AdminStoreMetricModel? metric,
    double width, {
    bool isTotal = false,
    BuildContext? context,
    String? date,
    String? unitId,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // Actual Cell
    Color actualBg = AppColors.collectionPink;
    String actualText = currencyFormat.format(metric?.actualNum ?? 0);

    // Dashboard Cell
    String dashText = currencyFormat.format(metric?.dashboardNum ?? 0);

    // Difference Cell
    Color diffBg = const Color(0xFFD6F0CD); // Light Green
    Color diffTextCol = AppColors.primaryGreen;
    String diffText = currencyFormat.format(0);

    if (metric != null) {
      if (metric.differenceNum < 0) {
        diffBg = const Color(0xFFFDE8E8); // Light Red
        diffTextCol = Colors.red;
      }
      diffText = currencyFormat.format(metric.differenceNum);
    }

    // Allow clicking even if isEmpty is true
    final bool isClickable = !isTotal && date != null && context != null && unitId != null;

    Widget actualCell = _buildDataCell(
      actualText,
      width: width,
      color: actualBg,
      isInside: true, // Lightened inside border between Actual and Revenue
    );
    if (isClickable) {
      actualCell = InkWell(
        onTap: () => _showUpdateDialog(context, date, unitId, currentValue: metric?.actualNum),
        child: actualCell,
      );
    }

    return Row(
      children: [
        actualCell,
        _buildDataCell(
          dashText,
          width: width,
          color: AppColors.white,
          isInside: true, // Lightened inside border between Revenue and Difference
        ),
        _buildDataCell(
          diffText,
          width: width,
          color: diffBg,
          textColor: diffTextCol,
          isBold: true,
          isInside: false, // Solid black border at the end of the unit group
        ),
      ],
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    Color color = AppColors.white,
    Color? textColor,
    bool isBold = false,
    bool isInside = false,
    bool hasLeftBorder = false,
  }) {
    return Container(
      width: width,
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        border: Border(
          left: hasLeftBorder
              ? const BorderSide(color: AppColors.black, width: 1.0)
              : BorderSide.none,
          bottom: const BorderSide(color: AppColors.black, width: 1.0),
          right: BorderSide(
            color: isInside ? const Color(0xFFCBD5E1) : AppColors.black,
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: isBold
              ? AppTextStyle.style_10_500(color: textColor ?? AppColors.black)
              : AppTextStyle.style_10_400(color: textColor ?? AppColors.black),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  void _showUpdateDialog(BuildContext context, String date, String unitId, {num? currentValue}) {
    final TextEditingController actualController = TextEditingController(
      text: currentValue != null && currentValue != 0 ? currentValue.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
                AppCommonTextField(
                  controller: actualController,
                  titleText: 'Actual Collection Value',
                  hintText: 'Enter value',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12.w, top: 12.h),
                    child: Text(
                      '₹ ',
                      style: AppTextStyle.style_14_600(color: AppColors.grey800),
                    ),
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
                    AppCommonButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      onPressed: () => Get.back(),
                    ),
                    SizedBox(width: 8.w),
                    AppCommonButton(
                      text: 'Save',
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final double value = double.parse(actualController.text.trim());
                          Get.back(); // Close dialog
                          
                          final adminController = Get.find<AdminCollectionsController>();
                          await adminController.updateActualValue(date: date, unitId: unitId, actual: value);
                        }
                      },
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
  // endregion
}
// endregion
