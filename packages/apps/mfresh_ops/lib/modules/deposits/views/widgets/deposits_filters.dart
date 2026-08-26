import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';
import 'package:core/widgets/month_year_picker_field.dart';
import 'package:intl/intl.dart';

class DepositsFilters extends StatelessWidget {
  const DepositsFilters({super.key});

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
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
              GridView(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 4.h,
                  mainAxisExtent: 28.h,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Obx(() {
                    String? displayVal;
                    if (controller.fromMonth.value != null) {
                      try {
                        final parsed = DateFormat('yyyy-MM').parse(controller.fromMonth.value!);
                        displayVal = DateFormat('MMM-yyyy').format(parsed);
                      } catch (_) {
                        displayVal = controller.fromMonth.value;
                      }
                    }
                    return MonthYearPickerField(
                      value: displayVal,
                      label: 'From Month',
                      onChanged: (val) {
                        if (val == null) {
                          controller.fromMonth.value = null;
                        } else {
                          try {
                            final parsed = DateFormat('MMM-yyyy').parse(val);
                            controller.fromMonth.value = DateFormat('yyyy-MM').format(parsed);
                          } catch (_) {
                            controller.fromMonth.value = val;
                          }
                        }
                      },
                    );
                  }),
                  Obx(() {
                    String? displayVal;
                    if (controller.toMonth.value != null) {
                      try {
                        final parsed = DateFormat('yyyy-MM').parse(controller.toMonth.value!);
                        displayVal = DateFormat('MMM-yyyy').format(parsed);
                      } catch (_) {
                        displayVal = controller.toMonth.value;
                      }
                    }
                    return MonthYearPickerField(
                      value: displayVal,
                      label: 'To Month',
                      onChanged: (val) {
                        if (val == null) {
                          controller.toMonth.value = null;
                        } else {
                          try {
                            final parsed = DateFormat('MMM-yyyy').parse(val);
                            controller.toMonth.value = DateFormat('yyyy-MM').format(parsed);
                          } catch (_) {
                            controller.toMonth.value = val;
                          }
                        }
                      },
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
