import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/delete_task_dialog.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class DailyTaskCard extends StatefulWidget {
  final TaskItem task;

  const DailyTaskCard({super.key, required this.task});

  @override
  State<DailyTaskCard> createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<DailyTaskCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {}

    // Clean the string (e.g. remove commas)
    String cleaned = dateStr.replaceAll(',', '').trim();
    
    // Try split-based manual parsing for formats like "07 Feb 2026" or "27-Feb-2026 10:00 AM"
    try {
      List<String> parts;
      if (cleaned.contains('-')) {
        // Handle parts split by spaces or hyphens, but keeping time components
        parts = cleaned.split(RegExp(r'[-\s]+'));
      } else {
        parts = cleaned.split(RegExp(r'\s+'));
      }
      
      if (parts.length >= 3) {
        int? day = int.tryParse(parts[0]);
        int? year = int.tryParse(parts[2]);
        
        final monthStr = parts[1].toLowerCase();
        int? month;
        final monthsList = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
        for (int i = 0; i < monthsList.length; i++) {
          if (monthStr.startsWith(monthsList[i])) {
            month = i + 1;
            break;
          }
        }
        
        if (day != null && month != null && year != null) {
          int hour = 0;
          int minute = 0;
          
          // If time is present, e.g. ["27", "Feb", "2026", "10:00", "AM"] or ["07", "Feb", "2026", "10:00", "am"]
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
    if (task.endDate.isEmpty) return null;
    try {
      return DateTime.parse(task.endDate).toLocal();
    } catch (_) {}
    
    final date = _parseDateTime(task.endDate);
    if (date == null) return null;
    
    if (task.endTime.isNotEmpty) {
      final time = _parseTimeOfDay(task.endTime);
      if (time != null) {
        return DateTime(date.year, date.month, date.day, time.hour, time.minute).toLocal();
      }
    }
    return date.toLocal();
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

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final statusLower = task.status.toLowerCase();

    // Check if the scheduled date time is in the past
    final scheduleDateTime = _parseDateTime(task.scheduleDateTime);

    final isCompletedOrApproved = statusLower == 'completed' || statusLower == 'approved';
    final isReviewOrUnderReview = statusLower == 'review' || statusLower == 'under_review';
    final isRejected = statusLower == 'rejected';

    final isUpcoming = !isCompletedOrApproved &&
        !isReviewOrUnderReview &&
        scheduleDateTime != null &&
        DateTime.now().isBefore(scheduleDateTime);

    bool isOverdue = false;
    if (!isCompletedOrApproved && !isReviewOrUnderReview) {
      if (statusLower == 'overdue') {
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

    Color statusBg;
    Color statusTextColor = AppColors.white;
    String statusText;

    if (isRejected) {
      statusBg = const Color(0xFF8B0000);
      statusText = 'Rejected';
    } else if (isUpcoming) {
      statusBg = const Color(0xFFFFB822);
      statusTextColor = const Color(0xFF212529);
      statusText = 'Upcoming';
    } else if (isOverdue) {
      statusBg = const Color(0xFFE25C5C);
      statusText = 'Overdue';
    } else {
      statusText = task.status;
      switch (statusLower) {
        case 'overdue':
          statusBg = const Color(0xFFE25C5C);
          statusText = 'Overdue';
          break;
        case 'pending':
        case 'due':
          statusBg = AppColors.red;
          statusText = 'Due';
          break;
        case 'upcoming':
          statusBg = const Color(0xFFFFB822);
          statusTextColor = const Color(0xFF212529);
          statusText = 'Upcoming';
          break;
        case 'review':
        case 'under_review':
          statusBg = AppColors.orange900;
          statusText = 'Review';
          break;
        case 'completed':
        case 'approved':
          statusBg = AppColors.green;
          statusText = 'Completed';
          break;
        case 'rejected':
          statusBg = const Color(0xFF8B0000);
          statusText = 'Rejected';
          break;
        default:
          statusBg = AppColors.black2;
      }
    }

    final isRecurring = task.frequency.toLowerCase() != 'none' && task.frequency.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Leading Icon
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(
                isRecurring ? Icons.sync : Icons.person,
                size: 18.r,
                color: isRecurring ? const Color(0xFFFF3B30) : const Color(0xFF212529),
              ),
            ),
            SizedBox(width: 8.w),
            // Middle Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: _isExpanded ? null : 1,
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: AppTextStyle.style_14_700(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Metadata Row 1: Time and Date
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildIconText(
                        Icons.access_time_outlined,
                        '${task.startTime} - ${task.endTime}',
                      ),
                      _buildIconText(
                        Icons.calendar_today_outlined,
                        _formatCardDate(task.scheduleDateTime),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (task.groupNames != null && task.groupNames!.isNotEmpty)
                                  ? Icons.people_outline
                                  : Icons.person_outline,
                              size: 12.r,
                              color: const Color(0xFF6C757D),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                (task.groupNames != null && task.groupNames!.isNotEmpty)
                                    ? task.groupNames!
                                    : (task.assigneeName != null && task.assigneeName!.isNotEmpty)
                                        ? task.assigneeName!
                                        : 'Unassigned',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6C757D),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      if (Get.find<AuthRepository>().rxUserPermissions.contains('Task_Edit')) ...[
                        GestureDetector(
                          onTap: () {
                            Get.find<TasksController>().editTaskDetails(task);
                          },
                          child: Icon(
                            Icons.edit,
                            size: 14.r,
                            color: const Color(0xFF0D6EFD),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (Get.find<AuthRepository>().rxUserPermissions.contains('Task_Delete'))
                        GestureDetector(
                          onTap: () {
                            Get.dialog(DeleteTaskDialog(task: task));
                          },
                          child: Icon(
                            Icons.delete_outline,
                            size: 14.r,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Right Badge Column
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  final status = task.status.toLowerCase();
                  final controller = Get.find<TasksController>();
                  if (status == 'review' || status == 'under_review') {
                    if (task.canStatusBtnClicked == true) {
                      controller.fetchTaskSubmissionDetails(task, isReview: true);
                    }
                  } else if (status == 'due' ||
                      status == 'overdue' ||
                      status == 'pending' ||
                      status == 'rejected' ||
                      isOverdue) {
                    controller.fetchTaskSubmissionDetails(task, isReview: false);
                  } else if (status == 'completed' || status == 'approved') {
                    controller.fetchTaskSubmissionDetails(task, isReview: true, readOnly: true);
                  } else {
                    if (Get.find<AuthRepository>().rxUserPermissions.contains('Task_Edit')) {
                      controller.editTaskDetails(task);
                    }
                  }
                },
                child: Column(
                  crossAxisAlignment: isRejected ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 75.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ),
                    if ((isOverdue || statusLower == 'overdue') && !isRejected) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Overdue by',
                        style: AppTextStyle.style_8_400(color: const Color(0xFF6C757D)),
                      ),
                      Obx(() {
                        // Trigger Obx refresh by accessing centralized currentTime value
                        final _ = Get.find<TasksController>().currentTime.value;
                        return Text(
                          _getOverdueDuration(task.scheduleDateTime),
                          style: AppTextStyle.style_10_700(color: AppColors.black),
                        );
                      }),
                    ],
                    if ((isUpcoming || statusLower == 'upcoming') && !isRejected) ...[
                      SizedBox(height: 4.h),
                      Obx(() {
                        // Trigger Obx refresh by accessing centralized currentTime value
                        final _ = Get.find<TasksController>().currentTime.value;
                        return Text(
                          'Starts in ${_getStartsInDuration(task.scheduleDateTime)}',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF212529),
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
      ),
    ),
  );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.r, color: const Color(0xFF6C757D)),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C757D),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCardDate(String dateStr) {
    try {
      final dt = _parseDateTime(dateStr);
      if (dt == null) return dateStr;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  String _getOverdueDuration(String scheduleStr) {
    try {
      final scheduleDateTime = _parseDateTime(scheduleStr);
      if (scheduleDateTime == null) return "00:00:00";
      final difference = DateTime.now().difference(scheduleDateTime);
      if (difference.isNegative) return "00:00:00";

      final totalSeconds = difference.inSeconds;
      final days = totalSeconds ~/ (3600 * 24);
      final hours = (totalSeconds % (3600 * 24)) ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;

      // More than 24 hours → show days format
      if (days > 0) {
        return '${days}d ${hours}h ${minutes}m';
      }

      // Under 24 hours → show HH:MM:SS format
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
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (_) {
      return "00:00:00";
    }
  }
}
