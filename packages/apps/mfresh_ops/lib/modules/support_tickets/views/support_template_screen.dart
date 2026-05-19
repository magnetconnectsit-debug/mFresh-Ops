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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box & Add Template Button Row
          Row(
            children: [
              AppCommonButton(
                text: "Add Template",
                onPressed: () {
                  controller.openAddForm();
                  controller.isFormScreenOpen.value = true;
                },
                width: 55.w,
                height: 35.h,
                buttonColor: AppColors.blue600,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: "Search Templates...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    isDense: true,
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
                      borderSide: const BorderSide(color: Color(0xFF009FDE)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Grid Table
          Obx(
            () => Table(
              border: TableBorder.all(color: Colors.grey.shade200, width: 1),
              columnWidths: {
                0: FixedColumnWidth(60.w),
                1: const FlexColumnWidth(),
                2: FixedColumnWidth(100.w),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade50),
                  children: [
                    _buildTableCell("SI No.", isHeader: true),
                    _buildTableCell("Templates", isHeader: true),
                    _buildTableCell("Action", isHeader: true),
                  ],
                ),
                // Data Rows
                ...controller.filteredTemplates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final template = entry.value;
                  return TableRow(
                    children: [
                      _buildTableCell((index + 1).toString()),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  template.templateName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (template.description.isNotEmpty) ...[
                                SizedBox(width: 4.w),
                                InkWell(
                                  onTap: () =>
                                      _showDescriptionDialog(context, template),
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
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  controller.openEditForm(template);
                                  controller.isFormScreenOpen.value = true;
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.blue,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 20.r,
                              ),
                              // SizedBox(width: 8.w),
                              // IconButton(
                              //   onPressed: () => _showDeleteConfirmation(context, controller, template.id),
                              //   icon: const Icon(Icons.delete, color: Colors.red),
                              //   padding: EdgeInsets.zero,
                              //   constraints: const BoxConstraints(),
                              //   iconSize: 20.r,
                              // ),
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
          SizedBox(height: 12.h),

          // Pagination Info Text
          Obx(
            () => Text(
              controller.filteredTemplates.isEmpty
                  ? "Showing 1 to 0 of 0"
                  : "Showing 1 to ${controller.filteredTemplates.length} of ${controller.filteredTemplates.length}",
              style: TextStyle(fontSize: 12.sp, color: AppColors.black87),
            ),
          ),
        ],
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
            maxLines: 12,
            isRequired: true,
          ),
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

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return TableCell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        alignment: isHeader ? Alignment.centerLeft : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
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
          width: 400.w,
          constraints: BoxConstraints(maxHeight: 300.h),
          child: SingleChildScrollView(
            child: Text(
              template.description,
              style: AppTextStyle.style_14_400(color: AppColors.black),
            ),
          ),
        ),
        actions: [
          AppCommonButton(
            text: 'Close',
            onPressed: () => Get.back(),
            width: 80.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }
}
