import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_export_button.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/allotment_controller.dart';

class AllotmentFilters extends StatelessWidget {
  const AllotmentFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AllotmentController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Card Container
        Container(
          padding: EdgeInsets.all(4.r),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
              final int crossAxis = isMobile ? 2 : 4;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
                  GridView(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 4.h,
                      mainAxisExtent: 28.h,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Single Date Range Field
                      _buildDateRangeField(context, controller),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // Action Row: Export & Per Page Count
        _buildActionButtons(controller),
      ],
    );
  }

  Widget _buildDateRangeField(
    BuildContext context,
    AllotmentController controller,
  ) {
    return InkWell(
      onTap: () => controller.selectDateRange(context),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          controller.fromDateController,
          controller.toDateController,
        ]),
        builder: (context, _) {
          final from = controller.fromDateController.text;
          final to = controller.toDateController.text;
          String displayVal = '';
          if (from.isNotEmpty && to.isNotEmpty) {
            displayVal = from == to ? from : '$from - $to';
          } else if (from.isNotEmpty) {
            displayVal = from;
          } else if (to.isNotEmpty) {
            displayVal = to;
          }

          final hasDates = displayVal.isNotEmpty;

          return InputDecorator(
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: 'Select Date Range',
                  style: AppTextStyle.style_11_400(
                    color: AppColors.grey200,
                  ),
                ),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 3.0.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hasDates ? displayVal : 'Select Date Range',
                    style: hasDates
                        ? AppTextStyle.style_12_400(color: AppColors.grey900)
                        : AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.grey300,
                  size: 14.r,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(AllotmentController controller) {
    final authRepo = Get.find<AuthRepository>();
    final hasExport = authRepo.rxUserPermissions.contains('Allotment_Report_export');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          if (hasExport)
            AppCommonExportButton(
              onExportExcel: () => controller.exportToExcel(),
            ),
          const Spacer(),
          Obx(
            () => Container(
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.perPage.value,
                  dropdownColor: AppColors.white,
                  style: AppTextStyle.style_12_500(color: AppColors.black),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 16.r,
                    color: AppColors.black,
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
}
