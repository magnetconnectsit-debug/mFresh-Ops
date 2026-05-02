import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/tasks/widgets/create_task_dialog.dart';
import 'package:mfresh_ops/data/models/models.dart';

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
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: Obx(() {
          final tasksList = controller.tasks;
          final bool isInitialLoading = controller.isLoading.value && tasksList.isEmpty;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              _buildFilterCard(controller),
              SizedBox(height: 12.h),
              _buildActionButtons(context, controller),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: isInitialLoading
                    ? _buildSkeletonTable()
                    : tasksList.isEmpty && !controller.isLoading.value
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50.h),
                              child: Text(
                                'No tasks found',
                                style: AppTextStyle.style_14_500(color: AppColors.grey300),
                              ),
                            ),
                          )
                        : AppCommonTable(
                            columns: const [
                              'Task ID',
                              'Project',
                              'Task',
                              'Created On',
                              'Created By',
                              'Task Type',
                              'Assignee',
                              'Started From',
                              'Completed By',
                              'Status',
                              'Approver Name',
                            ],
                            rows: [
                              ...tasksList.map((task) {
                                return [
                                  "${task.taskCode}_${task.taskInstanceId}",
                                  _sanitize(task.project ?? 'mFresh'),
                                  task.title,
                                  _formatDateTime(task.createdAt),
                                  _sanitize(task.createdByName ?? task.approverName ?? 'NA'),
                                  _sanitize(task.taskType.capitalizeFirst ?? 'NA'),
                                  _sanitize(task.assigneeName ?? ''),
                                  _formatDateTime(task.scheduleDateTime),
                                  _sanitize(task.completedByName ?? ''),
                                  _buildStatusBadge(task.status),
                                  _sanitize(task.approverName ?? ''),
                                ];
                              }),
                              if (controller.hasMore.value)
                                [
                                  '', '', '', '', '', '', '', '', '', '', 
                                  controller.isLoading.value 
                                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                                    : TextButton(
                                        onPressed: () => controller.fetchTasks(isLoadMore: true),
                                        child: Text('View More', style: AppTextStyle.style_10_700(color: AppColors.primary)),
                                      ),
                                ],
                            ],
                            columnWidths: {
                              0: 90.w,
                              1: 80.w,
                              2: 200.w,
                              3: 140.w,
                              4: 120.w,
                              5: 80.w,
                              6: 120.w,
                              7: 140.w,
                              8: 120.w,
                              9: 90.w,
                              10: 120.w,
                            },
                          ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _sanitize(String text) {
    return text.replaceAll('_', ' ');
  }

  Widget _buildSkeletonTable() {
    return Column(
      children: List.generate(10, (index) => _buildSkeletonRow()),
    );
  }

  Widget _buildSkeletonRow() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          _skeletonBox(40.w, 12.h),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(double.infinity, 10.h),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _skeletonBox(60.w, 8.h),
                    SizedBox(width: 12.w),
                    _skeletonBox(60.w, 8.h),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _skeletonBox(50.w, 20.h, borderRadius: 4.r),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1500.ms,
          color: AppColors.grey50,
        );
  }

  Widget _skeletonBox(double width, double height, {double borderRadius = 2.0}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'NA') return 'NA';
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      String day = dt.day.toString().padLeft(2, '0');
      String month = months[dt.month - 1];
      String year = dt.year.toString();
      
      int hour = dt.hour;
      String ampm = 'AM';
      if (hour >= 12) {
        ampm = 'PM';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;
      
      String minute = dt.minute.toString().padLeft(2, '0');
      return "$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $ampm";
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildActionButtons(BuildContext context, TasksController controller) {
    return Row(
      children: [
        _buildMainActionButton(
          'Create Task',
          AppColors.info,
          () => Get.dialog(const CreateTaskDialog()),
        ),
        SizedBox(width: 10.w),
        _buildMainActionButton(
          'Export',
          AppColors.success,
          () => _showExportOptions(context, controller),
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context, TasksController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Export Tasks',
              style: AppTextStyle.style_16_700(color: AppColors.black),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.table_view_rounded, color: AppColors.success),
              title: Text('Export to Excel', style: AppTextStyle.style_14_500(color: AppColors.black)),
              onTap: () {
                Get.back();
                controller.exportTasks(isPdf: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.red),
              title: Text('Export to PDF', style: AppTextStyle.style_14_500(color: AppColors.black)),
              onTap: () {
                Get.back();
                controller.exportTasks(isPdf: true);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: AppTextStyle.style_12_600(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        _sanitize(status.toUpperCase()),
        style: AppTextStyle.style_10_700(color: color),
      ),
    );
  }

  Widget _buildFilterCard(TasksController controller) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() => AppCommonDropdown<TaskProject>(
                  hintText: 'Project',
                  options: controller.projects.map((e) => DropdownOption(value: e, label: e.projectName)).toList(),
                  selectedValues: controller.selectedProjects,
                  onMultiSelectChanged: (val) => controller.selectedProjects.assignAll(val),
                  isMultiSelect: true,
                  style: AppTextStyle.style_10_600(color: AppColors.black),
                  hintStyle: AppTextStyle.style_10_600(color: AppColors.black),
                )),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(() => AppCommonDropdown<SupportUnit>(
                  hintText: 'Unit',
                  options: controller.units.map((e) => DropdownOption(value: e, label: e.unitName)).toList(),
                  selectedValues: controller.selectedUnits,
                  onMultiSelectChanged: (val) => controller.selectedUnits.assignAll(val),
                  isMultiSelect: true,
                  style: AppTextStyle.style_10_600(color: AppColors.black),
                  hintStyle: AppTextStyle.style_10_600(color: AppColors.black),
                )),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => AppCommonDropdown<TaskGroup>(
                  hintText: 'Group',
                  options: controller.groups.map((e) => DropdownOption(value: e, label: e.roleName)).toList(),
                  selectedValues: controller.selectedGroups,
                  onMultiSelectChanged: (val) => controller.selectedGroups.assignAll(val),
                  isMultiSelect: true,
                  style: AppTextStyle.style_10_600(color: AppColors.black),
                  hintStyle: AppTextStyle.style_10_600(color: AppColors.black),
                )),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(() => AppCommonDropdown<AssigneeModel>(
                  hintText: 'Assignee',
                  options: controller.assignees.map((e) => DropdownOption(value: e, label: e.name)).toList(),
                  selectedValues: controller.selectedAssignees,
                  onMultiSelectChanged: (val) => controller.selectedAssignees.assignAll(val),
                  isMultiSelect: true,
                  style: AppTextStyle.style_10_600(color: AppColors.black),
                  hintStyle: AppTextStyle.style_10_600(color: AppColors.black),
                )),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFilterButton('Reset', AppColors.white, AppColors.black, onTap: () {
                controller.selectedProjects.clear();
                controller.selectedGroups.clear();
                controller.selectedUnits.clear();
                controller.selectedAssignees.clear();
                controller.refreshData();
              }, borderColor: AppColors.borderColor),
              SizedBox(width: 8.w),
              _buildFilterButton('Apply', AppColors.info, AppColors.white, onTap: () {
                controller.refreshData();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, Color bgColor, Color textColor, {required VoidCallback onTap, Color? borderColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.r),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(
          label,
          style: AppTextStyle.style_10_600(color: textColor),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.red;
      case 'review':
      case 'under_review':
        return Colors.purple;
      default:
        return AppColors.grey300;
    }
  }
}
