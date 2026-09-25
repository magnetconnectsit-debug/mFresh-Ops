import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/create_payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class ReminderSetupDialog extends StatefulWidget {
  final CreatePaymentReminderController controller;

  const ReminderSetupDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    CreatePaymentReminderController controller,
  ) async {
    await Get.dialog(ReminderSetupDialog(controller: controller));
  }

  @override
  State<ReminderSetupDialog> createState() => _ReminderSetupDialogState();
}

class _ReminderSetupDialogState extends State<ReminderSetupDialog> {
  late bool tempWhatsApp;
  late bool tempApp;
  TimeOfDay? tempTime;
  late bool tempIsRecurring;
  RecurrenceData? tempRecurrenceData;

  /// Recurrence Fields
  late String _frequency;
  late int _repeatInterval;

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

  // Monthly
  bool _monthlyByDay = true;
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

  // Yearly
  bool _yearlyByDate = true;
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

  late DateTime _startDate;
  DateTime? _endByDate;
  int? _occurrences;
  bool _endByMode = true;

  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _occurrencesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tempWhatsApp = widget.controller.whatsappNotification.value;
    tempApp = widget.controller.appNotification.value;
    tempTime = widget.controller.selectedReminderTime.value;
    tempIsRecurring = widget.controller.isRecurring.value;
    tempRecurrenceData = widget.controller.recurrenceData.value;

    final data = tempRecurrenceData;
    _startDate =
        widget.controller.selectedReminderSetupDate.value ??
        data?.startDate ??
        DateTime.now();
    _endByDate = data?.endByDate;

