import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';

class DutyStatusCard extends StatelessWidget {
  const DutyStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTracking = TrackingService.to.isTracking.value;
      final isSyncing = TrackingService.to.isSyncing.value;

      // Premium theme coloring using central AppColors definitions
      final Color activeColor = isTracking
          ? AppColors.primaryGreen
          : AppColors.red;
      final Color innerBgColor = isTracking
          ? AppColors.primaryGreen.withOpacity(0.08)
          : AppColors.red1;
      final Color cardGlowColor = isTracking
          ? AppColors.primaryGreen.withOpacity(0.06)
          : Colors.black.withOpacity(0.02);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isTracking ? AppColors.primaryGreen : AppColors.red,
            width: 1.2.r,
          ),
          boxShadow: [
            BoxShadow(
              color: cardGlowColor,
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left icon placeholder
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: innerBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isTracking
                      ? Icons.radar_rounded
                      : Icons.power_settings_new_rounded,
                  color: activeColor,
                  size: 20.r,
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Middle state details
            Expanded(
              child: Row(
                children: [
                  Text(
                    isTracking ? 'Duty On' : 'Duty OFF',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                  if (isTracking && isSyncing) ...[
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 10.r,
                      height: 10.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right adaptive switch toggle or loader
            TrackingService.to.isToggling.value
                ? Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CustomAppLoader(),
                    ),
                  )
                : CustomLiquidSwitch(
                    value: isTracking,
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: AppColors.grey50,
                    onChanged: (val) async {
                      await TrackingService.to.toggleTracking();
                    },
                  ),
          ],
        ),
      );
    });
  }
}

class CustomLiquidSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const CustomLiquidSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  State<CustomLiquidSwitch> createState() => _CustomLiquidSwitchState();
}

class _CustomLiquidSwitchState extends State<CustomLiquidSwitch> {
  bool _isPressed = false;
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        scale: _isPressed ? 0.92 : 1.0, // Overall squeeze effect
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 32,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.value ? widget.activeColor : widget.inactiveColor,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut, // Bouncy snapping logic
            alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: _isAnimating ? 46 : (_isPressed ? 34 : 28), // Huge stretch across the track
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
