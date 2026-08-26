import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import '../controllers/support_projects_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

class SupportProjectsScreen extends StatelessWidget {
  const SupportProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportProjectsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Text(
          'Support Projects',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.fetchProjects(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Projects Button
                      InkWell(
                        onTap: () => _showAddDialog(context, controller),
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 6.h,
                          ),
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
                            'Add Project',
                            style: AppTextStyle.style_14_500(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Search Box
                      TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search projects...',
                          hintStyle: AppTextStyle.style_14_400(
                            color: AppColors.grey300,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
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
                            borderSide: const BorderSide(
                              color: Color(0xFF16A3B8),
                            ),
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
                                  _buildHeaderCell('Project'),
                                  _buildHeaderCell('Action'),
                                ],
                              ),
                              // Data Rows
                              ...controller.paginatedProjects
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final project = entry.value;
                                    final actualIndex =
                                        ((controller.currentPage.value - 1) *
                                            controller.itemsPerPage.value) +
                                        index;
                                    return TableRow(
                                      children: [
                                        _buildDataCell('${actualIndex + 1}'),
                                        _buildDataCell(project.project),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 4.h,
                                          ),
                                          child: Row(
                                            children: [
                                              _buildOutlinedIconButton(
                                                Icons.edit,
                                                () => _showEditDialog(
                                                  context,
                                                  controller,
                                                  project,
                                                  actualIndex,
                                                ),
                                              ),
                                              SizedBox(width: 6.w),
                                              _buildOutlinedIconButton(
                                                Icons.delete_outline,
                                                () => _showDeleteConfirmation(
                                                  context,
                                                  controller,
                                                  actualIndex,
                                                ),
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
                        final totalItems = controller.filteredProjects.length;
                        final startItem = totalItems == 0
                            ? 0
                            : ((controller.currentPage.value - 1) *
                                      controller.itemsPerPage.value) +
                                  1;
                        final endItem =
                            (startItem + controller.itemsPerPage.value - 1)
                                .clamp(0, totalItems);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Showing $startItem to $endItem of $totalItems entries',
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.black,
                                ),
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
                                    _buildPaginationButton(
                                      '←',
                                      false,
                                      controller.previousPage,
                                    ),
                                    // Generate page buttons
                                    ...List.generate(controller.totalPages, (
                                      index,
                                    ) {
                                      final pageNumber = index + 1;
                                      return _buildPaginationButton(
                                        pageNumber.toString(),
                                        controller.currentPage.value ==
                                            pageNumber,
                                        () => controller.goToPage(pageNumber),
                                      );
                                    }),
                                    _buildPaginationButton(
                                      '→',
                                      false,
                                      controller.nextPage,
                                    ),
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

  Widget _buildPaginationButton(
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
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
    SupportProjectsController controller,
  ) {
    controller.projectNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Text('Add Project', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCommonTextField(
              controller: controller.projectNameController,
              titleText: 'Project Name',
              hintText: 'Enter project name',
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
              final success = await controller.addProject();
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
    SupportProjectsController controller,
    SupportProjectModel project,
    int index,
  ) {
    controller.projectNameController.text = project.project;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Text('Edit Project', style: AppTextStyle.style_18_700()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCommonTextField(
              controller: controller.projectNameController,
              titleText: 'Project Name',
              hintText: 'Enter project name',
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
              final success = await controller.editProject(
                index,
                controller.projectNameController.text,
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
    SupportProjectsController controller,
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
        title: Text('Delete Project', style: AppTextStyle.style_18_700()),
        content: Text(
          'Are you sure you want to delete this project?',
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
              final success = await controller.deleteProject(index);
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
