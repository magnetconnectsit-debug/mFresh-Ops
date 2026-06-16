import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';

class DutyStatusCard extends StatefulWidget {
  const DutyStatusCard({super.key});

  @override
  State<DutyStatusCard> createState() => _DutyStatusCardState();
}

class _DutyStatusCardState extends State<DutyStatusCard>
    with SingleTickerProviderStateMixin {
  double _dragPercentage = 0.0;
  bool _isDragging = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_resetController);
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (_resetController.isAnimating) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDistance) {
    if (_resetController.isAnimating) return;
    setState(() {
      _dragPercentage += details.primaryDelta! / maxDistance;
      _dragPercentage = _dragPercentage.clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details, bool isTracking) {
    if (_resetController.isAnimating) return;
    _isDragging = false;

    if (isTracking) {
      if (_dragPercentage < 0.15) {
        TrackingService.to.toggleTracking();
        _animateTo(0.0);
      } else {
        _animateTo(1.0);
      }
    } else {
      if (_dragPercentage > 0.85) {
        TrackingService.to.toggleTracking();
        _animateTo(1.0);
      } else {
        _animateTo(0.0);
      }
    }
  }

  void _animateTo(double target) {
    _resetAnimation = Tween<double>(
      begin: _dragPercentage,
      end: target,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutBack,
    ));

    _resetController.addListener(() {
      setState(() {
        _dragPercentage = _resetAnimation.value;
      });
    });

    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTracking = TrackingService.to.isTracking.value;
      final isSyncing = TrackingService.to.isSyncing.value;

      if (!_isDragging && !_resetController.isAnimating) {
        _dragPercentage = isTracking ? 1.0 : 0.0;
      }

      // Green for tracking, Red for not tracking
      final Color activeColor = isTracking ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      final Color bgColor = isTracking ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
      final Color trackBorderColor = isTracking ? const Color(0xFFA7F3D0) : const Color(0xFFFCA5A5);

      final String text = isTracking ? "Slide left to end shift" : "Slide right to start shift";
      final IconData icon = isTracking ? Icons.power_settings_new_rounded : Icons.double_arrow_rounded;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.5),
                            blurRadius: 4.r,
                            spreadRadius: 1.r,
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isTracking ? 'Status: On Duty & Tracking' : 'Status: Offline (Off Duty)',
                      style: AppTextStyle.style_12_600(
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
                if (isTracking && isSyncing)
                  Row(
                    children: [
                      SizedBox(
                        width: 10.r,
                        height: 10.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.r,
                          valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Syncing...',
                        style: AppTextStyle.style_10_400(color: Colors.grey),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Sleek Slider
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = 60.h;
              final double handleSize = height - 12.h;
              final double maxDistance = width - handleSize - 12.w;

              double textOpacity = isTracking
                  ? (_dragPercentage).clamp(0.0, 1.0)
                  : (1.0 - (_dragPercentage * 1.5)).clamp(0.0, 1.0);

              return Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(color: trackBorderColor, width: 1.5.r),
                ),
                child: Stack(
                  children: [
                    // Slide Instruction Text
                    Center(
                      child: Opacity(
                        opacity: textOpacity,
                        child: Text(
                          text,
                          style: AppTextStyle.style_14_700(
                            color: activeColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),

                    // Draggable Handle
                    Positioned(
                      left: 6.w + (_dragPercentage * maxDistance),
                      top: 6.h,
                      bottom: 6.h,
                      child: GestureDetector(
                        onHorizontalDragStart: _onDragStart,
                        onHorizontalDragUpdate: (details) =>
                            _onDragUpdate(details, maxDistance),
                        onHorizontalDragEnd: (details) =>
                            _onDragEnd(details, isTracking),
                        child: Container(
                          width: handleSize,
                          height: handleSize,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
