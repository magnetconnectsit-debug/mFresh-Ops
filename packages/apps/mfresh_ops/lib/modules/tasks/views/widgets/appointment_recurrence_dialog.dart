import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class RecurrenceData {
  final String frequency; // 'day', 'week', 'month', 'year'
  final int repeatInterval;
  final String startTime;
  final String endTime;
  final String? selectedDays; // e.g. "Wed,Sat"
  final int? occurrences;
  final DateTime startDate;
  final DateTime? endByDate;

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

  RecurrenceData({
    required this.frequency,
    required this.repeatInterval,
    required this.startTime,
    required this.endTime,
    this.selectedDays,
    this.occurrences,
    required this.startDate,
    this.endByDate,
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
}

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
  State<AppointmentRecurrenceDialog> createState() => _AppointmentRecurrenceDialogState();
}

class _AppointmentRecurrenceDialogState extends State<AppointmentRecurrenceDialog> {
  late String _frequency;
  late int _repeatInterval;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  // Weekly selection
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};

  // Daily selection
  bool _everyWeekday = false;

  // Monthly selection
  bool _monthlyByDay = true; // true = Day mode, false = The mode
  String _monthOrdinal = 'First';
  String _monthWeekday = 'Monday';
  final TextEditingController _monthDayController = TextEditingController(text: '1');
  final TextEditingController _monthIntervalController = TextEditingController(text: '1');
  final TextEditingController _monthTheDayIntervalController = TextEditingController(text: '1');

  // Yearly selection
  bool _yearlyByDate = true; // true = On mode, false = The mode
  String _yearlyMonth = 'January';
  String _yearlyOrdinal = 'First';
  String _yearlyWeekday = 'Monday';
  String _yearlyTheMonth = 'January';
  final TextEditingController _yearlyDayController = TextEditingController(text: '1');
  final TextEditingController _yearlyIntervalController = TextEditingController(text: '1');

  static const _ordinals = ['First', 'Second', 'Third', 'Fourth', 'Last'];
  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  // Range of Recurrence
  late DateTime _startDate;
  DateTime? _endByDate;
  int? _occurrences;
  bool _endByMode = true;

  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _occurrencesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _startDate = widget.defaultStartDate ?? widget.initialData?.startDate ?? DateTime.now();
    _endByDate = widget.defaultEndDate ?? widget.initialData?.endByDate ?? DateTime.now().add(const Duration(days: 30));

    if (widget.defaultStartTime != null) {
      _startTime = widget.defaultStartTime!;
    } else if (widget.initialData != null) {
      _startTime = _parseTime(widget.initialData!.startTime);
    } else {
      final now = TimeOfDay.now();
      final roundedMin = now.minute < 30 ? 0 : 30;
      _startTime = TimeOfDay(hour: now.hour, minute: roundedMin);
    }

    if (widget.defaultEndTime != null) {
      _endTime = widget.defaultEndTime!;
    } else if (widget.initialData != null) {
      _endTime = _parseTime(widget.initialData!.endTime);
    } else {
      final roundedMin = _startTime.minute;
      final endMin = roundedMin + 30;
      _endTime = TimeOfDay(hour: endMin >= 60 ? (_startTime.hour + 1) % 24 : _startTime.hour, minute: endMin % 60);
    }

    if (widget.initialData != null) {
      final data = widget.initialData!;
      _frequency = data.frequency;
      _repeatInterval = data.repeatInterval;
      _selectedDays.addAll(data.selectedDays?.split(',') ?? []);
      _occurrences = data.occurrences;
      _endByMode = data.endByDate != null || data.occurrences == null;
      _everyWeekday = data.frequency == 'day' && data.repeatInterval == 1 && data.selectedDays == 'Mon,Tue,Wed,Thu,Fri';
      
      // Monthly restore
      if (data.monthlyMode != null) {
        _monthlyByDay = data.monthlyMode == 'day';
        _monthDayController.text = (data.monthDay ?? 1).toString();
        _monthIntervalController.text = (data.monthInterval ?? 1).toString();
        _monthTheDayIntervalController.text = (data.monthInterval ?? 1).toString();
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
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _occurrencesController.dispose();
    _monthDayController.dispose();
    _monthIntervalController.dispose();
    _monthTheDayIntervalController.dispose();
    _yearlyDayController.dispose();
    _yearlyIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
      backgroundColor: AppColors.white,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
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
                    child: Icon(Icons.close, color: AppColors.black, size: 18.r),
                  ),
                ],
              ),
            ),
            Divider(height: 16.h, color: const Color(0xffE9ECEF)),

            // ── Scrollable Body ──
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time row – custom dropdowns
                    Row(
                      children: [
                        Expanded(child: _buildStartTimeDropdown()),
                        SizedBox(width: 8.w),
                        Expanded(child: _buildEndTimeDropdown()),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Recurrence pattern label
                    Text('Recurrence pattern', style: AppTextStyle.style_12_600(color: AppColors.black)),
                    SizedBox(height: 4.h),

                    // Frequency options grouped in a bordered box
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffDEE2E6)),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFrequencyRow('Daily', 'day', isFirst: true),
                          _divider(),
                          _buildFrequencyRow('Weekly', 'week'),
                          _divider(),
                          _buildFrequencyRow('Monthly', 'month'),
                          _divider(),
                          _buildFrequencyRow('Yearly', 'year', isLast: true),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Pattern details
                    _buildPatternDetails(),
                    SizedBox(height: 10.h),

                    Divider(height: 1, color: const Color(0xffDEE2E6)),
                    SizedBox(height: 10.h),

                    // ── Range of recurrence ──
                    Text('Range of recurrence', style: AppTextStyle.style_12_600(color: AppColors.black)),
                    SizedBox(height: 4.h),

                    Text('Start', style: AppTextStyle.style_11_500(color: AppColors.black)),
                    SizedBox(height: 4.h),
                    _buildDateField(_startDate, (d) => setState(() => _startDate = d)),
                    SizedBox(height: 8.h),

                    _buildRadioRow('End by', true),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: _buildDateField(
                        _endByDate ?? DateTime.now(),
                        (d) { if (_endByMode) setState(() => _endByDate = d); },
                        enabled: _endByMode,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    _buildRadioRow('End after', false),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: SizedBox(
                        height: 30.h,
                        child: TextField(
                          controller: _occurrencesController,
                          keyboardType: TextInputType.number,
                          enabled: !_endByMode,
                          decoration: InputDecoration(
                            hintText: 'occurrence',
                            hintStyle: AppTextStyle.style_11_400(color: AppColors.grey200),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            border: _fieldBorder(),
                            enabledBorder: _fieldBorder(),
                            disabledBorder: _fieldBorder(color: const Color(0xffEEEEEE)),
                          ),
                          style: AppTextStyle.style_11_400(color: AppColors.grey900),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff5D3FD3),
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            elevation: 0,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _onSave,
                          child: Text('save', style: AppTextStyle.style_11_700(color: Colors.white)),
                        ),
                        SizedBox(width: 8.w),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xffDEE2E6)),
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: AppTextStyle.style_11_500(color: AppColors.black)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── helpers ───────────────────────

  void _onSave() {
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final occurrences = _endByMode ? null : (int.tryParse(_occurrencesController.text) ?? 5);
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
      // Monthly
      monthlyMode: _frequency == 'month' ? (_monthlyByDay ? 'day' : 'the') : null,
      monthDay: _frequency == 'month' ? (int.tryParse(_monthDayController.text) ?? 1) : null,
      monthInterval: _frequency == 'month'
          ? (int.tryParse(_monthlyByDay ? _monthIntervalController.text : _monthTheDayIntervalController.text) ?? 1)
          : null,
      monthOrdinal: _frequency == 'month' && !_monthlyByDay ? _monthOrdinal : null,
      monthWeekday: _frequency == 'month' && !_monthlyByDay ? _monthWeekday : null,
      // Yearly
      yearlyMode: _frequency == 'year' ? (_yearlyByDate ? 'on' : 'the') : null,
      yearlyMonth: _frequency == 'year' && _yearlyByDate ? _yearlyMonth : null,
      yearlyDay: _frequency == 'year' && _yearlyByDate ? (int.tryParse(_yearlyDayController.text) ?? 1) : null,
      yearlyInterval: _frequency == 'year' ? (int.tryParse(_yearlyIntervalController.text) ?? 1) : null,
      yearlyOrdinal: _frequency == 'year' && !_yearlyByDate ? _yearlyOrdinal : null,
      yearlyWeekday: _frequency == 'year' && !_yearlyByDate ? _yearlyWeekday : null,
      yearlyTheMonth: _frequency == 'year' && !_yearlyByDate ? _yearlyTheMonth : null,
    );
    Get.back(result: data);
  }

  Widget _divider() => const Divider(height: 0, thickness: 1, color: Color(0xffDEE2E6));

  OutlineInputBorder _fieldBorder({Color color = const Color(0xffDEE2E6)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.r),
      borderSide: BorderSide(color: color),
    );
  }

  // ── Frequency row inside the bordered box ──
  Widget _buildFrequencyRow(String label, String value, {bool isFirst = false, bool isLast = false}) {
    return InkWell(
      onTap: () => setState(() {
        _frequency = value;
        if (value == 'day') _everyWeekday = false;
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          children: [
            SizedBox(
              width: 20.r,
              height: 20.r,
              child: Radio<String>(
                value: value,
                groupValue: _frequency,
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _frequency = v;
                      if (v == 'day') {
                        _everyWeekday = false;
                      }
                    });
                  }
                },
                activeColor: const Color(0xff5D3FD3),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: 8.w),
            Text(label, style: AppTextStyle.style_12_400(color: AppColors.black)),
          ],
        ),
      ),
    );
  }

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

  // ── Daily ──
  Widget _buildDailyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Every ', style: AppTextStyle.style_12_400(color: AppColors.black)),
            _buildSmallNumberField(controller: _intervalController, enabled: !_everyWeekday),
            Text(' day(s)', style: AppTextStyle.style_12_400(color: AppColors.black)),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            SizedBox(
              width: 22.r,
              height: 22.r,
              child: Checkbox(
                value: _everyWeekday,
                onChanged: (v) => setState(() {
                  _everyWeekday = v ?? false;
                  if (_everyWeekday) _intervalController.text = '1';
                }),
                activeColor: const Color(0xff5D3FD3),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: Color(0xffCED4DA)),
              ),
            ),
            SizedBox(width: 6.w),
            Text('Every weekday', style: AppTextStyle.style_12_400(color: AppColors.black)),
          ],
        ),
      ],
    );
  }

  // ── Weekly ──
  Widget _buildWeeklyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recur Every ', style: AppTextStyle.style_12_400(color: AppColors.black)),
            _buildSmallNumberField(controller: _intervalController),
            Text(' week(s) on:', style: AppTextStyle.style_12_400(color: AppColors.black)),
          ],
        ),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 4.w,
          runSpacing: 4.h,
          children: _daysOfWeek.map((day) {
            final sel = _selectedDays.contains(day);
            return ChoiceChip(
              label: Text(
                day,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? const Color(0xff0D6EFD) : AppColors.black,
                ),
              ),
              selected: sel,
              showCheckmark: false,
              selectedColor: const Color(0xffE6F0FF),
              backgroundColor: AppColors.grey50,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onSelected: (v) => setState(() => v ? _selectedDays.add(day) : _selectedDays.remove(day)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recur every', style: AppTextStyle.style_12_600(color: AppColors.black)),
        SizedBox(height: 6.h),

        // ── Day mode ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeRadio('Day', _monthlyByDay, (v) => setState(() => _monthlyByDay = v)),
            SizedBox(width: 4.w),
            Expanded(
              child: Opacity(
                opacity: _monthlyByDay ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: !_monthlyByDay,
                  child: Row(
                    children: [
                      _buildSmallNumberField(controller: _monthDayController),
                      SizedBox(width: 4.w),
                      Text('of every ', style: AppTextStyle.style_12_400(color: AppColors.black)),
                      _buildSmallNumberField(controller: _monthIntervalController),
                      SizedBox(width: 4.w),
                      Text('month(s)', style: AppTextStyle.style_12_400(color: AppColors.black)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── The mode ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: _buildModeRadio('The', !_monthlyByDay, (v) => setState(() => _monthlyByDay = !v)),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Opacity(
                opacity: !_monthlyByDay ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: _monthlyByDay,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDropdown<String>(
                            value: _monthOrdinal,
                            items: _ordinals,
                            onChanged: (v) => setState(() => _monthOrdinal = v!),
                            width: 60.w,
                          ),
                          SizedBox(width: 4.w),
                          _buildDropdown<String>(
                            value: _monthWeekday,
                            items: _weekdays,
                            onChanged: (v) => setState(() => _monthWeekday = v!),
                            width: 80.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('of every ', style: AppTextStyle.style_12_400(color: AppColors.black)),
                          _buildSmallNumberField(controller: _monthTheDayIntervalController),
                          SizedBox(width: 4.w),
                          Text('month(s)', style: AppTextStyle.style_12_400(color: AppColors.black)),
                        ],
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
        Text('Recur every', style: AppTextStyle.style_12_600(color: AppColors.black)),
        SizedBox(height: 6.h),
        Row(
          children: [
            _buildSmallNumberField(controller: _yearlyIntervalController),
            SizedBox(width: 6.w),
            Text('year(s)', style: AppTextStyle.style_12_400(color: AppColors.black)),
          ],
        ),
        SizedBox(height: 8.h),

        // ── On mode ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeRadio('On', _yearlyByDate, (v) => setState(() => _yearlyByDate = v)),
            SizedBox(width: 4.w),
            Expanded(
              child: Opacity(
                opacity: _yearlyByDate ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: !_yearlyByDate,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: [
                      _buildDropdown<String>(
                        value: _yearlyMonth,
                        items: _months,
                        onChanged: (v) => setState(() => _yearlyMonth = v!),
                        width: 75.w,
                      ),
                      _buildSmallNumberField(controller: _yearlyDayController),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),

        // ── The mode ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeRadio('The', !_yearlyByDate, (v) => setState(() => _yearlyByDate = !v)),
            SizedBox(width: 4.w),
            Expanded(
              child: Opacity(
                opacity: !_yearlyByDate ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: _yearlyByDate,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: [
                      _buildDropdown<String>(
                        value: _yearlyOrdinal,
                        items: _ordinals,
                        onChanged: (v) => setState(() => _yearlyOrdinal = v!),
                        width: 60.w,
                      ),
                      _buildDropdown<String>(
                        value: _yearlyWeekday,
                        items: _weekdays,
                        onChanged: (v) => setState(() => _yearlyWeekday = v!),
                        width: 80.w,
                      ),
                      Text('of ', style: AppTextStyle.style_12_400(color: AppColors.black)),
                      _buildDropdown<String>(
                        value: _yearlyTheMonth,
                        items: _months,
                        onChanged: (v) => setState(() => _yearlyTheMonth = v!),
                        width: 75.w,
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

  // ── Reusable: mode radio (Day / The / On) ──
  Widget _buildModeRadio(String label, bool selected, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22.r,
            height: 22.r,
            child: Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onChanged(true),
              activeColor: const Color(0xff5D3FD3),
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

  // ── Small dropdown ──
  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    double? width,
  }) {
    return Container(
      width: width,
      height: 30.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffDEE2E6)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16.r, color: AppColors.grey400),
          style: AppTextStyle.style_11_400(color: AppColors.black),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(e.toString(), style: AppTextStyle.style_11_400(color: AppColors.black)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Small number input ──
  Widget _buildSmallNumberField({TextEditingController? controller, bool enabled = true}) {
    return Container(
      width: 50.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: enabled ? Colors.transparent : const Color(0xffEEEEEE),
        border: Border.all(color: const Color(0xffDEE2E6)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller ?? _intervalController,
        keyboardType: TextInputType.number,
        enabled: enabled,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  // ── Generate 30-min interval time slots ──
  List<TimeOfDay> _generate30MinSlots() {
    final slots = <TimeOfDay>[];
    for (int h = 0; h < 24; h++) {
      slots.add(TimeOfDay(hour: h, minute: 0));
      slots.add(TimeOfDay(hour: h, minute: 30));
    }
    return slots;
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return '';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '($mins min)';
    if (mins == 0) return '($hours hr)';
    return '($hours hr $mins min)';
  }

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  // ── Start time dropdown ──
  Widget _buildStartTimeDropdown() {
    final slots = _generate30MinSlots();
    return PopupMenuButton<TimeOfDay>(
      onSelected: (t) => setState(() => _startTime = t),
      constraints: BoxConstraints(maxHeight: 250.h),
      position: PopupMenuPosition.under,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      itemBuilder: (_) => slots.map((slot) {
        return PopupMenuItem<TimeOfDay>(
          value: slot,
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            _formatTimeOfDay(slot),
            style: AppTextStyle.style_12_400(
              color: slot == _startTime ? const Color(0xff5D3FD3) : AppColors.black,
            ),
          ),
        );
      }).toList(),
      child: Container(
        height: 28.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: const Color(0xffDEE2E6)),
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Text(
          _formatTimeOfDay(_startTime),
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
        ),
      ),
    );
  }

  // ── End time dropdown (shows duration relative to start) ──
  Widget _buildEndTimeDropdown() {
    final slots = _generate30MinSlots();
    final startMins = _timeToMinutes(_startTime);
    return PopupMenuButton<TimeOfDay>(
      onSelected: (t) => setState(() => _endTime = t),
      constraints: BoxConstraints(maxHeight: 250.h),
      position: PopupMenuPosition.under,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      itemBuilder: (_) => slots.map((slot) {
        final slotMins = _timeToMinutes(slot);
        int diff = slotMins - startMins;
        if (diff <= 0) diff += 24 * 60;
        final durationLabel = _formatDuration(diff);
        final isSelected = slot == _endTime;
        return PopupMenuItem<TimeOfDay>(
          value: slot,
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _formatTimeOfDay(slot),
                  style: AppTextStyle.style_12_400(
                    color: isSelected ? const Color(0xff5D3FD3) : AppColors.black,
                  ),
                ),
                if (durationLabel.isNotEmpty)
                  TextSpan(
                    text: ' $durationLabel',
                    style: AppTextStyle.style_10_400(
                      color: AppColors.grey200,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      child: Container(
        height: 28.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: const Color(0xffDEE2E6)),
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Text(
          _formatTimeOfDay(_endTime),
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
        ),
      ),
    );
  }

  // ── Date field ──
  Widget _buildDateField(DateTime date, Function(DateTime) onSelected, {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selected != null) onSelected(selected);
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          height: 30.h,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffDEE2E6)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          alignment: Alignment.centerLeft,
          child: Text(
            AppDateUtils.formatToOrdinalDate(date.toIso8601String()),
            style: AppTextStyle.style_11_400(color: AppColors.grey900),
          ),
        ),
      ),
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
              groupValue: _endByMode,
              onChanged: (v) => setState(() => _endByMode = v ?? true),
              activeColor: const Color(0xff5D3FD3),
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
