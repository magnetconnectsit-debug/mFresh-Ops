import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import '../controllers/support_template_controller.dart';

class SupportTemplateScreen extends StatelessWidget {
  const SupportTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportTemplateController());

    return Obx(() {
      if (controller.isFormScreenOpen.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            hasBackButton: true,
            onBackButtonPressed: () {
              controller.isFormScreenOpen.value = false;
              controller.clearControllers();
            },
            title: Text(
              controller.isEditing.value ? 'Edit Template' : 'Add Template',
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
          ),
          body: _buildFormScreen(context, controller),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppCommonAppBar(
          backgroundColor: AppColors.white,
          hasBackButton: false,
          showAppDrawer: true,
          title: Text(
            'Support Templates',
            style: AppTextStyle.style_14_600(color: AppColors.black),
          ),
        ),
        drawer: const CommonSidebar(),
        body: controller.isLoading.value
            ? const Center(child: CustomAppLoader())
            : _buildListScreen(context, controller),
      );
    });
  }

  Widget _buildListScreen(
    BuildContext context,
    SupportTemplateController controller,
  ) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchTemplates(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Template Button
            InkWell(
              onTap: () {
                controller.openAddForm();
                controller.isFormScreenOpen.value = true;
              },
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
                  'Add Template',
                  style: AppTextStyle.style_14_500(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Search Box
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search Templates...',
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
                    2: FixedColumnWidth(90.w),
                  },
                  children: [
                    // Header
                    TableRow(
                      children: [
                        _buildHeaderCell('Sl No.'),
                        _buildHeaderCell('Templates'),
                        _buildHeaderCell('Action'),
                      ],
                    ),
                    // Data Rows
                    ...controller.paginatedTemplates.asMap().entries.map((entry) {
                      final index = entry.key;
                      final template = entry.value;
                      final actualIndex = ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + index;
                      return TableRow(
                        children: [
                          _buildDataCell('${actualIndex + 1}'),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    template.templateName,
                                    style: AppTextStyle.style_14_400(color: AppColors.black),
                                  ),
                                ),
                                if (template.description.isNotEmpty) ...[
                                  SizedBox(width: 4.w),
                                  InkWell(
                                    onTap: () => _showDescriptionDialog(context, template),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.r),
                                      child: Icon(
                                        Icons.zoom_out_map,
                                        size: 16.r,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            child: Row(
                              children: [
                                _buildOutlinedIconButton(
                                  Icons.edit,
                                  () {
                                    controller.openEditForm(template);
                                    controller.isFormScreenOpen.value = true;
                                  },
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
              final totalItems = controller.filteredTemplates.length;
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
    );
  }

  Widget _buildFormScreen(
    BuildContext context,
    SupportTemplateController controller,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCommonTextField(
            controller: controller.templateNameController,
            titleText: 'Template Name',
            hintText: 'Enter Template Name',
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          AppCommonTextField(
            controller: controller.descriptionController,
            titleText: 'Description',
            hintText: 'Enter Description',
            maxLines: 4,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtasks',
                style: AppTextStyle.style_14_600(color: AppColors.black),
              ),
              TextButton.icon(
                onPressed: () => controller.addSubtaskField(),
                icon: Icon(Icons.add, size: 16.r),
                label: const Text('Add Subtask'),
              ),
            ],
          ),
          Obx(() => Column(
            children: controller.subtaskControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final subController = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: AppCommonTextField(
                        controller: subController,
                        hintText: 'Enter subtask',
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => controller.removeSubtaskField(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  controller.isFormScreenOpen.value = false;
                  controller.clearControllers();
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyle.style_14_500(color: AppColors.grey300),
                ),
              ),
              SizedBox(width: 8.w),
              AppCommonButton(
                text: 'Submit',
                onPressed: () => controller.submitForm(),
                width: 90.w,
                height: 36.h,
              ),
            ],
          ),
        ],
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

  void _showDescriptionDialog(
    BuildContext context,
    SupportTemplateModel template,
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
        title: Text(template.templateName, style: AppTextStyle.style_16_700()),
        content: Container(
          width: 250.w,
          constraints: BoxConstraints(maxHeight: 250.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (template.description.isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: AppTextStyle.style_14_600(color: AppColors.black),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    template.description,
                    style: AppTextStyle.style_14_400(color: AppColors.black),
                  ),
                  if (template.subtasks.isNotEmpty) SizedBox(height: 12.h),
                ],
                if (template.subtasks.isNotEmpty) ...[
                  Text(
                    'Subtasks:',
                    style: AppTextStyle.style_14_600(color: AppColors.black),
                  ),
                  SizedBox(height: 8.h),
                  ...template.subtasks.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: AppTextStyle.style_14_400(color: AppColors.black),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          AppCommonButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
            width: 80.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }
}
