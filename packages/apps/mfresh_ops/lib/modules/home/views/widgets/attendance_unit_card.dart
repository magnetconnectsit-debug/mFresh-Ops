// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/home/models/attendance_unit_item.dart';
// endregion

// region AttendanceUnitCard Widget
class AttendanceUnitCard extends StatelessWidget {
  final AttendanceUnitItem unit;
  final VoidCallback onTap;
  final bool isSelected;

  const AttendanceUnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = unit.location.isNotEmpty
        ? '${unit.name}, ${unit.location}'
        : unit.name;

    final borderColor = isSelected
        ? AppColors.successDark
        : AppColors.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: borderColor, width: isSelected ? 2.r : 1.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isSelected ? 0.2 : 0.14),
            blurRadius: 12.r,
            spreadRadius: isSelected ? 2.r : 1.r,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 4.r,
            spreadRadius: 0,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(9.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9.r),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.5.r),
                      ),
                      child: AppImageView(
                        imageUrl: unit.image,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightGreen.withValues(alpha: 0.2)
                          : AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8.5.r),
                      ),
                      border: Border(
                        top: BorderSide(color: borderColor, width: 1.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.style_11_700(
                        color: isSelected
                            ? AppColors.successDark
                            : AppColors.grey900,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 6.r,
                  right: 6.r,
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: AppColors.successDark,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.2),
                          blurRadius: 4.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14.sp,
                      color: AppColors.white,
                    ),
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
