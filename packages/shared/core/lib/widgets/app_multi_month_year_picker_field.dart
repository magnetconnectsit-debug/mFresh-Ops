// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
// endregion

// region MultiMonthYearPickerResult Model
class MultiMonthYearPickerResult {
  final int year;
  final List<int> months;

  const MultiMonthYearPickerResult({
    required this.year,
    required this.months,
  });
}
// endregion

// region AppMultiMonthYearPickerField Widget
/// A month-year filter input matching the standardized design in image:
/// Displays "MONTH / YEAR" label with formatted selected months (e.g., "Feb, Jun, Aug, Sep, Oct, De...").
/// Tapping opens a modern multi-month selector dialog with year navigation, 
/// selectable month badges (toggling any months), and a "Current Month" shortcut.
class AppMultiMonthYearPickerField extends StatelessWidget {
  // region Properties
  final int? selectedYear;
  final List<int> selectedMonths;
  final ValueChanged<MultiMonthYearPickerResult?> onChanged;
  final String label;
  final String hint;
  final bool showFloatingLabel;
  // endregion

  // region Constructor
  const AppMultiMonthYearPickerField({
    super.key,
    required this.selectedYear,
    required this.selectedMonths,
    required this.onChanged,
    this.label = 'MONTH / YEAR',
    this.hint = 'Select',
    this.showFloatingLabel = true,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedYear != null && selectedMonths.isNotEmpty;

    return InkWell(
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: showFloatingLabel ? label : null,
          floatingLabelBehavior: showFloatingLabel
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.never,
          labelStyle: AppTextStyle.style_11_500(color: AppColors.grey300),
          isDense: true,
          contentPadding: showFloatingLabel
              ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.0.h)
              : EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          filled: true,
          fillColor: AppColors.aliceBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.fieldBorderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.fieldBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        child: SizedBox(
          height: 18.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  hasSelection ? _formatDisplayText() : hint,
                  style: hasSelection
                      ? AppTextStyle.style_12_400(color: AppColors.grey900)
                      : AppTextStyle.style_12_400(color: AppColors.grey300),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (hasSelection)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Icon(
                    Icons.close,
                    size: 14.r,
                    color: AppColors.grey300,
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey300,
                  size: 16.r,
                ),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Helpers & Dialog Opener
  String _formatDisplayText() {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final sorted = List<int>.from(selectedMonths)..sort();
    final names = sorted
        .where((m) => m >= 1 && m <= 12)
        .map((m) => monthNames[m - 1])
        .toList();
    if (names.isEmpty) return '$selectedYear';
    return names.join(', ');
  }

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final initialYear = selectedYear ?? now.year;
    final initialMonths = List<int>.from(selectedMonths);

    final result = await showDialog<MultiMonthYearPickerResult>(
      context: context,
      builder: (_) => _MultiMonthYearPickerDialog(
        initialYear: initialYear,
        initialSelectedMonths: initialMonths,
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }
  // endregion
}
// endregion

// region _MultiMonthYearPickerDialog
class _MultiMonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final List<int> initialSelectedMonths;

  const _MultiMonthYearPickerDialog({
    required this.initialYear,
    required this.initialSelectedMonths,
  });

  @override
  State<_MultiMonthYearPickerDialog> createState() =>
      _MultiMonthYearPickerDialogState();
}

class _MultiMonthYearPickerDialogState
    extends State<_MultiMonthYearPickerDialog> {
  late int _year;
  late Set<int> _selectedMonths;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const Color _primaryThemeColor = Color(0xFF4C57C6); // Indigo / violet from image
  static const Color _cyanButtonColor = Color(0xFF0097A7); // Cyan color for "Current Month"

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _selectedMonths = Set<int>.from(widget.initialSelectedMonths);
  }

  void _toggleMonth(int monthNumber) {
    setState(() {
      if (_selectedMonths.contains(monthNumber)) {
        _selectedMonths.remove(monthNumber);
      } else {
        _selectedMonths.add(monthNumber);
      }
    });
  }

  void _selectCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _year = now.year;
      _selectedMonths.clear();
      _selectedMonths.add(now.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: 320.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header with Year Navigation ──────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: _primaryThemeColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _year--),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                  Text(
                    '$_year',
                    style: AppTextStyle.style_18_700(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _year++),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Month Grid ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  mainAxisExtent: 36.h,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final monthNumber = index + 1;
                  final monthName = _months[index];
                  final isSelected = _selectedMonths.contains(monthNumber);

                  return GestureDetector(
                    onTap: () => _toggleMonth(monthNumber),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryThemeColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        monthName,
                        style: isSelected
                            ? AppTextStyle.style_13_600(color: Colors.white)
                            : AppTextStyle.style_13_500(color: AppColors.black),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Footer: Action Buttons ───────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_12_500(color: AppColors.grey600),
                    ),
                  ),
                  Row(
                    children: [
                      // Current Month Button
                      GestureDetector(
                        onTap: _selectCurrentMonth,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _cyanButtonColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Current Month',
                            style: AppTextStyle.style_11_600(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Apply Button
                      GestureDetector(
                        onTap: () {
                          final sortedMonths = _selectedMonths.toList()..sort();
                          Navigator.of(context).pop(
                            MultiMonthYearPickerResult(
                              year: _year,
                              months: sortedMonths,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryThemeColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Apply',
                            style: AppTextStyle.style_11_600(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// endregion
