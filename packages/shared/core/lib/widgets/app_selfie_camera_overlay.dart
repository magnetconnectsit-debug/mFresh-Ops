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

            // 4. Guidance Text Pill ("Face, uniform & board should be visible")
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
  final double instructionY;
  final double leftArmX;
  final double rightArmX;

  const _SilhouetteData({
    required this.openPath,
    required this.shoulderY,
    required this.shoulderBottomY,
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
    final top = (size.height * 0.17).clamp(130.0, 155.0);
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Builds an anatomical human head, ear contours, neck & broad shoulders silhouette matching reference mockup.
  static _SilhouetteData computeSilhouette(Size size, Rect signboardRect) {
    final centerX = size.width / 2;

    // 1. Vertical coordinates calibrated to reference mockup (raised shoulders, flatter and broader stance)
    final headTopY = signboardRect.bottom + 28.h;
    final earTopY = headTopY + 84.h;
    final earBottomY = headTopY + 138.h;
    final neckBaseY = headTopY + 190.h;
    final shoulderY = headTopY + 208.h; // Raised and closer to neck as drawn
    final shoulderBottomY = headTopY + 218.h; // Very short shoulder stub, cut right at outer edge

    final instructionY = shoulderBottomY + 38.h;

    // 2. Horizontal half-widths matching reference mockup (wider shoulders & chest profile)
    final templeHalfWidth = (size.width * 0.245).clamp(88.0, 105.0);
    final earHalfWidth = (size.width * 0.285).clamp(105.0, 120.0);
    final jawHalfWidth = (size.width * 0.238).clamp(88.0, 105.0);
    final neckHalfWidth = (size.width * 0.192).clamp(72.0, 86.0);
    final shoulderHalfWidth = (size.width * 0.46).clamp(172.0, 215.0); // Widened shoulders as drawn in red
    final armHalfWidth = (size.width * 0.485).clamp(182.0, 225.0); // Outer boundary

    final leftArmX = centerX - armHalfWidth;
    final rightArmX = centerX + armHalfWidth;

    final openPath = Path();

    // 1. Start at bottom of left outer shoulder
    openPath.moveTo(leftArmX, shoulderBottomY);

    // 2. Up to left shoulder outer crest (broad, horizontal profile)
    openPath.cubicTo(
      leftArmX,
      shoulderY + 2.h,
      centerX - shoulderHalfWidth - 4.w,
      shoulderY,
      centerX - shoulderHalfWidth,
      shoulderY,
    );

    // 3. Across trapezius slope from left shoulder crest to neck base (more horizontal shoulder contour)
    openPath.cubicTo(
      centerX - shoulderHalfWidth + 38.w,
      shoulderY,
      centerX - neckHalfWidth - 24.w,
      neckBaseY + 12.h,
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
      centerX - 48.w,
      headTopY,
      centerX,
      headTopY,
    );

    // 7. Down from crown apex through right temple to right ear top (continuous smooth dome)
    openPath.cubicTo(
      centerX + 48.w,
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

    // 10. Down right trapezius slope to right shoulder crest (more horizontal shoulder contour)
    openPath.cubicTo(
      centerX + neckHalfWidth + 24.w,
      neckBaseY + 12.h,
      centerX + shoulderHalfWidth - 38.w,
      shoulderY,
      centerX + shoulderHalfWidth,
      shoulderY,
    );

    // 11. Down right outer shoulder to shoulder bottom
    openPath.cubicTo(
      centerX + shoulderHalfWidth + 4.w,
      shoulderY,
      rightArmX,
      shoulderY + 2.h,
      rightArmX,
      shoulderBottomY,
    );

    return _SilhouetteData(
      openPath: openPath,
      shoulderY: shoulderY,
      shoulderBottomY: shoulderBottomY,
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
    // 1. Top Rectangular Focus Box: 4 White Focus Corner Brackets ┌ ┐ └ ┘
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

    final whiteCornerPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 3.2.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawBoxCorners(
      canvas,
      signboardRect,
      cornerLen,
      cornerRadius,
      whiteCornerPaint,
    );
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
