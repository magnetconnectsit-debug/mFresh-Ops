// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
// endregion

// region DutyStatusCard Widget
class DutyStatusCard extends StatelessWidget {
  // region Constructor
  const DutyStatusCard({super.key});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTracking = TrackingService.to.isTracking.value;
      final isSyncing = TrackingService.to.isSyncing.value;
      final isToggling = TrackingService.to.isToggling.value;

      final Color activeColor = isTracking
          ? AppColors.primaryGreen
          : AppColors.red;
      final Color borderColor = isTracking
          ? AppColors.primaryGreen.withOpacity(0.35)
          : AppColors.grey200;
      final Color bgColor = isTracking
          ? const Color(0xFFF6FBF7)
          : AppColors.white;

      return Container(
        height: 35.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: borderColor,
            width: 1.2.r,
          ),
          boxShadow: [
            BoxShadow(
              color: isTracking
                  ? AppColors.primaryGreen.withOpacity(0.06)
                  : AppColors.black.withOpacity(0.03),
              blurRadius: 8.r,
              spreadRadius: 0,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Dot or Sync Loader
            if (isTracking && isSyncing)
              SizedBox(
                width: 10.r,
                height: 10.r,
                child: CustomAppLoader(
                  strokeWidth: 1.8.r,
                  color: activeColor,
                ),
              )
            else
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTracking ? AppColors.primaryGreen : AppColors.grey400,
                  boxShadow: isTracking
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.45),
                            blurRadius: 4.r,
                            spreadRadius: 0.5.r,
                          ),
                        ]
                      : null,
                ),
              ),
            SizedBox(width: 8.w),

            // Duty Status Label
            Text(
              isTracking ? 'Duty On' : 'Duty Off',
              style: AppTextStyle.style_12_600(
                color: isTracking ? AppColors.black : AppColors.grey600,
              ),
              maxLines: 1,
            ),

            const Spacer(),

            // Right Toggle Switch or Loader
            if (isToggling)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CustomAppLoader(
                    strokeWidth: 2.r,
                    color: activeColor,
                  ),
                ),
              )
            else
              CustomLiquidSwitch(
                value: isTracking,
                activeColor: AppColors.primaryGreen,
                inactiveColor: AppColors.grey300,
                onChanged: (val) async {
                  await TrackingService.to.toggleTracking();
                },
              ),
          ],
        ),
      );
    });
  }
  // endregion
}
// endregion

// region CustomLiquidSwitch Widget
class CustomLiquidSwitch extends StatefulWidget {
  // region Properties
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  // endregion

  // region Constructor
  const CustomLiquidSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
  });
  // endregion

  @override
  State<CustomLiquidSwitch> createState() => _CustomLiquidSwitchState();
}
// endregion

// region CustomLiquidSwitchState
class _CustomLiquidSwitchState extends State<CustomLiquidSwitch> {
  // region State Variables
  bool _isPressed = false;
  bool _isAnimating = false;
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() {
          _isPressed = false;
          _isAnimating = true;
        });
        widget.onChanged(!widget.value);
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 38.w,
          height: 22.h,
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: widget.value ? widget.activeColor : widget.inactiveColor,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            alignment: widget.value
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: _isAnimating
                  ? 28.w
                  : (_isPressed ? 22.w : 18.w),
              height: 18.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.r),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.15),
                    blurRadius: 3.r,
                    offset: Offset(0, 1.5.h),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion
