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
          'Support\nProjects',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        actions: [
          AppCommonButton(
            text: 'Add Project',
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
                itemCount: controller.filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = controller.filteredProjects[index];
                  return _buildProjectCard(context, controller, project, index);
                },
              ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    SupportProjectsController controller,
    SupportProjectModel project,
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
              project.id.toString(),
              style: AppTextStyle.style_12_700(color: AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              project.project,
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
          ),
          IconButton(
            onPressed: () => _showEditDialog(context, controller, project, index),
            icon: Icon(Icons.edit_outlined, color: AppColors.info, size: 20.r),
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, controller, index),
            icon: Icon(Icons.delete_outline, color: AppColors.red, size: 20.r),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, SupportProjectsController controller) {
    controller.projectNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyle.style_14_500(color: AppColors.grey300)),
          ),
          AppCommonButton(
            text: 'Submit',
            onPressed: () => controller.addProject(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyle.style_14_500(color: AppColors.grey300)),
          ),
          AppCommonButton(
            text: 'Update',
            onPressed: () => controller.editProject(index, controller.projectNameController.text),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Project', style: AppTextStyle.style_18_700()),
        content: Text(
          'Are you sure you want to delete this project?',
          style: AppTextStyle.style_14_400(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyle.style_14_500(color: AppColors.grey300)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProject(index);
            },
            child: Text('Delete', style: AppTextStyle.style_14_600(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
