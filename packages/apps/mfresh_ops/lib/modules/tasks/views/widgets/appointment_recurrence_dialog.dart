// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
// endregion

// region RecurrenceData Model
class RecurrenceData {
  final String frequency; // 'day', 'week', 'month', 'year'
  final int repeatInterval;
  final String startTime;
  final String endTime;
  final String? selectedDays; // e.g. "Wed,Sat"
  final int? occurrences;
  final DateTime startDate;
  final DateTime? endByDate;

  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final String? seriesEndChoice;

  // Monthly fields
  final String? monthlyMode; // 'day' or 'the'
  final int? monthDay;
  final int? monthInterval;
  final String? monthOrdinal; // 'First','Second','Third','Fourth','Last'
  final String? monthWeekday; // 'Monday','Tuesday', etc.

  // Yearly fields
  final String? yearlyMode; // 'on' or 'the'
  final String? yearlyMonth; // 'January', etc.
  final int? yearlyDay;
  final int? yearlyInterval;
  final String? yearlyOrdinal;
  final String? yearlyWeekday;
  final String? yearlyTheMonth;

  String? get monthlyPattern => monthlyMode;

  String? get monthlyWeek => monthOrdinal;

  String? get monthlyDayName => monthWeekday;

  String? get yearlyPattern => yearlyMode;

  String? get yearlyDayName => yearlyWeekday;

  String? get yearlyMonth2 => yearlyTheMonth;

  RecurrenceData({
    required this.frequency,
    required this.repeatInterval,
    required this.startTime,
    required this.endTime,
    this.selectedDays,
    this.occurrences,
    required this.startDate,
    this.endByDate,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.seriesEndChoice,
    this.monthlyMode,
    this.monthDay,
    this.monthInterval,
    this.monthOrdinal,
    this.monthWeekday,
    this.yearlyMode,
    this.yearlyMonth,
    this.yearlyDay,
    this.yearlyInterval,
    this.yearlyOrdinal,
    this.yearlyWeekday,
    this.yearlyTheMonth,
  });

