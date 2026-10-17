import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
import 'package:intl/intl.dart';

class DepositsFilters extends StatelessWidget {
  const DepositsFilters({super.key});

  Future<void> _openMonthPicker(BuildContext context, DepositsController controller) async {
    DateTime? initialStart;
    DateTime? initialEnd;

    if (controller.fromMonth.value != null) {
      try {
        initialStart = DateFormat('yyyy-MM').parse(controller.fromMonth.value!);
      } catch (_) {}
    }
    if (controller.toMonth.value != null) {
      try {
        initialEnd = DateFormat('yyyy-MM').parse(controller.toMonth.value!);
      } catch (_) {}
    }

    final DateTimeRange? picked = await showMonthRangePicker(
      context,
      initialStartMonth: initialStart,
      initialEndMonth: initialEnd,
    );

    if (picked != null) {
      controller.fromMonth.value = DateFormat('yyyy-MM').format(picked.start);
      controller.toMonth.value = DateFormat('yyyy-MM').format(picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositsController>();

    return Container(
      padding: EdgeInsets.all(4.r),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4.w, top: 2.h, bottom: 4.h),
                child: Text(
                  'Filters',
                  style: AppTextStyle.style_14_600(color: AppColors.black),
                ),
              ),
              Obx(() {
                final hasFilter = controller.fromMonth.value != null || controller.toMonth.value != null;
                if (!hasFilter) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: controller.resetFilters,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4.w, top: 2.h, bottom: 8.h),
                    child: Text(
                      'Reset',
                      style: AppTextStyle.style_12_600(color: const Color(0xffF15A24)),
                    ),
                  ),
                );
              }),
            ],
          ),
          Obx(() {
            final fromVal = controller.fromMonth.value;
            final toVal = controller.toMonth.value;
            String displayVal = '';

            String formatVal(String val) {
              try {
                final parsed = DateFormat('yyyy-MM').parse(val);
                return DateFormat('MMM yyyy').format(parsed);
              } catch (_) {
                return val;
              }
            }

            if (fromVal != null && toVal != null) {
              displayVal = fromVal == toVal
                  ? formatVal(fromVal)
                  : '${formatVal(fromVal)} - ${formatVal(toVal)}';
            } else if (fromVal != null) {
              displayVal = formatVal(fromVal);
            } else if (toVal != null) {
              displayVal = formatVal(toVal);
            }

            final hasValue = displayVal.isNotEmpty;

            return InkWell(
              onTap: () => _openMonthPicker(context, controller),
              borderRadius: BorderRadius.circular(4.r),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Month',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hasValue ? displayVal : 'Select Month',
                        style: hasValue
                            ? AppTextStyle.style_12_400(color: AppColors.grey900)
                            : AppTextStyle.style_12_400(color: AppColors.grey300),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.calendar_month_outlined, size: 14.r, color: AppColors.grey300),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
