import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_audit_controller.dart';

class AuditFilterWidget extends StatelessWidget {
  const AuditFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryAuditController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingUnits.value) {
                return const CustomAppLoader();
              }
              return MultiSelectDropdownWidget<String>(
                label: 'Select Unit',
                hint: 'Choose unit',
                height: 26.h,
                selectedValues: controller.selectedUnitIds.toSet(),
                items: controller.unitOptions
                    .map(
                      (o) => DropdownMenuItem<String>(
                        value: o.value,
                        child: Text(
                          o.label,
                          style:
                              AppTextStyle.style_12_400(color: AppColors.black),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (selected) => controller.onUnitChanged(selected),
                showSearch: true,
                isSingleSelect: true,
              );
            }),
          ),
          SizedBox(width: 8.w),
          Obx(() {
            if (controller.selectedUnitIds.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              height: 26.h,
              margin: EdgeInsets.only(right: 6.w),
              child: ElevatedButton.icon(
                onPressed: () => controller.addAdditionalItemRow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009BD9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(Icons.add, size: 13.r, color: Colors.white),
                label: Text(
                  'Add Item',
                  style: AppTextStyle.style_10_600(color: Colors.white),
                ),
              ),
            );
          }),
          Obx(() {
            final isEnabled = controller.isSubmitEnabled;

            return SizedBox(
              height: 26.h,
              child: ElevatedButton(
                onPressed: isEnabled ? () => controller.submitAudit() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F7BF7),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  elevation: 1,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: controller.isSubmitting.value
                    ? SizedBox(
                        width: 12.r,
                        height: 12.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 13.r, color: Colors.white),
                          SizedBox(width: 3.w),
                          Text(
                            'Submit',
                            style: AppTextStyle.style_10_600(
                                color: Colors.white),
                          ),
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
