// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/models/models.dart';
// endregion

// region EditRecurringTaskChoiceDialog Widget
class EditRecurringTaskChoiceDialog extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onThisTaskOnly;
  final VoidCallback onEntireSeries;

  const EditRecurringTaskChoiceDialog({
    super.key,
    required this.task,
    required this.onThisTaskOnly,
    required this.onEntireSeries,
  });

  @override
  State<EditRecurringTaskChoiceDialog> createState() =>
      _EditRecurringTaskChoiceDialogState();
}
// endregion

// region State Implementation
class _EditRecurringTaskChoiceDialogState
    extends State<EditRecurringTaskChoiceDialog> {
  // region State Variables
  String? _selectedLevel; // "0" for This Task Only, "1" for Entire Task Series
  bool _isNavigating = false;
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 540.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 18.h),
              _buildChoiceCards(context),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Header
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'What do you want to edit?',
                style: AppTextStyle.style_16_700(color: AppColors.black),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20.r, color: AppColors.grey500),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 18.r,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          'Choose whether the change applies only to this occurrence or to the complete recurring series.',
          style: AppTextStyle.style_12_400(color: AppColors.grey600),
        ),
      ],
    );
  }
  // endregion

  // region Choice Cards
  Widget _buildChoiceCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 440;

        final thisTaskCard = _buildOptionCard(
          level: '0',
          title: 'This Task Only',
          onTap: () => _handleSelection('0'),
        );

        final entireSeriesCard = _buildOptionCard(
          level: '1',
          title: 'Entire Task Series',
          onTap: () => _handleSelection('1'),
        );

        if (isNarrow) {
          return Column(
            children: [
              thisTaskCard,
              SizedBox(height: 12.h),
              entireSeriesCard,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: thisTaskCard),
            SizedBox(width: 14.w),
            Expanded(child: entireSeriesCard),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String level,
    required String title,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedLevel == level;

    return InkWell(
      onTap: _isNavigating ? null : onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7F4) : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF15A24)
                : const Color(0xFFD0D5DD),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF15A24).withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.85,
              child: Radio<String>(
                value: level,
                groupValue: _selectedLevel,
                activeColor: const Color(0xFFF15A24),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                onChanged: _isNavigating ? null : (_) => onTap(),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.style_14_700(color: AppColors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // endregion

  // region Helpers
  Future<void> _handleSelection(String level) async {
    if (_isNavigating) return;
    setState(() {
      _selectedLevel = level;
      _isNavigating = true;
    });

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    Navigator.of(context).pop();

    if (level == '0') {
      widget.onThisTaskOnly();
    } else {
      widget.onEntireSeries();
    }
  }
  // endregion
}
// endregion