    if (data != null) {
      _frequency = data.frequency;
      _repeatInterval = data.repeatInterval;
      _selectedDays.addAll(data.selectedDays?.split(',') ?? []);
      _occurrences = data.occurrences;
      _endByMode = data.endByDate != null || data.occurrences == null;

      if (data.monthlyMode != null) {
        _monthlyByDay = data.monthlyMode == 'day';
        _monthDayController.text = (data.monthDay ?? 1).toString();
        _monthIntervalController.text = (data.monthInterval ?? 1).toString();
        _monthTheDayIntervalController.text = (data.monthInterval ?? 1)
            .toString();
        _monthOrdinal = data.monthOrdinal ?? 'First';
        _monthWeekday = data.monthWeekday ?? 'Monday';
      }
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

  String _format12HourTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  RecurrenceData _buildRecurrenceData() {
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final occurrences = _endByMode
        ? null
        : (int.tryParse(_occurrencesController.text) ?? 5);
    final selectedDaysStr = _frequency == 'week'
        ? (_selectedDays.isEmpty ? null : _selectedDays.join(','))
        : null;

    final formattedTimeStr = tempTime != null ? _format12HourTime(tempTime!) : '';

    return RecurrenceData(
      frequency: _frequency,
      repeatInterval: interval,
      startTime: formattedTimeStr,
      endTime: formattedTimeStr,
      selectedDays: selectedDaysStr,
      occurrences: occurrences,
      startDate: _startDate,
      endByDate: _endByMode ? _endByDate : null,
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
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return SizedBox(
      width: 38.w,
      height: 22.h,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFFF2562B),
          inactiveTrackColor: AppColors.grey100,
          inactiveThumbColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  void _onApply() {
    if (tempIsRecurring) {
      if (_endByMode && _endByDate == null) {
        AppCommonToastMessage.show(
          message: 'Please select an end date for recurrence',
          type: ToastType.error,
        );
        return;
      }
      final rec = _buildRecurrenceData();
      widget.controller.isRecurring.value = true;
      widget.controller.recurrenceData.value = rec;
      widget.controller.selectedReminderSetupDate.value = rec.startDate;
    } else {
      widget.controller.isRecurring.value = false;
      widget.controller.recurrenceData.value = null;
      widget.controller.selectedReminderSetupDate.value = null;
    }

    widget.controller.whatsappNotification.value = tempWhatsApp;
    widget.controller.appNotification.value = tempApp;
    widget.controller.selectedReminderTime.value = tempTime;

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 440.w,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reminder Setup',
                  style: AppTextStyle.style_16_700(color: AppColors.black),
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    color: AppColors.grey700,
                    size: 20.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 12.h),

            // ── Scrollable Body ──────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Notification Type ─────────────────────────────────────
                    Text(
                      'Notification Type',
                      style: AppTextStyle.style_12_600(color: AppColors.black),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => tempWhatsApp = !tempWhatsApp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: Checkbox(
                                  value: tempWhatsApp,
                                  onChanged: (v) =>
                                      setState(() => tempWhatsApp = v ?? false),
                                  activeColor: const Color(0xFFF2562B),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Color(0xFF25D366),
                                size: 16,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'WhatsApp',
                                style: AppTextStyle.style_12_500(
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),
                        InkWell(
                          onTap: () => setState(() => tempApp = !tempApp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: Checkbox(
                                  value: tempApp,
                                  onChanged: (v) =>
                                      setState(() => tempApp = v ?? false),
                                  activeColor: const Color(0xFFF2562B),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.notifications,
                                color: AppColors.black,
                                size: 16.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'App / Text',
                                style: AppTextStyle.style_12_500(
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // ── Reminder Time ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reminder Time',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: tempTime ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: false),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() => tempTime = time);
                            }
                          },
                          child: Container(
                            width: 130.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              _format12HourTime(tempTime),
                              style: tempTime != null
                                  ? AppTextStyle.style_12_400(
                                      color: AppColors.grey900,
                                    )
                                  : AppTextStyle.style_12_400(
                                      color: AppColors.grey300,
                                    ).copyWith(fontSize: 11.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    SizedBox(height: 10.h),

                    // ── Recurring Reminder Switch ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Recurring Reminder',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        _buildSwitch(tempIsRecurring, (val) {
                          setState(() {
                            tempIsRecurring = val;
                          });
                        }),
                      ],
                    ),

                    // ── Expanded Recurrence Setup Section ─────────────────────
                    if (tempIsRecurring) ...[
                      SizedBox(height: 10.h),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      SizedBox(height: 10.h),

                      Text(
                        'Recurrence Pattern',
                        style: AppTextStyle.style_12_600(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Frequency Selection Box (Simple Compact Control with Dividers)
                      Container(
                        height: 26.h,
                        padding: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildFrequencyTab('Daily', 'day')),
                            Container(
                              width: 1.w,
                              height: 14.h,
                              color: const Color(0xFFD1D5DB),
                            ),
                            Expanded(
                              child: _buildFrequencyTab('Weekly', 'week'),
                            ),
                            Container(
                              width: 1.w,
                              height: 14.h,
                              color: const Color(0xFFD1D5DB),
                            ),
                            Expanded(
                              child: _buildFrequencyTab('Monthly', 'month'),
                            ),
                            Container(
                              width: 1.w,
                              height: 14.h,
                              color: const Color(0xFFD1D5DB),
                            ),
                            Expanded(
                              child: _buildFrequencyTab('Yearly', 'year'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Pattern details
                      _buildPatternDetails(),
                      SizedBox(height: 12.h),
                      const Divider(height: 1, color: Color(0xffDEE2E6)),
                      SizedBox(height: 10.h),

                      // Range of Recurrence
                      Text(
                        'Range of Recurrence',
                        style: AppTextStyle.style_12_600(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      Text(
                        'Start',
                        style: AppTextStyle.style_11_500(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _buildDateField(
                        _startDate,
                        (d) => setState(() => _startDate = d),
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
                                _buildDateField(_endByDate, (d) {
                                  if (_endByMode)
                                    setState(() => _endByDate = d);
                                }, enabled: _endByMode),
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
                                _buildOccurrencesField(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // ── Action Buttons ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppCommonButton(
                  text: 'Cancel',
                  variant: ButtonVariant.outline,
                  isSmall: true,
                  height: 32.h,
                  width: 80.w,
                  onPressed: () => Get.back(),
                ),
                SizedBox(width: 10.w),
                AppCommonButton(
                  text: 'Apply',
                  variant: ButtonVariant.primary,
                  isSmall: true,
                  height: 32.h,
                  width: 90.w,
                  onPressed: _onApply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────── Helpers ──────────────────────────

  OutlineInputBorder _fieldBorder({Color color = const Color(0xffDEE2E6)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.r),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildFrequencyTab(String label, String value) {
    final isSelected = _frequency == value;
    return InkWell(
      onTap: () => setState(() {
        _frequency = value;
      }),
      borderRadius: BorderRadius.circular(3.r),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2562B) : Colors.transparent,
          borderRadius: BorderRadius.circular(3.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

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

  Widget _buildDailyPattern() {
    return Row(
      children: [
        Text(
          'Every ',
          style: AppTextStyle.style_12_400(color: AppColors.black),
        ),
        _buildSmallNumberField(controller: _intervalController, enabled: true),
        Text(
          ' day(s)',
          style: AppTextStyle.style_12_400(color: AppColors.black),
        ),
      ],
    );
  }

  Widget _buildWeeklyPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recur Every ',
              style: AppTextStyle.style_12_400(color: AppColors.black),
            ),
            _buildSmallNumberField(controller: _intervalController),
            Text(
              ' week(s) on:',
              style: AppTextStyle.style_12_400(color: AppColors.black),
            ),
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
                  color: sel ? const Color(0xFFF2562B) : AppColors.black,
                ),
              ),
              selected: sel,
              showCheckmark: false,
              selectedColor: const Color(0xFFFFEBE5),
              backgroundColor: AppColors.grey50,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onSelected: (v) => setState(
                () => v ? _selectedDays.add(day) : _selectedDays.remove(day),
              ),
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
        Text(
          'Recur every',
          style: AppTextStyle.style_12_600(color: AppColors.black),
        ),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildModeRadio(
              'Day',
              _monthlyByDay,
              (v) => setState(() => _monthlyByDay = v),
            ),
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
                      Text(
                        'of every ',
                        style: AppTextStyle.style_12_400(
                          color: AppColors.black,
                        ),
                      ),
                      _buildSmallNumberField(
                        controller: _monthIntervalController,
                      ),
                      SizedBox(width: 4.w),
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
        SizedBox(height: 10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: _buildModeRadio(
                'The',
                !_monthlyByDay,
                (v) => setState(() => _monthlyByDay = !v),
              ),
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
                            onChanged: (v) =>
                                setState(() => _monthOrdinal = v!),
                            width: 60.w,
                          ),
                          SizedBox(width: 4.w),
                          _buildDropdown<String>(
                            value: _monthWeekday,
                            items: _weekdays,
                            onChanged: (v) =>
                                setState(() => _monthWeekday = v!),
                            width: 80.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'of every ',
                            style: AppTextStyle.style_12_400(
                              color: AppColors.black,
                            ),
                          ),
                          _buildSmallNumberField(
                            controller: _monthTheDayIntervalController,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'month(s)',
                            style: AppTextStyle.style_12_400(
                              color: AppColors.black,
                            ),
                          ),
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

  Widget _buildYearlyPattern() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Recur every ',
          style: AppTextStyle.style_12_400(color: AppColors.black),
        ),
        _buildSmallNumberField(controller: _yearlyIntervalController),
        SizedBox(width: 4.w),
        Text(
          'year(s) on ',
          style: AppTextStyle.style_12_400(color: AppColors.black),
        ),
        _buildDropdown<String>(
          value: _yearlyMonth,
          items: _months,
          onChanged: (v) => setState(() => _yearlyMonth = v!),
          width: 80.w,
        ),
        SizedBox(width: 4.w),
        _buildSmallNumberField(controller: _yearlyDayController),
      ],
    );
  }

  Widget _buildModeRadio(
    String label,
    bool selected,
    ValueChanged<bool> onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.r,
            height: 14.r,
            child: Transform.scale(
              scale: 0.75,
              child: Radio<bool>(
                value: true,
                groupValue: selected,
                onChanged: (_) => onChanged(true),
                activeColor: const Color(0xFFF2562B),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyle.style_11_400(color: AppColors.black)),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    double? width,
  }) {
    return Container(
      width: width,
      height: 26.h,
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
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 14.r,
            color: AppColors.grey400,
          ),
          style: AppTextStyle.style_11_400(color: AppColors.black),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(
                e.toString(),
                style: AppTextStyle.style_11_400(color: AppColors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSmallNumberField({
    TextEditingController? controller,
    bool enabled = true,
  }) {
    return Container(
      width: 40.w,
      height: 26.h,
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
        style: AppTextStyle.style_11_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildDateField(
    DateTime? date,
    Function(DateTime) onSelected, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final rawInitial = date ?? today;
              final initialDate = rawInitial.isBefore(today) ? today : rawInitial;
              final selected = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: today,
                lastDate: DateTime(2100),
              );
              if (selected != null) onSelected(selected);
            }
          : null,
      child: Container(
        height: 26.h,
        decoration: BoxDecoration(
          color: enabled ? Colors.transparent : const Color(0xffF9FAFB),
          border: Border.all(
            color: enabled ? const Color(0xffDEE2E6) : const Color(0xffE5E7EB),
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.centerLeft,
        child: Text(
          date != null
              ? AppDateUtils.formatToOrdinalDate(date.toIso8601String())
              : 'Select date',
          style: AppTextStyle.style_11_400(
            color: enabled
                ? (date != null ? AppColors.grey900 : AppColors.grey200)
                : AppColors.grey200,
          ),
        ),
      ),
    );
  }

  Widget _buildOccurrencesField() {
    final enabled = !_endByMode;
    return Container(
      height: 26.h,
      decoration: BoxDecoration(
        color: enabled ? Colors.transparent : const Color(0xffF9FAFB),
        border: Border.all(
          color: enabled ? const Color(0xffDEE2E6) : const Color(0xffE5E7EB),
        ),
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _occurrencesController,
        keyboardType: TextInputType.number,
        enabled: enabled,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'occurrences',
          hintStyle: AppTextStyle.style_11_400(color: AppColors.grey200),
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: AppTextStyle.style_11_400(
          color: enabled ? AppColors.grey900 : AppColors.grey200,
        ),
      ),
    );
  }

  Widget _buildRadioRow(String label, bool value) {
    return GestureDetector(
      onTap: () => setState(() => _endByMode = value),
      child: Row(
        children: [
          SizedBox(
            width: 14.r,
            height: 14.r,
            child: Transform.scale(
              scale: 0.75,
              child: Radio<bool>(
                value: value,
                groupValue: _endByMode,
                onChanged: (v) => setState(() => _endByMode = v ?? true),
                activeColor: const Color(0xFFF2562B),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyle.style_11_500(color: AppColors.black)),
        ],
      ),
    );
  }
}