  factory RecurrenceData.fromTaskItem(TaskItem task) {
    String freq = task.frequency.toLowerCase().trim();
    if (freq == 'daily') {
      freq = 'day';
    } else if (freq == 'weekly') {
      freq = 'week';
    } else if (freq == 'monthly') {
      freq = 'month';
    } else if (freq == 'yearly') {
      freq = 'year';
    }
    if (freq.isEmpty || freq == 'none') freq = 'day';

    final interval = int.tryParse(task.repeatInterval) ?? 1;

    DateTime? tryParseDate(String? str) {
      if (str == null || str.isEmpty || str == 'NA') return null;
      try {
        return DateTime.parse(str);
      } catch (_) {
        try {
          return DateTime.parse(str.replaceAll(' ', 'T'));
        } catch (_) {
          return null;
        }
      }
    }

    // Series Start Date (Range of Recurrence)
    final seriesStartStr =
        (task.seriesStartDate != null &&
            task.seriesStartDate!.isNotEmpty &&
            task.seriesStartDate != 'NA')
        ? task.seriesStartDate!
        : ((task.masterStartDate != null &&
                  task.masterStartDate!.isNotEmpty &&
                  task.masterStartDate != 'NA')
              ? task.masterStartDate!
              : task.scheduleDateTime);
    final DateTime parsedStartDate =
        tryParseDate(seriesStartStr) ?? DateTime.now();

    // Series End Date (Range of Recurrence)
    final seriesEndStr =
        (task.seriesEndDate != null &&
            task.seriesEndDate!.isNotEmpty &&
            task.seriesEndDate != 'NA')
        ? task.seriesEndDate!
        : ((task.masterEndDate != null &&
                  task.masterEndDate!.isNotEmpty &&
                  task.masterEndDate != 'NA')
              ? task.masterEndDate
              : null);
    final DateTime? parsedEndByDate = tryParseDate(seriesEndStr);

    // Each Recurrence Start Date (Do NOT use task.startDate for Entire Series UI)
    final recStartStr =
        (task.recurrenceStartDate != null &&
            task.recurrenceStartDate!.isNotEmpty &&
            task.recurrenceStartDate != 'NA')
        ? task.recurrenceStartDate!
        : seriesStartStr;
    final DateTime parsedRecurrenceStartDate =
        tryParseDate(recStartStr) ?? parsedStartDate;

    // Each Recurrence End Date (Do NOT use task.endDate for Entire Series UI)
    final recEndStr =
        (task.recurrenceEndDate != null &&
            task.recurrenceEndDate!.isNotEmpty &&
            task.recurrenceEndDate != 'NA')
        ? task.recurrenceEndDate!
        : (seriesEndStr ?? recStartStr);
    final DateTime parsedRecurrenceEndDate =
        tryParseDate(recEndStr) ?? parsedRecurrenceStartDate;

    // Series End Choice: by = End by, after = End after
    final rawChoice = task.seriesEndChoice?.toLowerCase().trim();
    final isEndBy =
        (rawChoice == 'by' || rawChoice == 'end_by') ||
        (rawChoice != 'after' &&
            rawChoice != 'occurrences' &&
            rawChoice != 'end_after' &&
            (parsedEndByDate != null ||
                task.occurrences.isEmpty ||
                task.occurrences == 'NA'));
    final seriesEndChoice = isEndBy ? 'by' : 'after';
    final occurrences = isEndBy ? null : int.tryParse(task.occurrences);

    final sTime = task.startTime.isNotEmpty && task.startTime != 'NA'
        ? task.startTime
        : (task.instStartTime ?? '');
    final eTime = task.endTime.isNotEmpty && task.endTime != 'NA'
        ? task.endTime
        : (task.instEndTime ?? '');

    String? selDays = task.selectedDays.isNotEmpty && task.selectedDays != 'NA'
        ? task.selectedDays
        : null;

    // Monthly
    String? monthlyMode = task.monthlyPattern;
    int? monthDay = int.tryParse(task.monthDays);
    int? monthInterval = interval;
    String? monthOrdinal = task.monthlyWeek;
    String? monthWeekday = task.monthlyDayName;

    if (freq == 'month') {
      if (monthlyMode == null || monthlyMode.isEmpty) {
        if (task.monthDays.isNotEmpty &&
            task.monthDays != 'null' &&
            task.monthDays != 'NA') {
          monthlyMode = 'day';
          monthDay = int.tryParse(task.monthDays) ?? parsedStartDate.day;
        } else if (selDays != null && selDays.contains(',')) {
          monthlyMode = 'the';
          final parts = selDays.split(',');
          monthOrdinal = parts[0];
          monthWeekday = _expandWeekday(parts.length > 1 ? parts[1] : 'Mon');
          selDays = null;
        } else {
          monthlyMode = 'day';
          monthDay = parsedStartDate.day;
        }
      }
    }

    // Yearly
    String? yearlyMode = task.yearlyPattern;
    String? yearlyMonth = task.yearlyMonth;
    int? yearlyDay = int.tryParse(task.yearlyDay ?? '');
    int? yearlyInterval = interval;
    String? yearlyOrdinal = task.yearlyWeek;
    String? yearlyWeekday = task.yearlyDayName != null
        ? _expandWeekday(task.yearlyDayName!)
        : null;
    String? yearlyTheMonth = task.yearlyMonth2;

    if (freq == 'year') {
      if (yearlyMode == null || yearlyMode.isEmpty) {
        if (selDays != null && selDays.contains(',')) {
          yearlyMode = 'the';
          final parts = selDays.split(',');
          yearlyOrdinal = parts[0];
          yearlyWeekday = _expandWeekday(parts.length > 1 ? parts[1] : 'Mon');
          yearlyTheMonth = _getMonthName(parsedStartDate.month);
          selDays = null;
        } else {
          yearlyMode = 'on';
          yearlyMonth = _getMonthName(parsedStartDate.month);
          yearlyDay =
              int.tryParse(task.monthDays) ??
              (int.tryParse(task.yearDays) ?? parsedStartDate.day);
        }
      }
    }

    return RecurrenceData(
      frequency: freq,
      repeatInterval: interval,
      startTime: sTime,
      endTime: eTime,
      selectedDays: selDays,
      occurrences: occurrences,
      startDate: parsedStartDate,
      endByDate: isEndBy ? parsedEndByDate : null,
      recurrenceStartDate: parsedRecurrenceStartDate,
      recurrenceEndDate: parsedRecurrenceEndDate,
      seriesEndChoice: seriesEndChoice,
      monthlyMode: monthlyMode,
      monthDay: monthDay,
      monthInterval: monthInterval,
      monthOrdinal: monthOrdinal,
      monthWeekday: monthWeekday,
      yearlyMode: yearlyMode,
      yearlyMonth: yearlyMonth,
      yearlyDay: yearlyDay,
      yearlyInterval: yearlyInterval,
      yearlyOrdinal: yearlyOrdinal,
      yearlyWeekday: yearlyWeekday,
      yearlyTheMonth: yearlyTheMonth,
    );
  }

  static String _expandWeekday(String shortOrLong) {
    final lower = shortOrLong.toLowerCase();
    if (lower.startsWith('mon')) return 'Monday';
    if (lower.startsWith('tue')) return 'Tuesday';
    if (lower.startsWith('wed')) return 'Wednesday';
    if (lower.startsWith('thu')) return 'Thursday';
    if (lower.startsWith('fri')) return 'Friday';
    if (lower.startsWith('sat')) return 'Saturday';
    if (lower.startsWith('sun')) return 'Sunday';
    return 'Monday';
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return 'January';
  }
}
// endregion

