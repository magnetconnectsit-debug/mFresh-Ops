import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
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
        topHeader: const CommonShortcutHeader(),
        showSearchBar: true,
        searchController: controller.searchController,
        title: Text(
          'Support Projects',
          style: AppTextStyle.style_18_700(color: AppColors.black),
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
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    top: 8.h,
                    bottom: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Projects Button
                      AppCommonButton(
                        text: 'Add Project',
                        onPressed: () => _showAddDialog(context, controller),
                      ),
                      SizedBox(height: 8.h),

                      // Data Table
                      Obx(() {
                        final projects = controller.paginatedProjects;

                        final columns = [
                          AppTableColumn<SupportProjectModel>(
                            key: 'sl_no',
                            title: 'Sl No.',
                            width: 50.w,
                            sortable: false,
                            cellBuilder: (context, project, index, isExpanded) {
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
                          AppTableColumn<SupportProjectModel>(
                            key: 'project',
                            title: 'Project',
                            width: 210.w,
                            cellBuilder: (context, project, index, isExpanded) {
                              return Text(
                                project.project,
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
                          AppTableColumn<SupportProjectModel>(
                            key: 'action',
                            title: 'Action',
                            width: 70.w,
                            sortable: false,
                            cellBuilder: (context, project, index, isExpanded) {
                              return Row(
                                children: [
                                  _buildOutlinedIconButton(
                                    Icons.edit,
                                    () => _showEditDialog(
                                      context,
                                      controller,
                                      project,
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

                        return AppCommonTable<SupportProjectModel>(
                          items: projects,
                          columns: columns,
                          emptyText: 'No projects found',
                        );
                      }),

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
    SupportProjectsController controller,
  ) {
    controller.projectNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Add Project', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller.projectNameController,
                label: 'Project Name*',
                hint: 'Enter project name',
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
                  final success = await controller.addProject();
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
    SupportProjectsController controller,
    SupportProjectModel project,
    int index,
  ) {
    controller.projectNameController.text = project.project;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        title: Text('Edit Project', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller.projectNameController,
                label: 'Project Name*',
                hint: 'Enter project name',
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
                  final success = await controller.editProject(
                    index,
                    controller.projectNameController.text,
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
    SupportProjectsController controller,
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
        title: Text('Delete Project', style: AppTextStyle.style_18_700()),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Are you sure you want to delete this project?',
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
                  final success = await controller.deleteProject(index);
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
