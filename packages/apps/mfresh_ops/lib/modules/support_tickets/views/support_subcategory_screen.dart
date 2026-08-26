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
        title: Text(
          'Support\nSub Categories',
          style: AppTextStyle.style_14_700(color: AppColors.black),
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
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Sub Categories Button
                      InkWell(
                        onTap: () => _showAddDialog(context, controller),
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A3B8), // Web mockup cyan
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Add Sub Categories',
                            style: AppTextStyle.style_14_500(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // Search Box
                      TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search sub categories...',
                          hintStyle: AppTextStyle.style_14_400(color: AppColors.grey300),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.r),
                            borderSide: const BorderSide(color: Color(0xFF16A3B8)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // Data Table
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: Table(
                            border: TableBorder.symmetric(
                              inside: BorderSide(color: Colors.grey.shade300),
                            ),
                            columnWidths: {
                              0: FixedColumnWidth(60.w),
                              1: const FlexColumnWidth(),
                              2: const FlexColumnWidth(),
                              3: FixedColumnWidth(90.w),
                            },
                            children: [
                              // Header
                              TableRow(
                                children: [
                                  _buildHeaderCell('Sl No.'),
                                  _buildHeaderCell('Category'),
                                  _buildHeaderCell('Sub Category'),
                                  _buildHeaderCell('Action'),
                                ],
                              ),
                              // Data Rows
                              ...controller.paginatedSubCategories.asMap().entries.map((entry) {
                                final index = entry.key;
                                final sub = entry.value;
                                final actualIndex = ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + index;
                                final category = controller.categories.firstWhereOrNull((c) => c.id == sub.catId);
                                return TableRow(
                                  children: [
                                    _buildDataCell('${actualIndex + 1}'),
                                    _buildDataCell(category?.categoryName ?? 'Unknown'),
                                    _buildDataCell(sub.subCategory),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                      child: Row(
                                        children: [
                                          _buildOutlinedIconButton(
                                            Icons.edit,
                                            () => _showEditDialog(context, controller, sub, actualIndex),
                                          ),
                                          SizedBox(width: 6.w),
                                          _buildOutlinedIconButton(
                                            Icons.delete_outline,
                                            () => _showDeleteConfirmation(context, controller, actualIndex),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      // Pagination
                      Obx(() {
                        final totalItems = controller.filteredSubCategories.length;
                        final startItem = totalItems == 0 ? 0 : ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + 1;
                        final endItem = (startItem + controller.itemsPerPage.value - 1).clamp(0, totalItems);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Showing $startItem to $endItem of $totalItems entries',
                                style: AppTextStyle.style_12_400(color: AppColors.black),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              flex: 2,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPaginationButton('←', false, controller.previousPage),
                                    // Generate page buttons
                                    ...List.generate(controller.totalPages, (index) {
                                      final pageNumber = index + 1;
                                      return _buildPaginationButton(
                                        pageNumber.toString(),
                                        controller.currentPage.value == pageNumber,
                                        () => controller.goToPage(pageNumber),
                                      );
                                    }),
                                    _buildPaginationButton('→', false, controller.nextPage),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
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
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 14.r, color: const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(
            color: isActive ? Colors.white : Colors.blue.shade600,
          ),
        ),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Text('Add Sub Category', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => AppCommonDropdown<SupportCategoryModel>(
                title: 'Category',
                hintText: 'Select Category',
                height: 48.h,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                items: controller.categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat.categoryName,
                          style: AppTextStyle.style_14_400(),
                        ),
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Submit',
            onPressed: () async {
              final success = await controller.addSubCategory();
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
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
    controller.selectedCategory.value = controller.categories.firstWhereOrNull(
      (c) => c.id == sub.catId,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Text('Edit Sub Category', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => AppCommonDropdown<SupportCategoryModel>(
                title: 'Category',
                hintText: 'Select Category',
                height: 48.h,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                items: controller.categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat.categoryName,
                          style: AppTextStyle.style_14_400(),
                        ),
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Text('Delete Sub Category', style: AppTextStyle.style_18_700()),
        content: Text(
          'Are you sure you want to delete this sub-category?',
          style: AppTextStyle.style_14_400(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          TextButton(
            onPressed: () async {
              final success = await controller.deleteSubCategory(index);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
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