// region AppointmentRecurrenceDialog Widget
class AppointmentRecurrenceDialog extends StatefulWidget {
  final RecurrenceData? initialData;
  final DateTime? defaultStartDate;
  final DateTime? defaultEndDate;
  final TimeOfDay? defaultStartTime;
  final TimeOfDay? defaultEndTime;

  const AppointmentRecurrenceDialog({
    super.key,
    this.initialData,
    this.defaultStartDate,
    this.defaultEndDate,
    this.defaultStartTime,
    this.defaultEndTime,
  });

  @override
  State<AppointmentRecurrenceDialog> createState() =>
      _AppointmentRecurrenceDialogState();
}

class _AppointmentRecurrenceDialogState
    extends State<AppointmentRecurrenceDialog> {
  RecurrenceData? _currentData;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
      backgroundColor: AppColors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Appointment Recurrence',
                      style: AppTextStyle.style_14_600(color: AppColors.black),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        color: AppColors.black,
                        size: 18.r,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 16.h, color: const Color(0xffE9ECEF)),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: AppointmentRecurrenceForm(
                    initialData: widget.initialData,
                    defaultStartDate: widget.defaultStartDate,
                    defaultEndDate: widget.defaultEndDate,
                    defaultStartTime: widget.defaultStartTime,
                    defaultEndTime: widget.defaultEndTime,
                    onChanged: (data) => _currentData = data,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: 'Save',
                      buttonColor: const Color(0xFFF15A24),
                      textColor: Colors.white,
                      height: 26.h,
                      textSize: 11.sp,
                      borderRadius: 4.r,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      useGradient: false,
                      onPressed: () => Get.back(result: _currentData),
                    ),
                    SizedBox(width: 8.w),
                    AppCommonButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      textColor: AppColors.black,
                      borderColor: const Color(0xffDEE2E6),
                      height: 26.h,
                      textSize: 11.sp,
                      borderRadius: 4.r,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// endregion

// region _RecurrenceTabItem Model
class _RecurrenceTabItem {
  final String label;
  final String value;

  const _RecurrenceTabItem({required this.label, required this.value});
}
// endregion

// region AppointmentRecurrenceForm Widget
class AppointmentRecurrenceForm extends StatefulWidget {
  final RecurrenceData? initialData;
  final DateTime? defaultStartDate;
  final DateTime? defaultEndDate;
  final TimeOfDay? defaultStartTime;
  final TimeOfDay? defaultEndTime;
  final ValueChanged<RecurrenceData>? onChanged;
  final bool readOnly;
  final FocusNode? intervalFocusNode;

  const AppointmentRecurrenceForm({
    super.key,
    this.initialData,
    this.defaultStartDate,
    this.defaultEndDate,
    this.defaultStartTime,
    this.defaultEndTime,
    this.onChanged,
    this.readOnly = false,
    this.intervalFocusNode,
  });

  @override
  State<AppointmentRecurrenceForm> createState() =>
      _AppointmentRecurrenceFormState();
}
// endregion

// region _AppointmentRecurrenceFormState
class _AppointmentRecurrenceFormState extends State<AppointmentRecurrenceForm> {
  static const _recurrenceTabs = [
    _RecurrenceTabItem(label: 'Daily', value: 'day'),
    _RecurrenceTabItem(label: 'Weekly', value: 'week'),
    _RecurrenceTabItem(label: 'Monthly', value: 'month'),
    _RecurrenceTabItem(label: 'Yearly', value: 'year'),
  ];

  late String _frequency;
  late int _repeatInterval;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final FocusNode _occurrencesFocusNode = FocusNode();
  final FocusNode _startTimeFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();

  // Weekly selection
  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final Set<String> _selectedDays = {};

  // Daily selection
  bool _everyWeekday = false;

  // Monthly selection
  bool _monthlyByDay = true; // true = Day mode, false = The mode
  String _monthOrdinal = 'First';
  String _monthWeekday = 'Monday';
  final TextEditingController _monthDayController = TextEditingController(
    text: '1',
  );
  final TextEditingController _monthIntervalController = TextEditingController(
    text: '1',
  );
  final TextEditingController _monthTheDayIntervalController =
      TextEditingController(text: '1');

  // Yearly selection
  bool _yearlyByDate = true; // true = On mode, false = The mode
  String _yearlyMonth = 'January';
  String _yearlyOrdinal = 'First';
  String _yearlyWeekday = 'Monday';
  String _yearlyTheMonth = 'January';
  final TextEditingController _yearlyDayController = TextEditingController(
    text: '1',
  );
  final TextEditingController _yearlyIntervalController = TextEditingController(
    text: '1',
  );

