import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/data/models/models.dart';
import '../controllers/support_subcategory_controller.dart';

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
        topHeader: const CommonShortcutHeader(),
        showSearchBar: true,
        searchController: controller.searchController,
        title: Text(
          'Sub Categories',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.fetchAllData(),
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
                      // Add Sub Categories Button
                      AppCommonButton(
                        text: 'Add Sub Categories',
                        onPressed: () => _showAddDialog(context, controller),
                      ),
                      SizedBox(height: 8.h),

                      // Data Table
                      Obx(() {
                        final subCategories = controller.paginatedSubCategories;

                        final columns = [
                          AppTableColumn<SupportSubCategoryModel>(
                            key: 'sl_no',
                            title: 'Sl No.',
                            width: 50.w,
                            sortable: false,
                            cellBuilder: (context, sub, index, isExpanded) {
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
                          AppTableColumn<SupportSubCategoryModel>(
                            key: 'category',
                            title: 'Category',
                            width: 85.w,
                            cellBuilder: (context, sub, index, isExpanded) {
                              final category = controller.categories
                                  .firstWhereOrNull((c) => c.id == sub.catId);
                              return Text(
                                category?.categoryName ?? 'Unknown',
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
                          AppTableColumn<SupportSubCategoryModel>(
                            key: 'sub_category',
                            title: 'Sub Category',
                            width: 125.w,

                            cellBuilder: (context, sub, index, isExpanded) {
                              return Text(
                                sub.subCategory,
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
                          AppTableColumn<SupportSubCategoryModel>(
                            key: 'action',
                            title: 'Action',
                            width: 90.w,
                            sortable: false,
                            cellBuilder: (context, sub, index, isExpanded) {
                              return Row(
                                children: [
                                  _buildOutlinedIconButton(
                                    Icons.edit,
                                    () => _showEditDialog(
                                      context,
                                      controller,
                                      sub,
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

                        return AppCommonTable<SupportSubCategoryModel>(
                          items: subCategories,
                          columns: columns,
                          emptyText: 'No sub categories found',
                        );
                      }),

                      SizedBox(height: 24.h),
                      // Pagination
                      Obx(() {
                        final totalItems =
                            controller.filteredSubCategories.length;
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
    SupportSubCategoryController controller,
  ) {
    controller.subCategoryNameController.clear();
    controller.selectedCategory.value = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Add Sub Category', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => MultiSelectDropdownWidget<SupportCategoryModel>(
                  label: 'Category*',
                  hint: 'Select Category',
                  isSingleSelect: true,
                  showSearch: true,
                  selectedValues: controller.selectedCategory.value != null
                      ? {controller.selectedCategory.value!}
                      : {},
                  items: controller.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.categoryName),
                        ),
                      )
                      .toList(),
                  onChanged: (values) {
                    controller.selectedCategory.value = values.isNotEmpty
                        ? values.first
                        : null;
                  },
                ),
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller.subCategoryNameController,
                label: 'Sub Category*',
                hint: 'Enter sub category',
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
                  final success = await controller.addSubCategory();
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
    SupportSubCategoryController controller,
    SupportSubCategoryModel sub,
    int index,
  ) {
    controller.subCategoryNameController.text = sub.subCategory;
    controller.selectedCategory.value = controller.categories.firstWhereOrNull(
      (c) => c.id == sub.catId,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Edit Sub Category', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => MultiSelectDropdownWidget<SupportCategoryModel>(
                  label: 'Category*',
                  hint: 'Select Category',
                  isSingleSelect: true,
                  showSearch: true,
                  selectedValues: controller.selectedCategory.value != null
                      ? {controller.selectedCategory.value!}
                      : {},
                  items: controller.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.categoryName),
                        ),
                      )
                      .toList(),
                  onChanged: (values) {
                    controller.selectedCategory.value = values.isNotEmpty
                        ? values.first
                        : null;
                  },
                ),
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller.subCategoryNameController,
                label: 'Sub Category*',
                hint: 'Enter sub category',
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
                  final success = await controller.editSubCategory(
                    index,
                    controller.selectedCategory.value?.id ?? 0,
                    controller.subCategoryNameController.text,
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
    SupportSubCategoryController controller,
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
        title: Text('Delete Sub Category', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Are you sure you want to delete this sub-category?',
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
                  final success = await controller.deleteSubCategory(index);
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
