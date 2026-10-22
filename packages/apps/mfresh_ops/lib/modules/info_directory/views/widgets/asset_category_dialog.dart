// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/asset_category_controller.dart';
// endregion

// region Asset Category Create/Edit Dialog
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
        constraints: BoxConstraints(maxWidth: 480.w),
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
                      category != null
                          ? 'Edit Asset Category'
                          : 'Create Asset Category',
                      style: AppTextStyle.style_16_700(color: AppColors.black),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.close,
                          size: 20.r,
                          color: AppColors.grey500,
                        ),
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
                  height: 38.h,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async {
                    final success = await controller.submitCategory(
                      categoryId: category?.id,
                    );
                    if (success && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
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
                        text: category != null ? 'Update' : 'Submit',
                        isLoading: controller.isSubmitting.value,
                        buttonColor: AppColors.primary,
                        textColor: AppColors.white,
                        height: 34.h,
                        width: 80.w,
                        borderRadius: 6.r,
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
// endregion

// region Delete Category Confirmation Dialog
Future<void> showDeleteCategoryDialog(
  BuildContext context,
  AssetCategoryController controller,
  AssetCategoryModel category,
) async {
  final confirmed = await AppCommonDialogBox.showConfirm(
    context,
    title: 'Delete Category',
    message: 'Are you sure you want to delete "${category.assetCatName}"?',
    confirmText: 'Delete',
    cancelText: 'Cancel',
  );
  if (confirmed) {
    controller.deleteCategory(category.id);
  }
}
// endregion