  static const _ordinals = ['First', 'Second', 'Third', 'Fourth', 'Last'];
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Range of Recurrence
  late DateTime _startDate;
  DateTime? _endByDate;
  int? _occurrences;
  bool _endByMode = true;
  DateTime? _instanceStartDate;
  DateTime? _instanceEndDate;

  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _occurrencesController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endByDateController = TextEditingController();
  final TextEditingController _instanceStartDateController =
      TextEditingController();
  final TextEditingController _instanceEndDateController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _startDate =
        widget.defaultStartDate ??
        widget.initialData?.startDate ??
        DateTime.now();
    _endByDate = widget.defaultEndDate ?? widget.initialData?.endByDate;
    _instanceStartDate =
        widget.initialData?.recurrenceStartDate ??
        widget.defaultStartDate ??
        widget.initialData?.startDate;
    _instanceEndDate =
        widget.initialData?.recurrenceEndDate ??
        widget.defaultEndDate ??
        widget.initialData?.endByDate ??
        _instanceStartDate;

    if (widget.defaultStartTime != null) {
      _startTime = widget.defaultStartTime;
    } else if (widget.initialData != null &&
        widget.initialData!.startTime.isNotEmpty) {
      _startTime = _parseTime(widget.initialData!.startTime);
    } else {
      _startTime = null;
    }

    if (widget.defaultEndTime != null) {
      _endTime = widget.defaultEndTime;
    } else if (widget.initialData != null &&
        widget.initialData!.endTime.isNotEmpty) {
      _endTime = _parseTime(widget.initialData!.endTime);
    } else {
      _endTime = null;
    }

    if (widget.initialData != null) {
      final data = widget.initialData!;
      _frequency = data.frequency;
      _repeatInterval = data.repeatInterval;
      _selectedDays.addAll(data.selectedDays?.split(',') ?? []);
      _occurrences = data.occurrences;
      if (data.seriesEndChoice != null) {
        _endByMode =
            data.seriesEndChoice == 'end_by' || data.seriesEndChoice == 'by';
      } else {
        _endByMode = data.endByDate != null || data.occurrences == null;
      }
      _everyWeekday =
          data.frequency == 'day' &&
          data.repeatInterval == 1 &&
          data.selectedDays == 'Mon,Tue,Wed,Thu,Fri';

      // Monthly restore
      if (data.monthlyMode != null) {
        _monthlyByDay = data.monthlyMode == 'day';
        _monthDayController.text = (data.monthDay ?? 1).toString();
        _monthIntervalController.text = (data.monthInterval ?? 1).toString();
        _monthTheDayIntervalController.text = (data.monthInterval ?? 1)
            .toString();
        _monthOrdinal = data.monthOrdinal ?? 'First';
        _monthWeekday = data.monthWeekday ?? 'Monday';
      }
      // Yearly restore
      if (data.yearlyMode != null) {
        _yearlyByDate = data.yearlyMode == 'on';
        _yearlyMonth = data.yearlyMonth ?? 'January';
        _yearlyDayController.text = (data.yearlyDay ?? 1).toString();
        _yearlyIntervalController.text = (data.yearlyInterval ?? 1).toString();
        _yearlyOrdinal = data.yearlyOrdinal ?? 'First';
        _yearlyWeekday = data.yearlyWeekday ?? 'Monday';
        _yearlyTheMonth = data.yearlyTheMonth ?? 'January';
      }
    } else {
      _frequency = 'day';
      _repeatInterval = 1;
      _endByMode = true;
    }
    _intervalController.text = _repeatInterval.toString();
    _occurrencesController.text = _occurrences?.toString() ?? '';
    _syncDateTimeControllers();

    _occurrencesFocusNode.addListener(() {
      if (_occurrencesFocusNode.hasFocus && _endByMode) {
        setState(() {
          _endByMode = false;
        });
        _notifyChanges();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyChanges();
    });
  }

  void _syncDateTimeControllers() {
    _startDateController.text = AppDateUtils.formatToApiDate(
      _startDate.toIso8601String(),
    );
    _endByDateController.text = _endByDate != null
        ? AppDateUtils.formatToApiDate(_endByDate!.toIso8601String())
        : '';
    _instanceStartDateController.text = AppDateUtils.formatToApiDate(
      (_instanceStartDate ?? _startDate).toIso8601String(),
    );
    _instanceEndDateController.text = AppDateUtils.formatToApiDate(
      (_instanceEndDate ?? _endByDate ?? _startDate).toIso8601String(),
    );
    _startTimeController.text = _formatTimeOfDay(_startTime);
    _endTimeController.text = _formatTimeOfDay(_endTime);
  }

  void _jumpToOccurrences() {
    setState(() {
      _endByMode = false;
    });
    _occurrencesFocusNode.requestFocus();
  }

