import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class MonthRangePicker extends StatefulWidget {
  final DateTime? initialStartMonth;
  final DateTime? initialEndMonth;

  const MonthRangePicker({super.key, this.initialStartMonth, this.initialEndMonth});

  @override
  State<MonthRangePicker> createState() => _MonthRangePickerState();
}

class _MonthRangePickerState extends State<MonthRangePicker> {
  int currentYear = DateTime.now().year;
  DateTime? startMonth;
  DateTime? endMonth;

  @override
  void initState() {
    super.initState();
    startMonth = widget.initialStartMonth;
    endMonth = widget.initialEndMonth;
    if (startMonth != null) {
      currentYear = startMonth!.year;
    }
  }

  void _onMonthTap(int month) {
    final tappedMonth = DateTime(currentYear, month);
    setState(() {
      if (startMonth == null) {
        startMonth = tappedMonth;
        endMonth = null;
      } else if (endMonth == null) {
        if (tappedMonth.isBefore(startMonth!)) {
          endMonth = startMonth;
          startMonth = tappedMonth;
        } else {
          endMonth = tappedMonth;
        }
      } else {
        startMonth = tappedMonth;
        endMonth = null;
      }
    });
  }

  bool _isMonthSelected(int month) {
    final m = DateTime(currentYear, month);
    if (startMonth != null && m.year == startMonth!.year && m.month == startMonth!.month) return true;
    if (endMonth != null && m.year == endMonth!.year && m.month == endMonth!.month) return true;
    return false;
  }

  bool _isMonthInRange(int month) {
    if (startMonth == null || endMonth == null) return false;
    final m = DateTime(currentYear, month);
    return m.isAfter(startMonth!) && m.isBefore(endMonth!);
  }

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => currentYear--),
                ),
                Text(
                  currentYear.toString(),
                  style: AppTextStyle.style_16_600(color: AppColors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => currentYear++),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = _isMonthSelected(month);
                final inRange = _isMonthInRange(month);
                return GestureDetector(
                  onTap: () => _onMonthTap(month),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : inRange
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: AppTextStyle.style_14_400(
                        color: isSelected ? Colors.white : AppColors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel', style: AppTextStyle.style_14_600(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (startMonth != null && endMonth == null) {
                      endMonth = startMonth;
                    }
                    if (startMonth == null && endMonth == null) {
                       Get.back();
                       return;
                    }
                    Get.back(result: DateTimeRange(start: startMonth!, end: endMonth!));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                  child: Text('OK', style: AppTextStyle.style_14_600(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Future<DateTimeRange?> showMonthRangePicker(
  BuildContext context, {
  DateTime? initialStartMonth,
  DateTime? initialEndMonth,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (context) => MonthRangePicker(
      initialStartMonth: initialStartMonth,
      initialEndMonth: initialEndMonth,
    ),
  );
}
