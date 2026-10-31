// region Imports
import 'dart:ui';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppSelfieCameraOverlay Widget
class AppSelfieCameraOverlay extends StatelessWidget {
  // region Properties & Constructor
  final bool showLogo;
  final bool showInstructionText;

  const AppSelfieCameraOverlay({
    super.key,
    this.showLogo = true,
    this.showInstructionText = true,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final signboardRect = _SelfieGeometry.getSignboardRect(size);
        final silhouetteData = _SelfieGeometry.computeSilhouette(size, signboardRect);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Top Signboard Dashed Border & Green Focus Corner Brackets
            CustomPaint(
              size: size,
              painter: _SelfieViewfinderPainter(
                signboardRect: signboardRect,
                silhouetteData: silhouetteData,
              ),
            ),

            // 2. Dashed White Person Silhouette Outline (Directly Below Top Box)
            CustomPaint(
              size: size,
              painter: _SelfieSilhouettePainter(
                silhouettePath: silhouetteData.openPath,
              ),
            ),

            // 3. Top Signboard Box Guide Label ("[m] mFresh Board")
            if (showLogo) _buildSignboardGuideLabel(signboardRect),

            // 4. Shoulder Guide Label ("Face & shoulders")
            _buildShoulderGuideLabel(silhouetteData.labelY),

            // 5. Guidance Text Pill ("Face, uniform & board should be visible")
            if (showInstructionText) _buildInstructionText(silhouetteData.instructionY),
          ],
        );
      },
    );
  }
  // endregion

  // region Section Builders
  Widget _buildSignboardGuideLabel(Rect signboardRect) {
    return Positioned(
      top: signboardRect.top - 14.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.25),
              width: 1.r,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16.r,
                height: 16.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Text(
                    'm',
                    style: AppTextStyle.style_11_700(color: AppColors.white).copyWith(
                      height: 1.05,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'mFresh Board',
                style: AppTextStyle.style_12_700(
                  color: AppColors.white,
                ).copyWith(letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoulderGuideLabel(double labelY) {
    return Positioned(
      top: labelY,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.25),
              width: 1.r,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Face & shoulders',
            style: AppTextStyle.style_12_700(color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText(double topY) {
    return Positioned(
      top: topY,
      left: 16.w,
      right: 16.w,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.25),
              width: 1.r,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Face, uniform & board should be visible',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyle.style_12_600(color: AppColors.white).copyWith(
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  // endregion
}
// endregion

// region Helper Geometry Functions & Data
class _SilhouetteData {
  final Path openPath;
  final double shoulderY;
  final double shoulderBottomY;
  final double labelY;
  final double instructionY;
  final double leftArmX;
  final double rightArmX;

  const _SilhouetteData({
    required this.openPath,
    required this.shoulderY,
    required this.shoulderBottomY,
    required this.labelY,
    required this.instructionY,
    required this.leftArmX,
    required this.rightArmX,
  });
}

class _SelfieGeometry {
  /// Computes the top rectangular focus box for the physical mFresh signboard.
  static Rect getSignboardRect(Size size) {
    final width = (size.width * 0.70).clamp(260.0, 310.0);
    final height = (width * 0.35).clamp(84.0, 96.0);
    final left = (size.width - width) / 2;
    final top = (size.height * 0.12).clamp(92.0, 108.0);
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Builds an anatomical human head, ear contours, neck & broad shoulders silhouette matching reference mockup.
  static _SilhouetteData computeSilhouette(Size size, Rect signboardRect) {
    final centerX = size.width / 2;

    // 1. Vertical coordinates calibrated to left reference mockup
    final headTopY = signboardRect.bottom + 32.h;
    final earTopY = headTopY + 76.h;
    final earBottomY = headTopY + 124.h;
    final neckBaseY = headTopY + 176.h;
    final shoulderY = headTopY + 220.h;
    final shoulderBottomY = headTopY + 268.h;

    final labelY = shoulderBottomY - 14.h;
    final instructionY = shoulderBottomY + 22.h;

    // 2. Horizontal half-widths matching left reference mockup
    final templeHalfWidth = (size.width * 0.22).clamp(80.0, 94.0);
    final earHalfWidth = (size.width * 0.255).clamp(95.0, 108.0);
    final jawHalfWidth = (size.width * 0.215).clamp(80.0, 94.0);
    final neckHalfWidth = (size.width * 0.175).clamp(65.0, 78.0);
    final shoulderHalfWidth = (size.width * 0.38).clamp(140.0, 168.0);
    final armHalfWidth = (size.width * 0.42).clamp(155.0, 185.0);

    final leftArmX = centerX - armHalfWidth;
    final rightArmX = centerX + armHalfWidth;

    final openPath = Path();

    // 1. Start at bottom of left arm
    openPath.moveTo(leftArmX, shoulderBottomY);

    // 2. Up left arm to left shoulder crest
    openPath.cubicTo(
      leftArmX,
      shoulderY + 18.h,
      centerX - shoulderHalfWidth - 8.w,
      shoulderY + 4.h,
      centerX - shoulderHalfWidth,
      shoulderY,
    );

    // 3. Across trapezius slope from left shoulder crest to neck base
    openPath.cubicTo(
      centerX - shoulderHalfWidth + 28.w,
      shoulderY - 6.h,
      centerX - neckHalfWidth - 22.w,
      neckBaseY + 16.h,
      centerX - neckHalfWidth,
      neckBaseY,
    );

    // 4. Up left neck and jaw to under-ear
    openPath.cubicTo(
      centerX - neckHalfWidth - 2.w,
      neckBaseY - 20.h,
      centerX - jawHalfWidth,
      earBottomY + 22.h,
      centerX - jawHalfWidth,
      earBottomY,
    );

    // 5. Around left ear (subtle, organic curve)
    openPath.cubicTo(
      centerX - earHalfWidth - 3.w,
      earBottomY - 8.h,
      centerX - earHalfWidth - 3.w,
      earTopY + 8.h,
      centerX - templeHalfWidth,
      earTopY,
    );

    // 6. Up left temple and cranial dome to crown apex (continuous smooth dome)
    openPath.cubicTo(
      centerX - templeHalfWidth,
      headTopY + 30.h,
      centerX - 46.w,
      headTopY,
      centerX,
      headTopY,
    );

    // 7. Down from crown apex through right temple to right ear top (continuous smooth dome)
    openPath.cubicTo(
      centerX + 46.w,
      headTopY,
      centerX + templeHalfWidth,
      headTopY + 30.h,
      centerX + templeHalfWidth,
      earTopY,
    );

    // 8. Around right ear
    openPath.cubicTo(
      centerX + earHalfWidth + 3.w,
      earTopY + 8.h,
      centerX + earHalfWidth + 3.w,
      earBottomY - 8.h,
      centerX + jawHalfWidth,
      earBottomY,
    );

    // 9. Down right jaw and neck to neck base
    openPath.cubicTo(
      centerX + jawHalfWidth,
      earBottomY + 22.h,
      centerX + neckHalfWidth + 2.w,
      neckBaseY - 20.h,
      centerX + neckHalfWidth,
      neckBaseY,
    );

    // 10. Down right trapezius slope to right shoulder crest
    openPath.cubicTo(
      centerX + neckHalfWidth + 22.w,
      neckBaseY + 16.h,
      centerX + shoulderHalfWidth - 28.w,
      shoulderY - 6.h,
      centerX + shoulderHalfWidth,
      shoulderY,
    );

    // 11. Down right outer arm to shoulder bottom
    openPath.cubicTo(
      centerX + shoulderHalfWidth + 8.w,
      shoulderY + 4.h,
      rightArmX,
      shoulderY + 18.h,
      rightArmX,
      shoulderBottomY,
    );

    return _SilhouetteData(
      openPath: openPath,
      shoulderY: shoulderY,
      shoulderBottomY: shoulderBottomY,
      labelY: labelY,
      instructionY: instructionY,
      leftArmX: leftArmX,
      rightArmX: rightArmX,
    );
  }
}
// endregion

// region Viewfinder Focus Corners Painter
class _SelfieViewfinderPainter extends CustomPainter {
  final Rect signboardRect;
  final _SilhouetteData silhouetteData;

  _SelfieViewfinderPainter({
    required this.signboardRect,
    required this.silhouetteData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const neonGreen = Color(0xFF22C55E);

    // 1. Signboard Box: White Dashed Border between corners
    final boardRRect = RRect.fromRectAndRadius(
      signboardRect,
      Radius.circular(10.r),
    );

    final whiteDashedPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 1.8.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPath = Path()..addRRect(boardRRect);
    _drawDashedPath(
      canvas,
      dashPath,
      whiteDashedPaint,
      dashWidth: 6.w,
      dashSpace: 4.w,
    );

    // 2. Top Rectangular Focus Box: 4 Neon Green Focus Corner Brackets ┌ ┐ └ ┘
    final cornerLen = 20.w;
    final cornerRadius = 8.r;

    final shadowPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4.2.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    _drawBoxCorners(
      canvas,
      signboardRect,
      cornerLen,
      cornerRadius,
      shadowPaint,
    );

    final greenCornerPaint = Paint()
      ..color = neonGreen
      ..strokeWidth = 3.2.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawBoxCorners(
      canvas,
      signboardRect,
      cornerLen,
      cornerRadius,
      greenCornerPaint,
    );

    // 3. Two Neon Green Shoulder Focus Corner Brackets └ and ┘
    final shoulderCornerPath = Path();
    final sCornerLen = 18.w;
    final sRadius = 8.r;
    final leftX = silhouetteData.leftArmX;
    final rightX = silhouetteData.rightArmX;
    final bottomY = silhouetteData.shoulderBottomY;

    // Left shoulder corner └
    shoulderCornerPath.moveTo(leftX, bottomY - sCornerLen);
    shoulderCornerPath.lineTo(leftX, bottomY - sRadius);
    shoulderCornerPath.arcToPoint(
      Offset(leftX + sRadius, bottomY),
      radius: Radius.circular(sRadius),
      clockwise: false,
    );
    shoulderCornerPath.lineTo(leftX + sCornerLen, bottomY);

    // Right shoulder corner ┘
    shoulderCornerPath.moveTo(rightX, bottomY - sCornerLen);
    shoulderCornerPath.lineTo(rightX, bottomY - sRadius);
    shoulderCornerPath.arcToPoint(
      Offset(rightX - sRadius, bottomY),
      radius: Radius.circular(sRadius),
      clockwise: true,
    );
    shoulderCornerPath.lineTo(rightX - sCornerLen, bottomY);

    canvas.drawPath(shoulderCornerPath, shadowPaint);
    canvas.drawPath(shoulderCornerPath, greenCornerPaint);
  }

  void _drawBoxCorners(
    Canvas canvas,
    Rect rect,
    double cornerLen,
    double cornerRadius,
    Paint paint,
  ) {
    final path = Path();

    // Top-Left Corner ┌
    path.moveTo(rect.left, rect.top + cornerLen);
    path.lineTo(rect.left, rect.top + cornerRadius);
    path.arcToPoint(
      Offset(rect.left + cornerRadius, rect.top),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.lineTo(rect.left + cornerLen, rect.top);

    // Top-Right Corner ┐
    path.moveTo(rect.right - cornerLen, rect.top);
    path.lineTo(rect.right - cornerRadius, rect.top);
    path.arcToPoint(
      Offset(rect.right, rect.top + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.lineTo(rect.right, rect.top + cornerLen);

    // Bottom-Right Corner ┘
    path.moveTo(rect.right, rect.bottom - cornerLen);
    path.lineTo(rect.right, rect.bottom - cornerRadius);
    path.arcToPoint(
      Offset(rect.right - cornerRadius, rect.bottom),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.lineTo(rect.right - cornerLen, rect.bottom);

    // Bottom-Left Corner └
    path.moveTo(rect.left + cornerLen, rect.bottom);
    path.lineTo(rect.left + cornerRadius, rect.bottom);
    path.arcToPoint(
      Offset(rect.left, rect.bottom - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.lineTo(rect.left, rect.bottom - cornerLen);

    canvas.drawPath(path, paint);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashWidth,
    required double dashSpace,
  }) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0.0, metric.length);
        final Path extract = metric.extractPath(distance, end);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SelfieViewfinderPainter oldDelegate) {
    return oldDelegate.signboardRect != signboardRect ||
        oldDelegate.silhouetteData.shoulderY != silhouetteData.shoulderY ||
        oldDelegate.silhouetteData.shoulderBottomY != silhouetteData.shoulderBottomY;
  }
}
// endregion

// region Silhouette Painter (Dashed Lines)
class _SelfieSilhouettePainter extends CustomPainter {
  final Path silhouettePath;

  _SelfieSilhouettePainter({required this.silhouettePath});

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final strokePaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 2.4.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(
      canvas,
      silhouettePath,
      shadowPaint,
      dashWidth: 7.w,
      dashSpace: 5.w,
    );

    _drawDashedPath(
      canvas,
      silhouettePath,
      strokePaint,
      dashWidth: 7.w,
      dashSpace: 5.w,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashWidth,
    required double dashSpace,
  }) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0.0, metric.length);
        final Path extract = metric.extractPath(distance, end);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SelfieSilhouettePainter oldDelegate) {
    return oldDelegate.silhouettePath != silhouettePath;
  }
}
// endregion