  Future<void> _pickStartTimeField() async {
    _startTimeFocusNode.requestFocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      helpText: 'Select Start Time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
      _notifyChanges();
    }
    _pickEndTimeField();
  }

  Future<void> _pickEndTimeField() async {
    _endTimeFocusNode.requestFocus();
    final initialEnd =
        _endTime ??
        (_startTime != null
            ? TimeOfDay(
                hour: (_startTime!.hour + 1) % 24,
                minute: _startTime!.minute,
              )
            : TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initialEnd,
      helpText: 'Select End Time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
      _notifyChanges();
    }
    _jumpToOccurrences();
  }

  void _notifyChanges() {
    if (widget.onChanged == null) return;
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final occurrences = _endByMode
        ? null
        : int.tryParse(_occurrencesController.text.trim());
    final selectedDaysStr = _frequency == 'week'
        ? (_selectedDays.isEmpty ? null : _selectedDays.join(','))
        : (_everyWeekday ? 'Mon,Tue,Wed,Thu,Fri' : null);

    final data = RecurrenceData(
      frequency: _frequency,
      repeatInterval: _everyWeekday ? 1 : interval,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      selectedDays: selectedDaysStr,
      occurrences: occurrences,
      startDate: _startDate,
      endByDate: _endByMode ? _endByDate : null,
      recurrenceStartDate: _instanceStartDate ?? _startDate,
      recurrenceEndDate: _instanceEndDate ?? _startDate,
      seriesEndChoice: _endByMode ? 'by' : 'after',
      monthlyMode: _frequency == 'month'
          ? (_monthlyByDay ? 'day' : 'the')
          : null,
      monthDay: _frequency == 'month'
          ? (int.tryParse(_monthDayController.text) ?? 1)
          : null,
      monthInterval: _frequency == 'month'
          ? (int.tryParse(
                  _monthlyByDay
                      ? _monthIntervalController.text
                      : _monthTheDayIntervalController.text,
                ) ??
                1)
          : null,
      monthOrdinal: _frequency == 'month' && !_monthlyByDay
          ? _monthOrdinal
          : null,
      monthWeekday: _frequency == 'month' && !_monthlyByDay
          ? _monthWeekday
          : null,
      yearlyMode: _frequency == 'year' ? (_yearlyByDate ? 'on' : 'the') : null,
      yearlyMonth: _frequency == 'year' && _yearlyByDate ? _yearlyMonth : null,
      yearlyDay: _frequency == 'year' && _yearlyByDate
          ? (int.tryParse(_yearlyDayController.text) ?? 1)
          : null,
      yearlyInterval: _frequency == 'year'
          ? (int.tryParse(_yearlyIntervalController.text) ?? 1)
          : null,
      yearlyOrdinal: _frequency == 'year' && !_yearlyByDate
          ? _yearlyOrdinal
          : null,
      yearlyWeekday: _frequency == 'year' && !_yearlyByDate
          ? _yearlyWeekday
          : null,
      yearlyTheMonth: _frequency == 'year' && !_yearlyByDate
          ? _yearlyTheMonth
          : null,
    );
    widget.onChanged!(data);
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final parts = clean
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim()
          .split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endByDateController.dispose();
    _instanceStartDateController.dispose();
    _instanceEndDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _intervalController.dispose();
    _occurrencesController.dispose();
    _monthDayController.dispose();
    _monthIntervalController.dispose();
    _monthTheDayIntervalController.dispose();
    _yearlyDayController.dispose();
    _yearlyIntervalController.dispose();
    _occurrencesFocusNode.dispose();
    _startTimeFocusNode.dispose();
    _endTimeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recurrence Pattern
        Text(
          'Recurrence Pattern',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        SizedBox(height: 10.h),

        // Recurrence Pattern Section — Connected Tab & Content Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabBar(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: _buildPatternDetails(),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        if (_frequency != 'day' && _frequency != 'week') ...[
          // ── Each Recurrence ──
          Text(
            'Each Recurrence',
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date',
                  date: _instanceStartDate ?? _startDate,
                  readOnly: false,
                  customController: _instanceStartDateController,
                  onSelected: (d) {
                    if (widget.readOnly) return;
                    setState(() {
                      _instanceStartDate = d;
                      if (_instanceEndDate == null ||
                          _instanceEndDate!.isBefore(d)) {
                        _instanceEndDate = d;
                      }
                    });
                    _notifyChanges();
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDateField(
                  label: 'End Date',
                  date: _instanceEndDate ?? _startDate,
                  readOnly: false,
                  customController: _instanceEndDateController,
                  onSelected: (d) {
                    if (widget.readOnly) return;
                    setState(() => _instanceEndDate = d);
                    _notifyChanges();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildStartEndTimeRow(),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFDEE2E6)),
          SizedBox(height: 16.h),
        ],

        // ── Range of Recurrence (Series) ──
        Text(
          'Range of Recurrence (Series)',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        SizedBox(height: 12.h),

        _buildDateField(
          label: 'Start Date',
          isRequired: true,
          date: _startDate,
          onSelected: (d) {
            if (widget.readOnly) return;
            setState(() {
              _startDate = d;
              _instanceStartDate = d;
              _instanceEndDate = d;
              if (_endByDate == null || _endByDate!.isBefore(d)) {
                _endByDate = d;
              }
            });
            _notifyChanges();
          },
        ),
        SizedBox(height: 8.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRadioRow('End by', true),
                  SizedBox(height: 4.h),
                  _buildDateField(
                    label: 'End Date',
                    date: _endByDate,
                    onSelected: (d) {
                      if (widget.readOnly) return;
                      if (_endByMode) {
                        setState(() => _endByDate = d);
                        _notifyChanges();
                      }
                    },
                    enabled: _endByMode,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRadioRow('End after', false),
                  SizedBox(height: 4.h),
                  AppCommonTextField(
                    controller: _occurrencesController,
                    focusNode: _occurrencesFocusNode,
                    labelText: 'Occurrence',
                    hintText: 'e.g. 5',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    enabled: !_endByMode && !widget.readOnly,
                    onChanged: (_) => _notifyChanges(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // region Connected Tab Bar
  // ── Connected Tab Bar for Frequency Selection ──
  Widget _buildTabBar() {
    final selectedIndex = _recurrenceTabs.indexWhere(
      (t) => t.value == _frequency,
    );
    final validIndex = selectedIndex == -1 ? 0 : selectedIndex;

    return AppCommonConnectedTabBar(
      tabs: _recurrenceTabs.map((t) => t.label).toList(),
      selectedIndex: validIndex,
      readOnly: widget.readOnly,
      height: 28.h,
      onTabChanged: (index) {
        final tab = _recurrenceTabs[index];
        setState(() {
          _frequency = tab.value;
          if (tab.value == 'day') _everyWeekday = false;
        });
        _notifyChanges();
      },
    );
  }

  // endregion

  // region Pattern Details
  // ── Pattern details ──
  Widget _buildPatternDetails() {
    if (_frequency == 'day') {
      return _buildDailyPattern();
    } else if (_frequency == 'week') {
      return _buildWeeklyPattern();
    } else if (_frequency == 'month') {
      return _buildMonthlyPattern();
    } else {
      return _buildYearlyPattern();
    }
  }

  // ── Start / End Time Row ──
  Widget _buildStartEndTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            label: 'Start Time',
            time: _startTime,
            focusNode: _startTimeFocusNode,
            onChanged: (t) {
              setState(() => _startTime = t);
              _notifyChanges();
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildTimeField(
            label: 'End Time',
            time: _endTime,
            focusNode: _endTimeFocusNode,
            onChanged: (t) {
              setState(() => _endTime = t);
              _notifyChanges();
            },
          ),
        ),
      ],
    );
  }

  // ── Daily ──
  Widget _buildDailyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Every',
                  style: AppTextStyle.style_12_400(color: AppColors.black),
                ),
                SizedBox(width: 8.w),
                AppCommonTextField(
                  controller: _intervalController,
                  hintText: '1',
                  keyboardType: TextInputType.number,
                  enabled: !_everyWeekday && !widget.readOnly,
                  focusNode: widget.intervalFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _pickStartTimeField(),
                  onChanged: (_) => _notifyChanges(),
                  width: 48.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'day(s)',
                  style: AppTextStyle.style_12_400(color: AppColors.black),
                ),
                SizedBox(width: 12.w),
              ],
            ),
            Focus(
              skipTraversal: true,
              canRequestFocus: false,
              child: InkWell(
                onTap: widget.readOnly
                    ? null
                    : () => setState(() {
                        _everyWeekday = !_everyWeekday;
                        if (_everyWeekday) _intervalController.text = '1';
                        _notifyChanges();
                      }),
                borderRadius: BorderRadius.circular(4.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: Checkbox(
                        value: _everyWeekday,
                        onChanged: widget.readOnly
                            ? null
                            : (v) => setState(() {
                                _everyWeekday = v ?? false;
                                if (_everyWeekday) {
                                  _intervalController.text = '1';
                                }
                                _notifyChanges();
                              }),
                        activeColor: const Color(0xFFF15A24),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Every weekday',
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildStartEndTimeRow(),
      ],
    );
  }

  // ── Weekly ──
  Widget _buildWeeklyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recur every',
              style: AppTextStyle.style_12_400(color: AppColors.black),
            ),
            SizedBox(width: 8.w),
            AppCommonTextField(
              controller: _intervalController,
              hintText: '1',
              keyboardType: TextInputType.number,
              enabled: !widget.readOnly,
              focusNode: widget.intervalFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _pickStartTimeField(),
              onChanged: (_) => _notifyChanges(),
              width: 48.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'week(s) on:',
              style: AppTextStyle.style_12_400(color: AppColors.black),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: _daysOfWeek.map((day) {
            final sel = _selectedDays.contains(day);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: InkWell(
                  onTap: widget.readOnly
                      ? null
                      : () => setState(() {
                          if (sel) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                          _notifyChanges();
                        }),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    height: 26.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFF15A24)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFF15A24)
                            : AppColors.borderColor,
                      ),
                    ),
                    child: Text(
                      day,
                      style: sel
                          ? AppTextStyle.style_11_600(color: AppColors.white)
                          : AppTextStyle.style_11_500(color: AppColors.grey800),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 12.h),
        _buildStartEndTimeRow(),
      ],
    );
  }

  // ── Monthly ──
  Widget _buildMonthlyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day mode ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeRadio(
              'Day',
              _monthlyByDay,
              (v) => setState(() => _monthlyByDay = v),
              width: 52.w,
            ),
            SizedBox(width: 6.w),
            Opacity(
              opacity: _monthlyByDay ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !_monthlyByDay || widget.readOnly,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppCommonTextField(
                      controller: _monthDayController,
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      enabled: _monthlyByDay && !widget.readOnly,
                      focusNode: _monthlyByDay
                          ? widget.intervalFocusNode
                          : null,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      onChanged: (_) => _notifyChanges(),
                      width: 48.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'of every',
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                    ),
                    SizedBox(width: 6.w),
                    AppCommonTextField(
                      controller: _monthIntervalController,
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      enabled: _monthlyByDay && !widget.readOnly,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _pickStartTimeField(),
                      onChanged: (_) => _notifyChanges(),
                      width: 48.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'month(s)',
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── The mode ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildModeRadio(
                  'The',
                  !_monthlyByDay,
                  (v) => setState(() => _monthlyByDay = !v),
                  width: 52.w,
                ),
                SizedBox(width: 6.w),
                Opacity(
                  opacity: !_monthlyByDay ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: _monthlyByDay || widget.readOnly,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropdown<String>(
                          value: _monthOrdinal,
                          items: _ordinals,
                          onChanged: (v) => setState(() => _monthOrdinal = v!),
                          width: 110.w,
                        ),
                        SizedBox(width: 6.w),
                        _buildDropdown<String>(
                          value: _monthWeekday,
                          items: _weekdays,
                          onChanged: (v) => setState(() => _monthWeekday = v!),
                          width: 110.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Opacity(
              opacity: !_monthlyByDay ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: _monthlyByDay || widget.readOnly,
                child: Padding(
                  padding: EdgeInsets.only(left: 58.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'of every',
                        style: AppTextStyle.style_12_400(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      AppCommonTextField(
                        controller: _monthTheDayIntervalController,
                        hintText: '1',
                        keyboardType: TextInputType.number,
                        enabled: !_monthlyByDay && !widget.readOnly,
                        focusNode: !_monthlyByDay
                            ? widget.intervalFocusNode
                            : null,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _pickStartTimeField(),
                        onChanged: (_) => _notifyChanges(),
                        width: 48.w,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'month(s)',
                        style: AppTextStyle.style_12_400(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Yearly ──
  Widget _buildYearlyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recur every',
              style: AppTextStyle.style_12_400(color: AppColors.black),
            ),
            SizedBox(width: 8.w),
            AppCommonTextField(
              controller: _yearlyIntervalController,
              hintText: '1',
              keyboardType: TextInputType.number,
              enabled: !widget.readOnly,
              focusNode: widget.intervalFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _pickStartTimeField(),
              onChanged: (_) => _notifyChanges(),
              width: 48.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'year(s)',
              style: AppTextStyle.style_12_400(color: AppColors.black),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── On mode ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeRadio(
              'On',
              _yearlyByDate,
              (v) => setState(() => _yearlyByDate = v),
              width: 52.w,
            ),
            SizedBox(width: 6.w),
            Opacity(
              opacity: _yearlyByDate ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !_yearlyByDate || widget.readOnly,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdown<String>(
                      value: _yearlyMonth,
                      items: _months,
                      onChanged: (v) => setState(() => _yearlyMonth = v!),
                      width: 110.w,
                    ),
                    SizedBox(width: 6.w),
                    AppCommonTextField(
                      controller: _yearlyDayController,
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      enabled: _yearlyByDate && !widget.readOnly,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _pickStartTimeField(),
                      onChanged: (_) => _notifyChanges(),
                      width: 48.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── The mode ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildModeRadio(
                  'The',
                  !_yearlyByDate,
                  (v) => setState(() => _yearlyByDate = !v),
                  width: 52.w,
                ),
                SizedBox(width: 6.w),
                Opacity(
                  opacity: !_yearlyByDate ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: _yearlyByDate || widget.readOnly,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropdown<String>(
                          value: _yearlyOrdinal,
                          items: _ordinals,
                          onChanged: (v) => setState(() => _yearlyOrdinal = v!),
                          width: 110.w,
                        ),
                        SizedBox(width: 6.w),
                        _buildDropdown<String>(
                          value: _yearlyWeekday,
                          items: _weekdays,
                          onChanged: (v) => setState(() => _yearlyWeekday = v!),
                          width: 110.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Opacity(
              opacity: !_yearlyByDate ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: _yearlyByDate || widget.readOnly,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 52.w,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Text(
                            'of',
                            style: AppTextStyle.style_12_400(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    _buildDropdown<String>(
                      value: _yearlyTheMonth,
                      items: _months,
                      onChanged: (v) => setState(() => _yearlyTheMonth = v!),
                      width: 110.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Reusable: mode radio (Day / The / On) ──
  Widget _buildModeRadio(
    String label,
    bool selected,
    ValueChanged<bool> onChanged, {
    double? width,
  }) {
    final row = GestureDetector(
      onTap: () => onChanged(true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: Radio<bool>(
              value: true,
              // ignore: deprecated_member_use
              groupValue: selected,
              // ignore: deprecated_member_use
              onChanged: (_) => onChanged(true),
              activeColor: const Color(0xFFF15A24),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Opacity(
              opacity: selected ? 1.0 : 0.5,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.style_12_400(color: AppColors.black),
              ),
            ),
          ),
        ],
      ),
    );
    if (width != null) {
      return SizedBox(width: width, child: row);
    }
    return row;
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    double? width,
    String? label,
  }) {
    final dropdown = MultiSelectDropdownWidget<T>(
      label: label,
      selectedValues: {value},
      isSingleSelect: true,
      showSearch: false,
      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(
            e.toString(),
            style: AppTextStyle.style_12_400(color: AppColors.grey900),
          ),
        );
      }).toList(),
      onChanged: (values) {
        if (values.isNotEmpty) {
          onChanged(values.first);
          _notifyChanges();
        }
      },
    );

    if (width != null) {
      return SizedBox(width: width, child: dropdown);
    }
    return dropdown;
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay> onChanged,
    bool isRequired = true,
    FocusNode? focusNode,
  }) {
    final cleanLabel = label.replaceAll(' *', '').replaceAll('*', '').trim();
    final isStart = cleanLabel.toLowerCase().contains('start');
    final controller = isStart ? _startTimeController : _endTimeController;
    final isReadOnly = widget.readOnly;

    if (time != null) {
      final formatted = _formatTimeOfDay(time);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    } else if (controller.text.isNotEmpty) {
      controller.text = '';
    }

    return AppCommonTextField(
      controller: controller,
      labelText: cleanLabel,
      isRequired: isRequired || label.contains('*'),
      hintText: 'Select time',
      readOnly: true,
      enabled: !isReadOnly,
      fillColor: isReadOnly ? const Color(0xFFF1F3F5) : Colors.white,
      focusNode: focusNode,
      onTap: isReadOnly
          ? null
          : () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time ?? TimeOfDay.now(),
                helpText: isStart ? 'Select Start Time' : 'Select End Time',
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: false),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onChanged(picked);
                controller.text = _formatTimeOfDay(picked);
              }
            },
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 6.w),
        child: Icon(
          Icons.access_time_rounded,
          color: AppColors.grey200,
          size: 14.r,
        ),
      ),
      suffixIconConstraints: BoxConstraints(minWidth: 20.w, minHeight: 0),
    );
  }

  // ── Date field powered by AppCommonDateField ──
  Widget _buildDateField({
    required DateTime? date,
    required ValueChanged<DateTime> onSelected,
    bool enabled = true,
    bool readOnly = false,
    String? label,
    bool isRequired = false,
    TextEditingController? customController,
  }) {
    final cleanLabel = label?.replaceAll(' *', '').replaceAll('*', '').trim();
    final isStart =
        cleanLabel != null && cleanLabel.toLowerCase().contains('start');
    final controller =
        customController ??
        (isStart ? _startDateController : _endByDateController);
    final isFieldReadOnly = widget.readOnly || !enabled || readOnly;

    return AppCommonDateField(
      controller: controller,
      labelText: cleanLabel,
      selectedDate: date,
      isRequired: isRequired || (label != null && label.contains('*')),
      hintText: 'Select date',
      enabled: !isFieldReadOnly,
      readOnly: isFieldReadOnly,
      dateFormatter: (d) => AppDateUtils.formatToApiDate(d.toIso8601String()),
      onDateSelected: onSelected,
    );
  }

  // ── Radio row for End by / End after ──
  Widget _buildRadioRow(String label, bool value) {
    return GestureDetector(
      onTap: () => setState(() => _endByMode = value),
      child: Row(
        children: [
          SizedBox(
            width: 22.r,
            height: 22.r,
            child: Radio<bool>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: _endByMode,
              // ignore: deprecated_member_use
              onChanged: (v) => setState(() => _endByMode = v ?? true),
              activeColor: const Color(0xFFF15A24),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: 6.w),
          Text(label, style: AppTextStyle.style_12_400(color: AppColors.black)),
        ],
      ),
    );
  }
}
// endregion
