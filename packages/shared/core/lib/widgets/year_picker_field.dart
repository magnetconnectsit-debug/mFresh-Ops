// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region YearPickerField Class
/// A tap-to-open year-only picker styled identically to [AppCommonMultiSelectDropdown]
/// and [MonthYearPickerField] (InputDecorator + floating label).
/// Displays and stores only the 4-digit year string (e.g. '2025').
class YearPickerField extends StatelessWidget {
  const YearPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Select Year',
    this.hintText,
    this.showFloatingLabel = true,
  });

  /// Currently selected year (e.g. '2025'), or null if none.
  final String? value;

  /// Called with a 4-digit year string when the user picks a year,
  /// or null when they clear the selection.
  final ValueChanged<String?> onChanged;

  final String label;
  final String? hintText;
  final bool showFloatingLabel;

  @override
  Widget build(BuildContext context) {
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
            borderSide:
                const BorderSide(color: AppColors.fieldBorderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide:
                const BorderSide(color: AppColors.fieldBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        child: SizedBox(
          height: 18.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value != null && value!.isNotEmpty
                      ? value!
                      : (hintText ?? (showFloatingLabel ? 'Select' : label)),
                  style: value != null && value!.isNotEmpty
                      ? AppTextStyle.style_12_400(color: AppColors.grey900)
                      : AppTextStyle.style_12_400(color: AppColors.grey300),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (value != null && value!.isNotEmpty)
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

  Future<void> _openPicker(BuildContext context) async {
    int initialYear = DateTime.now().year;
    if (value != null && value!.isNotEmpty) {
      initialYear = int.tryParse(value!) ?? DateTime.now().year;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _YearPickerDialog(initialYear: initialYear),
    );

    if (result != null) onChanged(result);
  }
}
// endregion

// region _YearPickerDialog Class
class _YearPickerDialog extends StatefulWidget {
  const _YearPickerDialog({required this.initialYear});
  final int initialYear;

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _startYear;
  static const int _yearsPerPage = 12;

  @override
  void initState() {
    super.initState();
    _startYear = (widget.initialYear ~/ _yearsPerPage) * _yearsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    final endYear = _startYear + _yearsPerPage - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Select Year',
                    style: AppTextStyle.style_15_700(color: AppColors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Decade Navigation
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.aliceBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 20.sp,
                      color: AppColors.grey700,
                    ),
                    onPressed: () => setState(() => _startYear -= _yearsPerPage),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    '$_startYear - $endYear',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 20.sp,
                      color: AppColors.grey700,
                    ),
                    onPressed: () => setState(() => _startYear += _yearsPerPage),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // 12-Year Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _yearsPerPage,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                final year = _startYear + index;
                final isSelected = year == widget.initialYear;

                return InkWell(
                  onTap: () => Navigator.of(context).pop(year.toString()),
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.fieldBorderColor,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      year.toString(),
                      style: isSelected
                          ? AppTextStyle.style_13_600(color: AppColors.white)
                          : AppTextStyle.style_13_500(color: AppColors.grey800),
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
// endregion
