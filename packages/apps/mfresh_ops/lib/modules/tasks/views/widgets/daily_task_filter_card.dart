import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/services.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/tasks/controllers/daily_task_filter_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/delete_task_dialog.dart';

// region DailyTaskFilterCard Widget
class DailyTaskFilterCard extends StatelessWidget {
  // region Properties & Constructor
  final TaskItem task;

  const DailyTaskFilterCard({
    super.key,
    required this.task,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final statusLower = task.status.toLowerCase().trim();
    final dayStatusLower = task.taskDayStatus?.toLowerCase().trim() ?? '';

    final isCompletedOrApproved =
        statusLower == 'completed' || statusLower == 'approved';
    final isReviewOrUnderReview =
        statusLower == 'review' || statusLower == 'under_review';
    final isRejected = statusLower == 'rejected';

    bool isUpcoming = false;
    bool isOverdue = false;
    bool isActive = false;

    Color statusBg = AppColors.black2;
    Color statusTextColor = AppColors.white;
    String statusText = '';

    String formatStatus(String str) {
      if (str.isEmpty) return '';
      return str
          .replaceAll('_', ' ')
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' ')
          .trim();
    }

    // Use task_status from server as authoritative display text
    final hasServerTaskStatus =
        task.taskStatus != null && task.taskStatus!.isNotEmpty;

    if (hasServerTaskStatus) {
      statusText = task.taskStatus!;
    } else if (task.status.isNotEmpty) {
      statusText = formatStatus(task.status);
    } else {
      statusText = 'Active';
    }

    final lowerText = statusText.toLowerCase();

    if (lowerText.contains('cancel') || statusLower == 'cancel_review') {
      statusBg = const Color(0xFFFFA000);
      statusTextColor = AppColors.white;
    } else if (lowerText == 'cancelled' ||
        statusLower == 'cancelled' ||
        isRejected) {
      statusBg = const Color(0xFF8B0000);
      statusTextColor = AppColors.white;
    } else if (lowerText.contains('review') ||
        isReviewOrUnderReview ||
        dayStatusLower == 'review') {
      statusBg = AppColors.orange900;
      statusTextColor = AppColors.white;
    } else if (lowerText == 'completed' ||
        lowerText == 'approved' ||
        isCompletedOrApproved) {
      statusBg = AppColors.green;
      statusTextColor = AppColors.white;
    } else if (lowerText == 'overdue' ||
        statusLower == 'overdue' ||
        dayStatusLower == 'overdue') {
      isOverdue = true;
      statusBg = const Color(0xFFE25C5C);
      statusTextColor = AppColors.white;
    } else if (lowerText == 'upcoming' ||
        statusLower == 'upcoming' ||
        dayStatusLower == 'upcoming') {
      isUpcoming = true;
      statusBg = const Color(0xFFFFB822);
      statusTextColor = const Color(0xFF212529);
    } else if (!hasServerTaskStatus &&
        (statusLower == 'pending' || statusLower == 'due')) {
      final scheduleDateTime = _parseDateTime(task.scheduleDateTime);
      final isUpcomingTime = scheduleDateTime != null &&
          DateTime.now().isBefore(scheduleDateTime);
      final endDt = _parseEndDateTime(task);
      final isOverdueTime = (endDt != null && DateTime.now().isAfter(endDt)) ||
          (scheduleDateTime != null &&
              DateTime.now().isAfter(scheduleDateTime));
      if (isUpcomingTime) {
        isUpcoming = true;
        statusBg = const Color(0xFFFFB822);
        statusTextColor = const Color(0xFF212529);
        statusText = 'Upcoming';
      } else if (isOverdueTime) {
        isOverdue = true;
        statusBg = const Color(0xFFE25C5C);
        statusTextColor = AppColors.white;
        statusText = 'Overdue';
      } else {
        statusBg = AppColors.red;
        statusTextColor = AppColors.white;
        statusText = 'Due';
      }
    } else if (lowerText == 'active' ||
        statusLower == 'active' ||
        dayStatusLower == 'active') {
      isActive = true;
      statusBg = const Color(0xFF28A745);
      statusTextColor = AppColors.white;
    } else {
      statusBg = const Color(0xFFFFA000);
      statusTextColor = AppColors.white;
    }

    if (task.badgeText != null && task.badgeText!.isNotEmpty) {
      statusText = task.badgeText!;
    }

    statusText = statusText
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');

    if (statusText.toLowerCase() == 'cancel review') {
      statusText = 'Cancel\nReview';
    }

    final isRecurring =
        task.frequency.toLowerCase() != 'none' && task.frequency.isNotEmpty;

    String formatTimeAmPm(String timeStr) {
      if (timeStr.isEmpty) return timeStr;
      final tod = _parseTimeOfDay(timeStr);
      if (tod == null) return timeStr;
      final hour12 = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
      final minuteStr = tod.minute.toString().padLeft(2, '0');
      final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour12:$minuteStr $period';
    }

    String? timeRangeText;
    final startTimeStr = (task.instStartTime != null && task.instStartTime!.isNotEmpty)
        ? task.instStartTime!
        : task.startTime;
    final endTimeStr = (task.instEndTime != null && task.instEndTime!.isNotEmpty)
        ? task.instEndTime!
        : task.endTime;

    if (startTimeStr.isNotEmpty && endTimeStr.isNotEmpty) {
      timeRangeText = '${formatTimeAmPm(startTimeStr)} - ${formatTimeAmPm(endTimeStr)}';
    } else if (startTimeStr.isNotEmpty) {
      timeRangeText = formatTimeAmPm(startTimeStr);
    }

    final assigneeOrGroupText = ((task.assigneeName != null && task.assigneeName!.isNotEmpty)
            ? task.assigneeName!
            : (task.groupNames != null && task.groupNames!.isNotEmpty)
                ? task.groupNames!
                : 'Unassigned')
        .replaceAll('_', ' ');

    final projectName = (task.project != null && task.project!.isNotEmpty)
        ? task.project!
        : '';

    final filterController = Get.isRegistered<DailyTaskFilterController>()
        ? Get.find<DailyTaskFilterController>()
        : null;

    final taskKey =
        '${task.id}_${task.taskInstanceId}_${task.scheduleDateTime}';

    return Obx(() {
      final isCompactList = filterController?.isListView.value ?? false;
      final isExpandedInListView =
          filterController?.expandedTaskId.value == taskKey;

      if (isCompactList && !isExpandedInListView) {
        return GestureDetector(
          onTap: () => filterController?.toggleExpandedTask(taskKey),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE5E5E5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isRecurring ? Icons.sync : Icons.person,
                  size: 16.r,
                  color: isRecurring
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF212529),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.style_13_600(color: AppColors.black),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildStatusAction(
                  task: task,
                  statusBg: statusBg,
                  statusTextColor: statusTextColor,
                  statusText: statusText,
                  statusLower: statusLower,
                  dayStatusLower: dayStatusLower,
                  isReviewOrUnderReview: isReviewOrUnderReview,
                  isRejected: isRejected,
                  isOverdue: isOverdue,
                  isUpcoming: isUpcoming,
                  isActive: isActive,
                  showTimer: false,
                ),
              ],
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: isCompactList
            ? () => filterController?.toggleExpandedTask(taskKey)
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE5E5E5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  isRecurring ? Icons.sync : Icons.person,
                  size: 16.r,
                  color: isRecurring
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF212529),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyle.style_12_700(color: AppColors.black),
                    ),
                    SizedBox(height: 4.h),
                    // Row 1: Time & Date strictly together
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (timeRangeText != null) ...[
                            Icon(
                              Icons.access_time_outlined,
                              size: 11.r,
                              color: const Color(0xFF6C757D),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              timeRangeText,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF495057),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11.r,
                            color: const Color(0xFF6C757D),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            _formatCardDate(task.scheduleDateTime),
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF495057),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Row 2: Assignee, Project & Action Icons (closer together)
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (task.assigneeName != null &&
                                        task.assigneeName!.isNotEmpty)
                                    ? Icons.person_outline
                                    : Icons.people_outline,
                                size: 11.r,
                                color: const Color(0xFF6C757D),
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Text(
                                  assigneeOrGroupText,
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF495057),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (projectName.isNotEmpty) ...[
                                Text(
                                  ' • ',
                                  style: AppTextStyle.style_10_400(
                                    color: AppColors.grey600,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    projectName,
                                    style: AppTextStyle.style_10_500(
                                      color: const Color(0xFF6C757D),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        if (Get.find<AuthRepository>().rxUserPermissions
                            .contains('Task_Edit')) ...[
                          GestureDetector(
                            onTap: () {
                              Get.find<TasksController>().editTaskDetails(
                                task,
                              );
                            },
                            child: Icon(
                              Icons.edit_note,
                              size: 14.r,
                              color: const Color(0xFF0D6EFD),
                            ),
                          ),
                          SizedBox(width: 6.w),
                        ],
                        if (Get.find<AuthRepository>().rxUserPermissions
                            .contains('Task_Delete'))
                          GestureDetector(
                            onTap: () {
                              Get.dialog(DeleteTaskDialog(task: task));
                            },
                            child: Icon(
                              Icons.delete_outline,
                              size: 13.r,
                              color: const Color(0xFFDC3545),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Align(
                alignment: Alignment.center,
                child: _buildStatusAction(
                  task: task,
                  statusBg: statusBg,
                  statusTextColor: statusTextColor,
                  statusText: statusText,
                  statusLower: statusLower,
                  dayStatusLower: dayStatusLower,
                  isReviewOrUnderReview: isReviewOrUnderReview,
                  isRejected: isRejected,
                  isOverdue: isOverdue,
                  isUpcoming: isUpcoming,
                  isActive: isActive,
                  showTimer: true,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  // endregion

  // region UI Builders
  Widget _buildStatusAction({
    required TaskItem task,
    required Color statusBg,
    required Color statusTextColor,
    required String statusText,
    required String statusLower,
    required String dayStatusLower,
    required bool isReviewOrUnderReview,
    required bool isRejected,
    required bool isOverdue,
    required bool isUpcoming,
    required bool isActive,
    bool showTimer = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (task.canStatusBtnClicked != true) {
          AppCommonToastMessage.show(
            message:
                'You do not have permission to perform this action.',
            type: ToastType.warning,
          );
          return;
        }
        final status = task.status.toLowerCase().trim();
        final taskStatus = (task.taskStatus ?? '').toLowerCase().trim();
        final isCancelReview = status == 'cancel_review' ||
            status == 'cancel review' ||
            taskStatus == 'cancel review';
        final controller = Get.find<TasksController>();
        if (isCancelReview) {
          if (task.canCancelReview == true) {
            controller.fetchTaskSubmissionDetails(
              task,
              isReview: true,
              readOnly: false,
            );
          }
          return;
        }
        if (status == 'review' || status == 'under_review') {
          final user = Get.find<StorageService>().getUser();
          final isApprover = task.approverId == user?.id?.toString();
          controller.fetchTaskSubmissionDetails(
            task,
            isReview: true,
            readOnly: !isApprover,
          );
        } else if (status == 'due' ||
            status == 'overdue' ||
            status == 'pending' ||
            status == 'rejected' ||
            isOverdue) {
          controller.fetchTaskSubmissionDetails(
            task,
            isReview: false,
          );
        } else if (status == 'completed' || status == 'approved') {
          controller.fetchTaskSubmissionDetails(
            task,
            isReview: true,
            readOnly: true,
          );
        } else if (status == 'cancelled' ||
            taskStatus == 'task cancelled' ||
            taskStatus == 'cancelled') {
          // Cancelled task: status button should never open edit task page
          return;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 65.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w700,
                  color: statusTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (showTimer) ...[
            if (isReviewOrUnderReview &&
                task.approverName != null &&
                task.approverName!.isNotEmpty) ...[
              SizedBox(height: 3.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 11.r,
                    color: const Color(0xFF8B0000),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    task.approverName!,
                    style: AppTextStyle.style_10_600(
                      color: const Color(0xFF8B0000),
                    ),
                  ),
                ],
              ),
            ],
            if ((isOverdue ||
                    statusLower == 'overdue' ||
                    statusLower == 'due' ||
                    dayStatusLower == 'overdue') &&
                !isRejected &&
                !isReviewOrUnderReview) ...[
              SizedBox(height: 3.h),
              Text(
                'Overdue by',
                style: AppTextStyle.style_8_400(
                  color: const Color(0xFF6C757D),
                ),
              ),
              Obx(() {
                if (Get.isRegistered<TasksController>()) {
                  final _ = Get.find<TasksController>().currentTime.value;
                }
                return Text(
                  _getOverdueDuration(task),
                  style: AppTextStyle.style_10_700(
                    color: AppColors.black,
                  ),
                );
              }),
            ],
            if ((isUpcoming || statusLower == 'upcoming') &&
                !isRejected &&
                !isReviewOrUnderReview) ...[
              SizedBox(height: 3.h),
              Text(
                'Starts in',
                style: AppTextStyle.style_8_400(
                  color: const Color(0xFF6C757D),
                ),
              ),
              Obx(() {
                if (Get.isRegistered<TasksController>()) {
                  final _ = Get.find<TasksController>().currentTime.value;
                }
                return Text(
                  _getStartsInDuration(task.scheduleDateTime),
                  style: AppTextStyle.style_10_700(
                    color: AppColors.black,
                  ),
                );
              }),
            ],
            if (isActive && !isRejected && !isReviewOrUnderReview) ...[
              Obx(() {
                if (Get.isRegistered<TasksController>()) {
                  final _ = Get.find<TasksController>().currentTime.value;
                }
                final remainingDuration = _getEndsInDuration(task);
                if (remainingDuration == '0s') {
                  return const SizedBox.shrink();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 3.h),
                    Text(
                      'Ends in',
                      style: AppTextStyle.style_8_400(
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                    Text(
                      remainingDuration,
                      style: AppTextStyle.style_10_700(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
  // endregion

  // region Date & Time Parsing Helpers
  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {}

    String cleaned = dateStr.replaceAll(',', '').trim();
    try {
      List<String> parts;
      if (cleaned.contains('-')) {
        parts = cleaned.split(RegExp(r'[-\s]+'));
      } else {
        parts = cleaned.split(RegExp(r'\s+'));
      }

      if (parts.length >= 3) {
        int? day = int.tryParse(parts[0]);
        int? year = int.tryParse(parts[2]);

        final monthStr = parts[1].toLowerCase();
        int? month;
        final monthsList = [
          'jan', 'feb', 'mar', 'apr', 'may', 'jun',
          'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
        ];
        for (int i = 0; i < monthsList.length; i++) {
          if (monthStr.startsWith(monthsList[i])) {
            month = i + 1;
            break;
          }
        }

        if (day != null && month != null && year != null) {
          int hour = 0;
          int minute = 0;

          if (parts.length >= 4) {
            final timeParts = parts[3].split(':');
            if (timeParts.isNotEmpty) {
              hour = int.tryParse(timeParts[0]) ?? 0;
              if (timeParts.length > 1) {
                minute = int.tryParse(timeParts[1]) ?? 0;
              }
            }
            if (parts.length >= 5) {
              final marker = parts[4].toLowerCase();
              if (marker == 'pm' && hour < 12) {
                hour += 12;
              } else if (marker == 'am' && hour == 12) {
                hour = 0;
              }
            }
          }

          return DateTime(year, month, day, hour, minute).toLocal();
        }
      }
    } catch (_) {}
    return null;
  }

  DateTime? _parseEndDateTime(TaskItem task) {
    if (task.instanceEndDate != null && task.instanceEndDate!.isNotEmpty) {
      final parsedInstanceEnd = _parseDateTime(task.instanceEndDate);
      if (parsedInstanceEnd != null) return parsedInstanceEnd;
    }

    final date = _parseDateTime(task.scheduleDateTime);
    if (date == null) return null;

    final effectiveEndTime = (task.instEndTime != null && task.instEndTime!.isNotEmpty)
        ? task.instEndTime!
        : task.endTime;

    if (effectiveEndTime.isNotEmpty) {
      final time = _parseTimeOfDay(effectiveEndTime);
      if (time != null) {
        return DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ).toLocal();
      }
    }

    return DateTime(date.year, date.month, date.day, 23, 59, 59).toLocal();
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final parts = clean.split(RegExp(r'[\s:]+'));
      if (parts.isNotEmpty) {
        int hour = int.tryParse(parts[0]) ?? 12;
        int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        if (clean.contains('PM') && hour < 12) {
          hour += 12;
        } else if (clean.contains('AM') && hour == 12) {
          hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  // endregion

  // region Duration & Formatting Helpers
  String _formatCardDate(String dateStr) {
    try {
      final dt = _parseDateTime(dateStr);
      if (dt == null) return AppDateUtils.formatToApiDate(dateStr);
      return AppDateUtils.formatToApiDate(dt.toIso8601String()).replaceAll('-', ' ');
    } catch (_) {
      return AppDateUtils.formatToApiDate(dateStr);
    }
  }

  String _formatDuration(Duration difference) {
    if (difference.isNegative || difference.inSeconds <= 0) {
      return "0s";
    }

    final totalSeconds = difference.inSeconds;

    final weeks = totalSeconds ~/ (3600 * 24 * 7);
    if (weeks >= 4) {
      final months = weeks ~/ 4;
      final remWeeks = weeks % 4;
      return '${months}mo ${remWeeks}w';
    }

    if (weeks > 0) {
      final days = (totalSeconds % (3600 * 24 * 7)) ~/ (3600 * 24);
      return '${weeks}w ${days}d';
    }

    final days = totalSeconds ~/ (3600 * 24);
    if (days > 0) {
      final hours = (totalSeconds % (3600 * 24)) ~/ 3600;
      return '${days}d ${hours}h';
    }

    final hours = totalSeconds ~/ 3600;
    if (hours > 0) {
      final minutes = (totalSeconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }

    final minutes = totalSeconds ~/ 60;
    if (minutes > 0) {
      final seconds = totalSeconds % 60;
      return '${minutes}m ${seconds}s';
    }

    return '${totalSeconds}s';
  }

  String _getOverdueDuration(TaskItem task) {
    try {
      final referenceDateTime = _parseEndDateTime(task);
      if (referenceDateTime == null) return "0s";
      final difference = DateTime.now().difference(referenceDateTime);
      if (difference.isNegative) return "0s";

      return _formatDuration(difference);
    } catch (_) {
      return "0s";
    }
  }

  String _getStartsInDuration(String? scheduleStr) {
    try {
      final scheduleDateTime = _parseDateTime(scheduleStr);
      if (scheduleDateTime == null) return "0s";
      final difference = scheduleDateTime.difference(DateTime.now());
      if (difference.isNegative) return "0s";

      return _formatDuration(difference);
    } catch (_) {
      return "0s";
    }
  }

  String _getEndsInDuration(TaskItem task) {
    try {
      final endDateTime = _parseEndDateTime(task);
      if (endDateTime == null) return "0s";
      final difference = endDateTime.difference(DateTime.now());
      if (difference.isNegative) return "0s";

      return _formatDuration(difference);
    } catch (_) {
      return "0s";
    }
  }
  // endregion
}
// endregion
