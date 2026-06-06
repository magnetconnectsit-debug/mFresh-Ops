import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class AllTasksHeaderCell extends StatelessWidget {
  final String text;

  const AllTasksHeaderCell({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }
}

class AllTasksDataCell extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const AllTasksDataCell({
    super.key,
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class AllTasksStatusBadge extends StatelessWidget {
  final String status;
  final bool isExpanded;

  const AllTasksStatusBadge({
    super.key,
    required this.status,
    required this.isExpanded,
  });

  String _sanitize(String text) {
    return text.replaceAll('_', ' ');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.red;
      case 'review':
      case 'under_review':
        return Colors.purple;
      default:
        return AppColors.grey300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        _sanitize(status.toUpperCase()),
        style: AppTextStyle.style_10_700(color: color),
        maxLines: isExpanded ? null : 1,
        overflow: isExpanded ? null : TextOverflow.ellipsis,
      ),
    );
  }
}

class AllTasksPaginationButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const AllTasksPaginationButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(
            color: isActive ? Colors.white : Colors.blue.shade600,
          ),
        ),
      ),
    );
  }
}
