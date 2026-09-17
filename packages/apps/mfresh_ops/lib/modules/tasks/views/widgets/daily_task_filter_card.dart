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
import 'package:mfresh_ops/modules/tasks/views/widgets/delete_task_dialog.dart';

class DailyTaskFilterCard extends StatelessWidget {
  final TaskItem task;

  const DailyTaskFilterCard({
    super.key,
    required this.task,
  });

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

    if (!isCompletedOrApproved && !isReviewOrUnderReview && !isRejected) {
      if (dayStatusLower.isNotEmpty) {
        isUpcoming = dayStatusLower == 'upcoming';
        isOverdue = dayStatusLower == 'overdue';
        isActive = dayStatusLower == 'active';
      } else {
        final scheduleDateTime = _parseDateTime(task.scheduleDateTime);
        isUpcoming =
            scheduleDateTime != null &&
            DateTime.now().isBefore(scheduleDateTime);
        if (!isUpcoming) {
          if (statusLower == 'overdue' || statusLower == 'due') {
            isOverdue = true;
          } else {
            final endDt = _parseEndDateTime(task);
            if (endDt != null) {
              isOverdue = DateTime.now().isAfter(endDt);
            } else if (scheduleDateTime != null) {
              isOverdue = DateTime.now().isAfter(scheduleDateTime);
            }
          }
        }
      }
    }

    Color statusBg = AppColors.black2;
    Color statusTextColor = AppColors.white;
    String statusText = task.status;

    if (statusLower == 'review' || statusLower == 'under_review' || dayStatusLower == 'review') {
      statusBg = AppColors.orange900;
      final user = Get.find<StorageService>().getUser();
      if (task.approverId == user?.id?.toString()) {
        statusText = 'Review';
      } else {
        statusText = 'Under Review';
      }
    } else if (isRejected) {
      statusBg = const Color(0xFF8B0000);
      statusText = task.status;
    } else if (isUpcoming) {
      statusBg = const Color(0xFFFFB822);
      statusTextColor = const Color(0xFF212529);
      statusText = task.status.isNotEmpty ? task.status : 'Upcoming';
    } else if (isOverdue) {
      statusBg = const Color(0xFFE25C5C);
      statusText = task.status.isNotEmpty ? task.status : 'Overdue';
    } else if (isActive) {
      statusBg = const Color(0xFF28A745);
      statusText = task.status.isNotEmpty ? task.status : 'Active';
    } else {
      statusText = task.status;
      switch (statusLower) {
        case 'overdue':
          statusBg = const Color(0xFFE25C5C);
          break;
        case 'pending':
        case 'due':
          statusBg = AppColors.red;
          break;
        case 'upcoming':
          statusBg = const Color(0xFFFFB822);
          statusTextColor = const Color(0xFF212529);
          break;
        case 'review':
        case 'under_review':
          statusBg = AppColors.orange900;
          break;
        case 'completed':
        case 'approved':
          statusBg = AppColors.green;
          break;
        case 'rejected':
          statusBg = const Color(0xFF8B0000);
          break;
        default:
          statusBg = AppColors.black2;
      }
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

    return Container(
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
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: task.title,
                        style: AppTextStyle.style_12_700(color: AppColors.black),
                      ),
                      if (projectName.isNotEmpty) ...[
                        TextSpan(
                          text: ' • ',
                          style: AppTextStyle.style_11_400(color: AppColors.grey600),
                        ),
                        TextSpan(
                          text: projectName,
                          style: AppTextStyle.style_11_400(color: AppColors.grey600),
                        ),
                      ],
                    ],
                  ),
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
                // Row 2: Assignee & Action Icons
                Row(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF495057),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
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
            child: GestureDetector(
              onTap: () {
                if (task.canStatusBtnClicked != true) {
                  AppCommonToastMessage.show(
                    message:
                        'You do not have permission to perform this action.',
                    type: ToastType.warning,
                  );
                  return;
                }
                final status = task.status.toLowerCase();
                final controller = Get.find<TasksController>();
                if (status == 'review' || status == 'under_review') {
                  controller.fetchTaskSubmissionDetails(
                    task,
                    isReview: true,
                    readOnly: false,
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
                } else {
                  if (Get.find<AuthRepository>().rxUserPermissions.contains(
                    'Task_Edit',
                  )) {
                    controller.editTaskDetails(task);
                  }
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
                  if ((isOverdue || statusLower == 'overdue' || statusLower == 'due' || dayStatusLower == 'overdue') &&
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final date = _parseDateTime(task.scheduleDateTime);
    if (date == null) return null;

    if (task.endTime.isNotEmpty) {
      final time = _parseTimeOfDay(task.endTime);
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

    return DateTime(date.year, date.month, date.day, 0, 0, 0).toLocal();
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

  String _formatCardDate(String dateStr) {
    try {
      final dt = _parseDateTime(dateStr);
      if (dt == null) return AppDateUtils.formatToApiDate(dateStr);
      return AppDateUtils.formatToApiDate(dt.toIso8601String()).replaceAll('-', ' ');
    } catch (_) {
      return AppDateUtils.formatToApiDate(dateStr);
    }
  }

  String _getOverdueDuration(TaskItem task) {
    try {
      final referenceDateTime = _parseEndDateTime(task);
      if (referenceDateTime == null) return "00:00:00";
      final difference = DateTime.now().difference(referenceDateTime);
      if (difference.isNegative) return "00:00:00";

      final totalSeconds = difference.inSeconds;
      final days = totalSeconds ~/ (3600 * 24);
      final hours = (totalSeconds % (3600 * 24)) ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;

      if (days > 0) {
        return '${days}d ${hours}h ${minutes}m';
      }

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (_) {
      return "00:00:00";
    }
  }

  String _getStartsInDuration(String? scheduleStr) {
    try {
      final scheduleDateTime = _parseDateTime(scheduleStr);
      if (scheduleDateTime == null) return "00:00:00";
      final difference = scheduleDateTime.difference(DateTime.now());
      if (difference.isNegative) return "00:00:00";

      final totalSeconds = difference.inSeconds;
      final days = totalSeconds ~/ (3600 * 24);
      final hours = (totalSeconds % (3600 * 24)) ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;

      if (days > 0) {
        return '${days}d ${hours}h ${minutes}m';
      }

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (_) {
      return "00:00:00";
    }
  }
}
