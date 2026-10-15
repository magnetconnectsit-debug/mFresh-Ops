import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/support_category_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

class SupportCategoryScreen extends StatelessWidget {
  const SupportCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportCategoryController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        topHeader: const CommonShortcutHeader(),
        showSearchBar: true,
        searchController: controller.searchController,
        title: Text(
          'Support Categories',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.fetchCategories(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    top: 8.h,
                    bottom: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Categories Button
                      AppCommonButton(
                        text: 'Add Categories',
                        onPressed: () => _showAddDialog(context, controller),
                      ),
                      SizedBox(height: 8.h),

                      // Data Table
                      Obx(() {
                        final categories = controller.paginatedCategories;

                        final columns = [
                          AppTableColumn<SupportCategoryModel>(
                            key: 'sl_no',
                            title: 'Sl No.',
                            width: 50.w,
                            sortable: false,
                            cellBuilder:
                                (context, category, index, isExpanded) {
                                  final actualIndex =
                                      ((controller.currentPage.value - 1) *
                                          controller.itemsPerPage.value) +
                                      index;
                                  return Text(
                                    '${actualIndex + 1}',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.black,
                                    ),
                                  );
                                },
                          ),
                          AppTableColumn<SupportCategoryModel>(
                            key: 'category',
                            title: 'Category',
                            width: 210.w,

                            cellBuilder:
                                (context, category, index, isExpanded) {
                                  return Text(
                                    category.categoryName,
                                    style: AppTextStyle.style_14_400(
                                      color: AppColors.black,
                                    ),
                                    maxLines: isExpanded ? null : 1,
                                    overflow: isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                  );
                                },
                          ),
                          AppTableColumn<SupportCategoryModel>(
                            key: 'action',
                            title: 'Action',
                            width: 90.w,
                            sortable: false,
                            cellBuilder:
                                (context, category, index, isExpanded) {
                                  return Row(
                                    children: [
                                      _buildOutlinedIconButton(
                                        Icons.edit,
                                        () => _showEditDialog(
                                          context,
                                          controller,
                                          category,
                                          index,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      _buildOutlinedIconButton(
                                        Icons.delete_outline,
                                        () => _showDeleteConfirmation(
                                          context,
                                          controller,
                                          index,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                          ),
                        ];

                        return AppCommonTable<SupportCategoryModel>(
                          items: categories,
                          columns: columns,
                          emptyText: 'No categories found',
                        );
                      }),

                      SizedBox(height: 24.h),
                      // Pagination
                      Obx(() {
                        final totalItems = controller.filteredCategories.length;
                        final startItem = totalItems == 0
                            ? 0
                            : ((controller.currentPage.value - 1) *
                                      controller.itemsPerPage.value) +
                                  1;
                        final endItem =
                            (startItem + controller.itemsPerPage.value - 1)
                                .clamp(0, totalItems);

                        return AppTablePagination(
                          startItem: startItem,
                          endItem: endItem,
                          totalItems: totalItems,
                          currentPage: controller.currentPage.value,
                          totalPages: controller.totalPages,
                          onPageChanged: (page) => controller.goToPage(page),
                          onPreviousPage: controller.previousPage,
                          onNextPage: controller.nextPage,
                        );
                      }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOutlinedIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey400),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 14.r, color: AppColors.grey600),
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
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Add Category', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller.categoryNameController,
                label: 'Category Name*',
                hint: 'Enter category name',
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppCommonButton(
                text: 'Cancel',
                variant: ButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
                width: 85.w,
                height: 32.h,
              ),
              SizedBox(width: 8.w),
              AppCommonButton(
                text: 'Submit',
                onPressed: () async {
                  final success = await controller.addCategory();
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                width: 85.w,
                height: 32.h,
              ),
            ],
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
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Edit Category', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller.categoryNameController,
                label: 'Category Name*',
                hint: 'Enter category name',
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppCommonButton(
                text: 'Cancel',
                variant: ButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
                width: 85.w,
                height: 32.h,
              ),
              SizedBox(width: 8.w),
              AppCommonButton(
                text: 'Update',
                onPressed: () async {
                  final success = await controller.editCategory(
                    index,
                    controller.categoryNameController.text,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                width: 85.w,
                height: 32.h,
              ),
            ],
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
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Delete Category', style: AppTextStyle.style_16_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Are you sure you want to delete this category?',
            style: AppTextStyle.style_14_400(color: AppColors.black),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppCommonButton(
                text: 'Cancel',
                variant: ButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
                width: 85.w,
                height: 32.h,
              ),
              SizedBox(width: 8.w),
              AppCommonButton(
                text: 'Delete',
                buttonColor: AppColors.red,
                onPressed: () async {
                  final success = await controller.deleteCategory(index);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                width: 85.w,
                height: 32.h,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    String? hint,
    int maxLines = 1,
    bool hasError = false,
  }) {
    return AppCommonTextField(
      controller: controller,
      labelText: label,
      hintText: hint ?? '',
      maxLines: maxLines,
    );
  }
}
