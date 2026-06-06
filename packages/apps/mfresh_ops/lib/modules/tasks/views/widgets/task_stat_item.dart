import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class TaskStatItem extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const TaskStatItem({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(count, style: AppTextStyle.style_12_700(color: color)),
        SizedBox(width: 3.w),
        Text(label, style: AppTextStyle.style_10_500(color: AppColors.black)),
      ],
    );
  }
}
