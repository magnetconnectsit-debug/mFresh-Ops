import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/asset_category_controller.dart';

Future<void> showAssetCategoryDialog(
  BuildContext context,
  AssetCategoryController controller, {
  AssetCategoryModel? category,
}) async {
  if (category != null) {
    controller.categoryNameCtrl.text = category.assetCatName;
  } else {
    controller.categoryNameCtrl.clear();
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category != null ? 'Edit Asset Category' : 'Create Asset Category',
                      style: AppTextStyle.style_16_700(color: AppColors.black),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(Icons.close, size: 20.r, color: AppColors.grey500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppCommonTextField(
                  controller: controller.categoryNameCtrl,
                  labelText: 'Asset Category Name',
                  hintText: 'Enter asset category name',
                  isRequired: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Asset category name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_14_600(color: AppColors.grey600),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => AppCommonButton(
                        text: category != null ? 'Update' : 'Submit',
                        isLoading: controller.isSubmitting.value,
                        buttonColor: AppColors.primary,
                        height: 34.h,
                        textSize: 13.sp,
                        onPressed: () async {
                          final success = await controller.submitCategory(
                            categoryId: category?.id,
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

Future<void> showDeleteCategoryDialog(
  BuildContext context,
  AssetCategoryController controller,
  AssetCategoryModel category,
) async {
  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.red,
            size: 26.r,
          ),
          SizedBox(width: 8.w),
          Text(
            'Delete Category',
            style: AppTextStyle.style_16_700(color: AppColors.black),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete "${category.assetCatName}"?',
        style: AppTextStyle.style_14_400(color: AppColors.grey700),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'Cancel',
            style: AppTextStyle.style_14_500(color: AppColors.grey600),
          ),
        ),
        AppCommonButton(
          text: 'Delete',
          buttonColor: AppColors.red,
          height: 32.h,
          textSize: 13.sp,
          onPressed: () {
            Navigator.of(dialogContext).pop();
            controller.deleteCategory(category.id);
          },
        ),
      ],
    ),
  );
}
