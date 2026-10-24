// region Imports
import 'dart:math' as math;
import 'dart:ui';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
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
        final boxRect = _SelfieGeometry.getViewfinderSquare(size);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Semi-transparent Scrim with 4 Camera Focus Corner Brackets
            CustomPaint(
              size: size,
              painter: _ViewfinderScrimPainter(boxRect: boxRect),
            ),

            // 2. Human Outlined White Dashed Contour (Inside the Focus Box)
            CustomPaint(
              size: size,
              painter: _SelfieSilhouettePainter(boxRect: boxRect),
            ),

            // 3. Brand Logo Card at Top
            if (showLogo)
              _buildTopLogo(),

            // 4. Warning Guidance Text Pill (Centered horizontally, never wrapped vertically)
            if (showInstructionText)
              _buildInstructionText(),
          ],
        );
      },
    );
  }
  // endregion

  // region Section Builders
  Widget _buildTopLogo() {
    return Positioned(
      top: 14.h,
      left: 56.w,
      right: 56.w,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            AppImages.appLogo,
            height: 48.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              'mFresh',
              style: AppTextStyle.style_22_600(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return Positioned(
      bottom: 135.h,
      left: 16.w,
      right: 16.w,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1.r,
            ),
          ),
          child: Text(
            'Face, Uniform & mFresh should be visible.',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyle.style_12_700(
              color: const Color(0xFFFF3B30),
            ).copyWith(
              letterSpacing: 0.2,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion

// region Helper Geometry Functions
class _SelfieGeometry {
  /// Computes a responsive square viewfinder box centered between the top logo and bottom camera controls.
  static Rect getViewfinderSquare(Size size) {
    final boxSize = (size.width * 0.88).clamp(280.0, 360.0);
    final boxLeft = (size.width - boxSize) / 2;

    // Available vertical space between top logo (~75.h) and bottom controls (~size.height - 165.h)
    final availableTop = 75.h;
    final availableBottom = size.height - 165.h;
    final availableCenterY = (availableTop + availableBottom) / 2;
    final boxTop = (availableCenterY - (boxSize / 2)).clamp(75.h, size.height - boxSize - 160.h);

    return Rect.fromLTWH(boxLeft, boxTop, boxSize, boxSize);
  }

  /// Builds a unified, seamless person silhouette path (Head + Neck + Shoulders + Torso)
  /// scaled to fit inside the square box.
  static Path getPersonSilhouettePath(Rect boxRect, {bool closeAtBottom = false}) {
    final boxWidth = boxRect.width;
    final centerX = boxRect.center.dx;

    // Head circle positioned in upper half of square box
    final headCenterY = boxRect.top + boxWidth * 0.32;
    final headRadius = boxWidth * 0.20;

    // Neck dimensions connecting seamlessly into head circle
    final neckHalfWidth = (headRadius * 0.44).clamp(24.w, 36.w);
    final deltaY = math.sqrt(headRadius * headRadius - neckHalfWidth * neckHalfWidth);
    final neckJoinY = headCenterY + deltaY;

    final thetaRight = math.atan2(deltaY, neckHalfWidth);
    final thetaLeft = math.atan2(deltaY, -neckHalfWidth);

    // Torso, uniform, and shoulder dimensions filling lower half of box
    final shoulderHalfWidth = boxWidth * 0.38;
    final armHalfWidth = boxWidth * 0.46;
    final shoulderY = neckJoinY + boxWidth * 0.12;
    final bottomY = boxRect.bottom - 4.h;

    final path = Path();

    // 1. Start at bottom of left arm
    path.moveTo(centerX - armHalfWidth, bottomY);

    // 2. Up left arm to left shoulder crest
    path.cubicTo(
      centerX - armHalfWidth,
      shoulderY + boxWidth * 0.20,
      centerX - shoulderHalfWidth - 10.w,
      shoulderY + boxWidth * 0.08,
      centerX - shoulderHalfWidth,
      shoulderY,
    );

    // 3. Left shoulder crest inward & upward along left neck to head attach
    path.cubicTo(
      centerX - shoulderHalfWidth + boxWidth * 0.08,
      shoulderY - boxWidth * 0.03,
      centerX - neckHalfWidth - 3.w,
      neckJoinY + boxWidth * 0.05,
      centerX - neckHalfWidth,
      neckJoinY,
    );

    // 4. Head Arc - Sweep clockwise around top crown of head from left neck to right neck
    final sweepAngle = 2 * math.pi - (thetaLeft - thetaRight);
    path.arcTo(
      Rect.fromCircle(
        center: Offset(centerX, headCenterY),
        radius: headRadius,
      ),
      thetaLeft,
      sweepAngle,
      false,
    );

    // 5. Down right neck attach along neck and outward across right shoulder
    path.cubicTo(
      centerX + neckHalfWidth + 3.w,
      neckJoinY + boxWidth * 0.05,
      centerX + shoulderHalfWidth - boxWidth * 0.08,
      shoulderY - boxWidth * 0.03,
      centerX + shoulderHalfWidth,
      shoulderY,
    );

    // 6. Down right shoulder crest to bottom of right arm
    path.cubicTo(
      centerX + shoulderHalfWidth + 10.w,
      shoulderY + boxWidth * 0.08,
      centerX + armHalfWidth,
      shoulderY + boxWidth * 0.20,
      centerX + armHalfWidth,
      bottomY,
    );

    if (closeAtBottom) {
      path.lineTo(centerX - armHalfWidth, bottomY);
      path.close();
    }

    return path;
  }
}
// endregion

// region Viewfinder Scrim & Focus Corners Painter
class _ViewfinderScrimPainter extends CustomPainter {
  final Rect boxRect;

  _ViewfinderScrimPainter({required this.boxRect});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(16.r);
    final boxRRect = RRect.fromRectAndRadius(boxRect, radius);

    // 1. Semi-transparent dark mask outside the square focus area
    final maskPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(boxRRect);

    final scrimPaint = Paint()
      ..color = AppColors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, scrimPaint);

    // 2. Camera Focus Four-Corner Brackets ┌ ┐ └ ┘
    final cornerLen = 32.w;
    final cornerRadius = 12.r;

    // Subtle dark glow shadow behind corner brackets for high visibility
    final shadowPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 4.5.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    _drawFocusCorners(canvas, boxRect, cornerLen, cornerRadius, shadowPaint);

    // Foreground white focus corner lines
    final cornerPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 3.2.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawFocusCorners(canvas, boxRect, cornerLen, cornerRadius, cornerPaint);
  }

  void _drawFocusCorners(
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

  @override
  bool shouldRepaint(covariant _ViewfinderScrimPainter oldDelegate) {
    return oldDelegate.boxRect != boxRect;
  }
}
// endregion

// region Silhouette Painter (Dashed Lines)
class _SelfieSilhouettePainter extends CustomPainter {
  final Rect boxRect;

  _SelfieSilhouettePainter({required this.boxRect});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 2.5.r
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final personPath = _SelfieGeometry.getPersonSilhouettePath(
      boxRect,
      closeAtBottom: false,
    );

    _drawDashedPath(
      canvas,
      personPath,
      strokePaint,
      dashWidth: 8.w,
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
    return oldDelegate.boxRect != boxRect;
  }
}
// endregion
