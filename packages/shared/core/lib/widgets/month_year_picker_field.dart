import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

/// A tap-to-open month-year picker styled identically to
/// [MultiSelectDropdownWidget] (InputDecorator + floating label).
/// Stores value as 'MMM-yyyy' (e.g. 'Jun-2026').
class MonthYearPickerField extends StatelessWidget {
  const MonthYearPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Select Month',
    this.showFloatingLabel = true,
  });

  /// Currently selected value in 'MMM-yyyy' format, or null if none.
  final String? value;

  /// Called with a 'MMM-yyyy' string when the user picks a month,
  /// or null when they clear the selection.
  final ValueChanged<String?> onChanged;

  final String label;
  final bool showFloatingLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: showFloatingLabel ? label : null,
          floatingLabelBehavior: showFloatingLabel ? FloatingLabelBehavior.always : FloatingLabelBehavior.never,
          labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
          isDense: true,
          contentPadding:
              showFloatingLabel ? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h) : EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide:
                BorderSide(color: AppColors.borderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide:
                BorderSide(color: AppColors.borderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide:
                BorderSide(color: AppColors.borderColor, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value != null ? _displayLabel(value!) : label,
                style: value != null
                    ? AppTextStyle.style_12_400(color: AppColors.grey900)
                    : AppTextStyle.style_12_400(color: AppColors.grey300),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close,
                    size: 14.r, color: AppColors.grey300),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey300, size: 16.r),
          ],
        ),
      ),
    );
  }

  /// Shows 'Jun 2026' in the field.
  String _displayLabel(String v) {
    try {
      final d = DateFormat('MMM-yyyy').parse(v);
      return DateFormat('MMM yyyy').format(d);
    } catch (_) {
      return v;
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    int pickerYear = DateTime.now().year;
    if (value != null) {
      try {
        pickerYear = DateFormat('MMM-yyyy').parse(value!).year;
      } catch (_) {}
    }

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _MonthYearPickerDialog(initialYear: pickerYear),
    );

    if (result != null) onChanged(result);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({required this.initialYear});
  final int initialYear;

  @override
  State<_MonthYearPickerDialog> createState() =>
      _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState
    extends State<_MonthYearPickerDialog> {
  late int _year;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    size: 16.r, color: AppColors.collectionHeader),
                SizedBox(width: 6.w),
                Text(
                  'Select Month',
                  style: AppTextStyle.style_14_600(
                      color: AppColors.collectionHeader),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close,
                      size: 16.r, color: AppColors.grey300),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.borderColor),
            SizedBox(height: 12.h),

            // ── Year navigation ───────────────────────────────────────
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.collectionHeader
                    .withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _YearArrow(
                    icon: Icons.chevron_left,
                    onTap: () => setState(() => _year--),
                  ),
                  Text(
                    _year.toString(),
                    style: AppTextStyle.style_14_600(
                        color: AppColors.collectionHeader),
                  ),
                  _YearArrow(
                    icon: Icons.chevron_right,
                    onTap: () => setState(() => _year++),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // ── Month grid ────────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                mainAxisExtent: 34.h,
              ),
              itemCount: _months.length,
              itemBuilder: (_, i) {
                final month = _months[i];
                return GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pop('$month-$_year'),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.collectionHeader
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: AppColors.collectionHeader
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      month,
                      style: AppTextStyle.style_12_500(
                          color: AppColors.collectionHeader),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _YearArrow extends StatelessWidget {
  const _YearArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
              color: AppColors.borderColor, width: 1),
        ),
        child: Icon(icon,
            size: 16.r, color: AppColors.collectionHeader),
      ),
    );
  }
}
