import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/support_template_controller.dart';

import 'package:mfresh_ops/routes/app_routes.dart';

class SupportTemplateScreen extends StatelessWidget {
  const SupportTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportTemplateController());

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
          'Support Templates',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CustomAppLoader())
            : _buildListScreen(context, controller),
      ),
    );
  }

  Widget _buildListScreen(
    BuildContext context,
    SupportTemplateController controller,
  ) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchTemplates(),
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
            // Add Template Button
            AppCommonButton(
              text: 'Add Template',
              onPressed: () {
                controller.openAddForm();
                Get.toNamed(AppRoutes.createTemplate);
              },
            ),
            SizedBox(height: 8.h),

            // Data Table
            Obx(() {
              final templates = controller.paginatedTemplates;

              final columns = [
                AppTableColumn<SupportTemplateModel>(
                  key: 'sl_no',
                  title: 'Sl No.',
                  width: 50.w,
                  sortable: false,
                  cellBuilder: (context, template, index, isExpanded) {
                    final actualIndex =
                        ((controller.currentPage.value - 1) *
                            controller.itemsPerPage.value) +
                        index;
                    return Text(
                      '${actualIndex + 1}',
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                    );
                  },
                ),
                AppTableColumn<SupportTemplateModel>(
                  key: 'template',
                  title: 'Templates',
                  width: 220.w,
                  cellBuilder: (context, template, index, isExpanded) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.templateName,
                            style: AppTextStyle.style_14_400(
                              color: AppColors.black,
                            ),
                            maxLines: isExpanded ? null : 1,
                            overflow: isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
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
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                AppTableColumn<SupportTemplateModel>(
                  key: 'action',
                  title: 'Action',
                  
                  sortable: false,
                  cellBuilder: (context, template, index, isExpanded) {
                    return _buildOutlinedIconButton(Icons.edit, () {
                      controller.openEditForm(template);
                      Get.toNamed(AppRoutes.createTemplate);
                    });
                  },
                ),
              ];

              return AppCommonTable<SupportTemplateModel>(
                items: templates,
                columns: columns,
                emptyText: 'No templates found',
              );
            }),

            SizedBox(height: 24.h),
            // Pagination
            Obx(() {
              final totalItems = controller.filteredTemplates.length;
              final startItem = totalItems == 0
                  ? 0
                  : ((controller.currentPage.value - 1) *
                            controller.itemsPerPage.value) +
                        1;
              final endItem = (startItem + controller.itemsPerPage.value - 1)
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


  void _showDescriptionDialog(
    BuildContext context,
    SupportTemplateModel template,
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
        title: Text(template.templateName, style: AppTextStyle.style_16_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 400),
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
                        style: AppTextStyle.style_14_400(
                          color: AppColors.black,
                        ),
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
            width: 85.w,
            height: 32.h,
          ),
        ],
      ),
    );
  }
}
