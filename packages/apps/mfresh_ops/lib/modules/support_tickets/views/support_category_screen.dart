import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import '../controllers/support_category_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

class SupportCategoryScreen extends StatelessWidget {
  const SupportCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportCategoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Text(
          'Support Categories',
          style: AppTextStyle.style_14_600(color: AppColors.black),
        ),
        actions: [
          AppCommonButton(
            text: 'Add Category',
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
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.filteredCategories[index];
                  return _buildCategoryCard(context, controller, category, index);
                },
              ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    SupportCategoryController controller,
    SupportCategoryModel category,
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
              category.id.toString(),
              style: AppTextStyle.style_12_700(color: AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category.categoryName,
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
          ),
          IconButton(
            onPressed: () =>
                _showEditDialog(context, controller, category, index),
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
    SupportCategoryController controller,
  ) {
    controller.categoryNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Add Category', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCommonTextField(
              controller: controller.categoryNameController,
              titleText: 'Category Name',
              hintText: 'Enter category name',
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
            onPressed: () => controller.addCategory(),
            width: 90.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SupportCategoryController controller,
    SupportCategoryModel category,
    int index,
  ) {
    controller.categoryNameController.text = category.categoryName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Edit Category', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCommonTextField(
              controller: controller.categoryNameController,
              titleText: 'Category Name',
              hintText: 'Enter category name',
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
            onPressed: () => controller.editCategory(
              index,
              controller.categoryNameController.text,
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
    SupportCategoryController controller,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Delete Category', style: AppTextStyle.style_16_700()),
        content: Text(
          'Are you sure you want to delete this category?',
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
              controller.deleteCategory(index);
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
