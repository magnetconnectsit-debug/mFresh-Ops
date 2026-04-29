import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_drop_down.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import '../controllers/support_subcategory_controller.dart';
import '../models/support_subcategory_model.dart';

class SupportSubCategoryScreen extends StatelessWidget {
  const SupportSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportSubCategoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Text(
          'Support\nSub Categories',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        actions: [
          AppCommonButton(
            text: 'Add Sub Cat',
            onPressed: () => _showAddDialog(context, controller),
            height: 32.h,
            width: 85.w,
            textSize: 10.sp,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Obx(
        () => ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: controller.filteredSubCategories.length,
          itemBuilder: (context, index) {
            final sub = controller.filteredSubCategories[index];
            return _buildSubCategoryCard(context, controller, sub, index);
          },
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard(
    BuildContext context,
    SupportSubCategoryController controller,
    SupportSubCategoryModel sub,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              sub.siNo.toString(),
              style: AppTextStyle.style_12_700(color: AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.subCategory,
                  style: AppTextStyle.style_14_600(color: AppColors.black),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Category: ${sub.category}',
                  style: AppTextStyle.style_11_400(color: AppColors.grey300),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditDialog(context, controller, sub, index),
            icon: Icon(Icons.edit_outlined, color: AppColors.info, size: 20.r),
          ),
          IconButton(
            onPressed: () =>
                _showDeleteConfirmation(context, controller, index),
            icon: Icon(Icons.delete_outline, color: AppColors.red, size: 20.r),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    SupportSubCategoryController controller,
  ) {
    controller.subCategoryNameController.clear();
    controller.selectedCategory.value = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Add Sub Category', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => AppCommonDropdown<String>(
                title: 'Category',
                hintText: 'Select Category',
                items: controller.categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: AppTextStyle.style_14_400()),
                      ),
                    )
                    .toList(),
                value: controller.selectedCategory.value,
                onChanged: (val) => controller.selectedCategory.value = val,
              ),
            ),
            SizedBox(height: 12.h),
            AppCommonTextField(
              controller: controller.subCategoryNameController,
              titleText: 'Sub Category',
              hintText: 'Enter sub category',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Submit',
            onPressed: () => controller.addSubCategory(),
            width: 90.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SupportSubCategoryController controller,
    SupportSubCategoryModel sub,
    int index,
  ) {
    controller.subCategoryNameController.text = sub.subCategory;
    controller.selectedCategory.value = sub.category;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Edit Sub Category', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => AppCommonDropdown<String>(
                title: 'Category',
                hintText: 'Select Category',
                items: controller.categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: AppTextStyle.style_14_400()),
                      ),
                    )
                    .toList(),
                value: controller.selectedCategory.value,
                onChanged: (val) => controller.selectedCategory.value = val,
              ),
            ),
            SizedBox(height: 12.h),
            AppCommonTextField(
              controller: controller.subCategoryNameController,
              titleText: 'Sub Category',
              hintText: 'Enter sub category',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Update',
            onPressed: () => controller.editSubCategory(
              index,
              controller.selectedCategory.value ?? '',
              controller.subCategoryNameController.text,
            ),
            width: 90.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    SupportSubCategoryController controller,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Delete Sub Category', style: AppTextStyle.style_18_700()),
        content: Text(
          'Are you sure you want to delete this sub-category?',
          style: AppTextStyle.style_14_400(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSubCategory(index);
            },
            child: Text(
              'Delete',
              style: AppTextStyle.style_14_600(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
