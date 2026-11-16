// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_brands_controller.dart';
// endregion

// region Brand Dialog Function
Future<void> showMContactBrandDialog(
  BuildContext context,
  MContactBrandsController controller, {
  Map<String, dynamic>? brand,
}) async {
  if (brand != null) {
    controller.brandNameCtrl.text = brand['name']?.toString() ?? '';
  } else {
    controller.brandNameCtrl.clear();
  }

  await showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand != null ? 'Edit Brand' : 'Create Brand',
                  style: AppTextStyle.style_16_700(color: AppColors.black),
                ),
                SizedBox(height: 20.h),
                AppCommonTextField(
                  controller: controller.brandNameCtrl,
                  hintText: 'Enter brand name',
                  labelText: 'Brand Name',
                  isRequired: true,
                  height: 38.h,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async {
                    final success = await controller.submitBrand(
                      brandId: brand?['id'] as int?,
                    );
                    if (success && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Brand name is required';
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
                      buttonColor: AppColors.white,
                      borderColor: AppColors.borderColor,
                      textColor: AppColors.grey600,
                      height: 34.h,
                      width: 80.w,
                      borderRadius: 6.r,
                      textSize: 13.sp,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => AppCommonButton(
                        text: brand != null ? 'Update' : 'Submit',
                        isLoading: controller.isLoading.value,
                        buttonColor: AppColors.primary,
                        textColor: AppColors.white,
                        height: 34.h,
                        width: 80.w,
                        borderRadius: 6.r,
                        textSize: 13.sp,
                        onPressed: () async {
                          final success = await controller.submitBrand(
                            brandId: brand?['id'] as int?,
                          );
                          if (success && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
// endregion
