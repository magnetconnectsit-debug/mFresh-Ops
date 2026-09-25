import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';

class DateTimeRangeResult {
  final DateTime startDateTime;
  final DateTime endDateTime;

  DateTimeRangeResult({
    required this.startDateTime,
    required this.endDateTime,
  });

  String get startFormatted {
    final y = startDateTime.year;
    final m = startDateTime.month.toString().padLeft(2, '0');
    final d = startDateTime.day.toString().padLeft(2, '0');
    final h = startDateTime.hour.toString().padLeft(2, '0');
    final min = startDateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String get endFormatted {
    final y = endDateTime.year;
    final m = endDateTime.month.toString().padLeft(2, '0');
    final d = endDateTime.day.toString().padLeft(2, '0');
    final h = endDateTime.hour.toString().padLeft(2, '0');
    final min = endDateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}

class CustomDateTimeRangeDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const CustomDateTimeRangeDialog({
    super.key,
    this.initialStart,
    this.initialEnd,
  });

  static Future<DateTimeRangeResult?> show(
    BuildContext context, {
    DateTime? initialStart,
    DateTime? initialEnd,
  }) async {
    return showDialog<DateTimeRangeResult>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Container(
          width: 440.w,
          padding: EdgeInsets.all(20.r),
          child: CustomDateTimeRangeDialog(
            initialStart: initialStart,
            initialEnd: initialEnd,
          ),
        ),
      ),
    );
  }

  @override
  State<CustomDateTimeRangeDialog> createState() => _CustomDateTimeRangeDialogState();
}

class _CustomDateTimeRangeDialogState extends State<CustomDateTimeRangeDialog> {
  late DateTime _fromDate;
  late TimeOfDay _fromTime;
  late DateTime _toDate;
  late TimeOfDay _toTime;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.initialStart != null) {
      _fromDate = DateTime(widget.initialStart!.year, widget.initialStart!.month, widget.initialStart!.day);
      _fromTime = TimeOfDay(hour: widget.initialStart!.hour, minute: widget.initialStart!.minute);
    } else {
      _fromDate = now;
      _fromTime = const TimeOfDay(hour: 0, minute: 0);
    }

    if (widget.initialEnd != null) {
      _toDate = DateTime(widget.initialEnd!.year, widget.initialEnd!.month, widget.initialEnd!.day);
      _toTime = TimeOfDay(hour: widget.initialEnd!.hour, minute: widget.initialEnd!.minute);
    } else {
      _toDate = now;
      _toTime = const TimeOfDay(hour: 23, minute: 59);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateRangeText() {
    final startStr = _formatDate(_fromDate);
    final endStr = _formatDate(_toDate);
    if (startStr == endStr) {
      return startStr;
    }
    return '$startStr - $endStr';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _formatTimeRangeText() {
    return '${_formatTime(_fromTime)} - ${_formatTime(_toTime)}';
  }

  void _onApply() {
    final startDt = DateTime(
      _fromDate.year,
      _fromDate.month,
      _fromDate.day,
      _fromTime.hour,
      _fromTime.minute,
    );
    final endDt = DateTime(
      _toDate.year,
      _toDate.month,
      _toDate.day,
      _toTime.hour,
      _toTime.minute,
    );

    if (startDt.isAfter(endDt)) {
      setState(() {
        _errorMessage = 'From Date & Time cannot be after To Date & Time';
      });
      return;
    }

    Navigator.of(context).pop(
      DateTimeRangeResult(
        startDateTime: startDt,
        endDateTime: endDt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Custom Date & Time Range',
              style: AppTextStyle.style_16_700(color: AppColors.grey800),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.r,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Divider(height: 1, color: AppColors.borderColor),
        SizedBox(height: 16.h),

        // ── Single Date Range Field ───────────────────────────────────────
        Text(
          'Date Range',
          style: AppTextStyle.style_13_600(color: AppColors.primary),
        ),
        SizedBox(height: 8.h),
        _buildPickerField(
          label: 'Select Date Range',
          value: _formatDateRangeText(),
          icon: Icons.date_range_rounded,
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _fromDate = picked.start;
                _toDate = picked.end;
                _errorMessage = null;
              });
            }
          },
        ),
        SizedBox(height: 16.h),

        // ── Single Time Range Field ───────────────────────────────────────
        Text(
          'Time Range',
          style: AppTextStyle.style_13_600(color: AppColors.primary),
        ),
        SizedBox(height: 8.h),
        _buildPickerField(
          label: 'Select Time Range',
          value: _formatTimeRangeText(),
          icon: Icons.access_time_rounded,
          onTap: () async {
            final startPicked = await showTimePicker(
              context: context,
              initialTime: _fromTime,
              helpText: 'SELECT FROM TIME',
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                ),
              ),
            );
            if (startPicked != null) {
              if (!mounted) return;
              final endPicked = await showTimePicker(
                context: context,
                initialTime: _toTime,
                helpText: 'SELECT TO TIME',
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  ),
                ),
              );
              if (endPicked != null) {
                setState(() {
                  _fromTime = startPicked;
                  _toTime = endPicked;
                  _errorMessage = null;
                });
              }
            }
          },
        ),

        if (_errorMessage != null) ...[
          SizedBox(height: 12.h),
          Text(
            _errorMessage!,
            style: AppTextStyle.style_12_500(color: Colors.red),
          ),
        ],

        SizedBox(height: 20.h),

        // ── Action Buttons ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppCommonButton(
              text: 'Cancel',
              variant: ButtonVariant.outline,
              isSmall: true,
              height: 36.h,
              width: 90.w,
              onPressed: () => Navigator.of(context).pop(),
            ),
            SizedBox(width: 12.w),
            AppCommonButton(
              text: 'Apply',
              variant: ButtonVariant.primary,
              isSmall: true,
              height: 36.h,
              width: 90.w,
              onPressed: _onApply,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyle.style_10_400(color: AppColors.grey500),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyle.style_12_600(color: AppColors.grey900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  icon,
                  size: 16.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
