import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class AppCommonTable extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final Map<int, double>? columnWidths;
  final double? headingRowHeight;
  final double? dataRowHeight;
  final Color? headingRowColor;
  final double? horizontalMargin;
  final double? columnSpacing;

  const AppCommonTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnWidths,
    this.headingRowHeight,
    this.dataRowHeight,
    this.headingRowColor,
    this.horizontalMargin,
    this.columnSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: AppColors.grey50,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                horizontalMargin: horizontalMargin ?? 12.w,
                columnSpacing: columnSpacing ?? 20.w,
                headingRowHeight: headingRowHeight ?? 40.h,
                dataRowMinHeight: dataRowHeight ?? 40.h,
                dataRowMaxHeight: (dataRowHeight ?? 40.h) + 10.h,
                headingRowColor: WidgetStateProperty.all(
                  headingRowColor ?? AppColors.grey50,
                ),
                columns: columns.map((col) => DataColumn(
                  label: Text(
                    col,
                    style: AppTextStyle.style_12_700(color: AppColors.black),
                  ),
                )).toList(),
                rows: rows.map((row) => DataRow(
                  cells: row.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    return DataCell(
                      SizedBox(
                        width: columnWidths?[index],
                        child: value is Widget 
                          ? value 
                          : Text(
                              value.toString(),
                              style: AppTextStyle.style_12_400(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                      ),
                    );
                  }).toList(),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
