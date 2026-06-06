import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_submission_dialog.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/delete_task_dialog.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

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

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final statusLower = task.status.toLowerCase();

    // Check if the scheduled date time is in the past
    final scheduleDateTime = _parseDateTime(task.scheduleDateTime);

    final isCompletedOrApproved = statusLower == 'completed' || statusLower == 'approved';
    final isReviewOrUnderReview = statusLower == 'review' || statusLower == 'under_review';

    final isOverdue = !isCompletedOrApproved &&
        !isReviewOrUnderReview &&
        scheduleDateTime != null &&
        DateTime.now().isAfter(scheduleDateTime);

    final isUpcoming = !isCompletedOrApproved &&
        !isReviewOrUnderReview &&
        scheduleDateTime != null &&
        DateTime.now().isBefore(scheduleDateTime);

    Color statusBg;
    Color statusTextColor = AppColors.white;
    String statusText;

    if (isUpcoming) {
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
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
                    style: AppTextStyle.style_12_700(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Metadata Wrap
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (task.groupNames != null && task.groupNames!.isNotEmpty)
                                ? Icons.people_outline
                                : Icons.person_outline,
                            size: 10.r,
                            color: const Color(0xFF6C757D),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            (task.groupNames != null && task.groupNames!.isNotEmpty)
                                ? task.groupNames!
                                : (task.assigneeName != null && task.assigneeName!.isNotEmpty)
                                    ? task.assigneeName!
                                    : '',
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<TasksController>().formInitialized.value = false;
                          Get.toNamed(AppRoutes.createTask, arguments: task);
                        },
                        child: Icon(
                          Icons.edit,
                          size: 14.r,
                          color: const Color(0xFF0D6EFD),
                        ),
                      ),
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
            GestureDetector(
              onTap: () {
                final status = task.status.toLowerCase();
                if (status == 'review' || status == 'under_review') {
                  Get.dialog(TaskSubmissionDialog(task: task, isReview: true));
                } else if (status == 'due' ||
                    status == 'overdue' ||
                    status == 'pending' ||
                    status == 'rejected' ||
                    isOverdue) {
                  Get.dialog(TaskSubmissionDialog(task: task, isReview: false));
                } else if (status != 'completed' && status != 'approved') {
                  Get.find<TasksController>().formInitialized.value = false;
                  Get.toNamed(AppRoutes.createTask, arguments: task);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 75.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        statusText,
                        style: AppTextStyle.style_10_700(color: statusTextColor),
                      ),
                    ),
                  ),
                  if (isOverdue || statusLower == 'overdue') ...[
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
                  if (isUpcoming || statusLower == 'upcoming') ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.r, color: const Color(0xFF6C757D)),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w400,
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
