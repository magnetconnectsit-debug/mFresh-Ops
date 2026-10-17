import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_filter_card.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/all_tasks_action_buttons.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/all_tasks_table.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  late final TasksController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TasksController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearFilters();
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(
          'All Task',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        iconColor: AppColors.black,
        topHeader: const CommonShortcutHeader(),
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.selectedProjects.clear();
          controller.selectedGroups.clear();
          controller.selectedUnits.clear();
          controller.selectedAssignees.clear();
          await controller.refreshData();
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TaskFilterCard(controller: controller),
            SizedBox(height: 4.h),
            AllTasksActionButtons(controller: controller),
            SizedBox(height: 4.h),
            AllTasksTableWidget(controller: controller),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
          ],
        ),
      ),
    );
  }
}
