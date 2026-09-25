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
          // Left Side: Selected Unit Name
          Obx(() {
            final selectedId = controller.selectedUnitIds.firstOrNull;
            final selectedOpt = controller.unitOptions
                .firstWhereOrNull((o) => o.value == selectedId);
            final unitName = selectedOpt?.label ?? selectedId ?? '';

            return InkWell(
              onTap: () => controller.clearSelectedUnit(),
              borderRadius: BorderRadius.circular(4.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront, size: 13.r, color: Colors.blue.shade900),
                    SizedBox(width: 4.w),
                    Text(
                      'Unit: $unitName',
                      style: AppTextStyle.style_11_600(color: Colors.blue.shade900),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.close, size: 12.r, color: Colors.blue.shade900),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          // Right Side: Add Item Button
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
          // Right Side: Submit Button
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
