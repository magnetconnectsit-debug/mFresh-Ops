import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class MonthRangePicker extends StatefulWidget {
  final DateTime? initialStartMonth;
  final DateTime? initialEndMonth;

  const MonthRangePicker({
    super.key,
    this.initialStartMonth,
    this.initialEndMonth,
  });

  @override
  State<MonthRangePicker> createState() => _MonthRangePickerState();
}

class _MonthRangePickerState extends State<MonthRangePicker> {
  late int currentYear;
  DateTime? startMonth;
  DateTime? endMonth;
  bool isSelectingYear = false;
  int? _dragStartMonthIndex;

  @override
  void initState() {
    super.initState();
    startMonth = widget.initialStartMonth;
    endMonth = widget.initialEndMonth;
    currentYear = startMonth?.year ?? DateTime.now().year;
  }

  void _onMonthTap(int month) {
    final tappedMonth = DateTime(currentYear, month);
    setState(() {
      if (startMonth == null) {
        startMonth = tappedMonth;
        endMonth = null;
      } else if (endMonth == null) {
        if (tappedMonth.isBefore(startMonth!)) {
          endMonth = DateTime(currentYear, startMonth!.month);
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

  void _handleDragUpdate(Offset localPosition, Size gridSize) {
    if (gridSize.width <= 0 || gridSize.height <= 0) return;

    final double cellWidth = gridSize.width / 3;
    final double cellHeight = gridSize.height / 4;

    final int col = (localPosition.dx / cellWidth).floor().clamp(0, 2);
    final int row = (localPosition.dy / cellHeight).floor().clamp(0, 3);
    final int currentHoverMonth = (row * 3 + col) + 1;

    if (_dragStartMonthIndex == null) {
      _dragStartMonthIndex = currentHoverMonth;
    }

    final int startIdx = _dragStartMonthIndex!;
    final int endIdx = currentHoverMonth;

    final int minMonth = startIdx < endIdx ? startIdx : endIdx;
    final int maxMonth = startIdx < endIdx ? endIdx : startIdx;

    setState(() {
      startMonth = DateTime(currentYear, minMonth);
      endMonth = DateTime(currentYear, maxMonth);
    });
  }

  bool _isMonthSelected(int month) {
    final m = DateTime(currentYear, month);
    if (startMonth != null && m.year == startMonth!.year && m.month == startMonth!.month) {
      return true;
    }
    if (endMonth != null && m.year == endMonth!.year && m.month == endMonth!.month) {
      return true;
    }
    return false;
  }

  bool _isMonthInRange(int month) {
    if (startMonth == null || endMonth == null) return false;
    final m = DateTime(currentYear, month);
    final s = startMonth!;
    final e = endMonth!;
    return m.isAfter(s) && m.isBefore(e);
  }

  Widget _buildYearSelector() {
    final int baseYear = (currentYear ~/ 12) * 12;
    final List<int> years = List.generate(12, (i) => baseYear + i);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => currentYear -= 12),
            ),
            Text(
              '${years.first} - ${years.last}',
              style: AppTextStyle.style_16_600(color: AppColors.black),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => currentYear += 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            final y = years[index];
            final isSelected = y == currentYear;
            return InkWell(
              onTap: () {
                setState(() {
                  currentYear = y;
                  isSelectingYear = false;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$y',
                  style: AppTextStyle.style_14_600(
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => currentYear--),
            ),
            InkWell(
              onTap: () => setState(() => isSelectingYear = true),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currentYear',
                      style: AppTextStyle.style_16_600(color: AppColors.black),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: AppColors.black),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => currentYear++),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onPanStart: (details) {
                _dragStartMonthIndex = null;
                _handleDragUpdate(details.localPosition, constraints.biggest);
              },
              onPanUpdate: (details) {
                _handleDragUpdate(details.localPosition, constraints.biggest);
              },
              onPanEnd: (_) {
                _dragStartMonthIndex = null;
              },
              child: GridView.builder(
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
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelectingYear ? _buildYearSelector() : _buildMonthGrid(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyle.style_14_600(color: Colors.grey),
                  ),
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
                    Get.back(
                      result: DateTimeRange(
                        start: startMonth!,
                        end: endMonth!,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: AppTextStyle.style_14_600(color: Colors.white),
                  ),
                ),
              ],
            ),
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
