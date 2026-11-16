// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonLiquidGlass Widget
/// Authentic iOS / VisionOS Liquid Glass Container & Indicator.
///
/// Recreates the 3D embossed cast-glass lens effect with:
/// - Diffuse ambient & contact drop shadows for tactile elevation
/// - Translucent cool silver-grey refractive optical body
/// - Dual-tone directional outer rim (sharp specular highlight to dark refraction edge)
/// - Inner meniscus groove ("double rim" refractive contour)
/// - Top curvature Fresnel specular sheen and crest glint
/// - Bottom caustic reflection
///
/// Can be used as a stadium capsule pill, a rounded card/container, or with a custom [borderRadius].
class AppCommonLiquidGlass extends StatelessWidget {
  // region Properties
  /// Optional content to display inside the glass container.
  final Widget? child;

  /// Explicit width for the container.
  final double? width;

  /// Explicit height for the container.
  final double? height;

  /// Custom border radius for rounded rectangle glass surfaces.
  /// If [isPill] is true, this is overridden by a semicircular stadium radius.
  final BorderRadius? borderRadius;

  /// Whether to render as a perfect stadium capsule pill.
  final bool isPill;

  /// Insets inside the glass container.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the glass container.
  final EdgeInsetsGeometry? margin;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Base glass tint color (defaults to cool silver-grey `Color(0xFFE2E8F0)`).
  final Color? tintColor;

  /// Overall glass opacity factor between 0.0 and 1.0.
  final double glassOpacity;

  /// Whether to render elevation shadows.
  final bool showShadow;

  /// Whether to render the internal caustic glow and meniscus groove.
  final bool showRefraction;

  /// Whether to render the top curvature Fresnel sheen.
  final bool showSheen;

  /// Whether to render the razor-sharp top crest glint.
  final bool showGlint;
  // endregion

  // region Constructors
  const AppCommonLiquidGlass({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.isPill = false,
    this.padding,
    this.margin,
    this.onTap,
    this.tintColor,
    this.glassOpacity = 1.0,
    this.showShadow = true,
    this.showRefraction = true,
    this.showSheen = true,
    this.showGlint = true,
  });

  /// Factory constructor for a stadium capsule pill shape.
  const AppCommonLiquidGlass.pill({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.tintColor,
    this.glassOpacity = 1.0,
    this.showShadow = true,
    this.showRefraction = true,
    this.showSheen = true,
    this.showGlint = true,
  })  : isPill = true,
        borderRadius = null;
  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: AppCommonLiquidGlassPainter(
        borderRadius: borderRadius,
        isPill: isPill,
        tintColor: tintColor,
        glassOpacity: glassOpacity,
        showShadow: showShadow,
        showRefraction: showRefraction,
        showSheen: showSheen,
        showGlint: showGlint,
      ),
      child: child != null
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            )
          : null,
    );

    if (onTap != null) {
      final effectiveRadius = isPill
          ? BorderRadius.circular(100.r)
          : (borderRadius ?? BorderRadius.circular(12.r));
      content = Material(
        color: AppColors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: AppColors.white.withValues(alpha: 0.2),
          highlightColor: AppColors.white.withValues(alpha: 0.1),
          child: content,
        ),
      );
    }

    if (width != null || height != null) {
      content = SizedBox(
        width: width,
        height: height,
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
  // endregion
}
// endregion

// region AppCommonLiquidGlassPainter Class
/// CustomPainter rendering the authentic iOS / VisionOS liquid glass material.
class AppCommonLiquidGlassPainter extends CustomPainter {
  // region Properties
  final BorderRadius? borderRadius;
  final bool isPill;
  final Color? tintColor;
  final double glassOpacity;
  final bool showShadow;
  final bool showRefraction;
  final bool showSheen;
  final bool showGlint;
  // endregion

  // region Constructor
  const AppCommonLiquidGlassPainter({
    this.borderRadius,
    this.isPill = false,
    this.tintColor,
    this.glassOpacity = 1.0,
    this.showShadow = true,
    this.showRefraction = true,
    this.showSheen = true,
    this.showGlint = true,
  });
  // endregion

  // region Paint Implementation
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // region Geometry & Sizing
    final RRect rrect;
    final double radius;
    if (isPill) {
      radius = size.height / 2;
      rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      );
    } else {
      final br = borderRadius ?? BorderRadius.circular(12.r);
      rrect = br.toRRect(Rect.fromLTWH(0, 0, size.width, size.height));
      radius = rrect.tlRadiusX;
    }

    final opacity = glassOpacity.clamp(0.0, 1.0);
    // endregion

    // region 1. Soft Ambient & Contact Drop Shadows
    if (showShadow && opacity > 0.1) {
      final ambientShadowPaint = Paint()
        ..color = const Color(0x1F0F172A).withValues(alpha: 0.12 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawRRect(rrect.shift(Offset(0, 2.2.h)), ambientShadowPaint);

      final contactShadowPaint = Paint()
        ..color = const Color(0x160F172A).withValues(alpha: 0.09 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
      canvas.drawRRect(rrect.shift(Offset(0, 1.0.h)), contactShadowPaint);
    }
    // endregion

    // region 2. Glass Body (Refractive Frosted Silver-Grey Optical Density)
    final baseColor = tintColor ?? const Color(0xFFE2E8F0);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF8FAFC).withValues(alpha: 0.95 * opacity),
          baseColor.withValues(alpha: 0.85 * opacity),
          const Color(0xFFCBD5E1).withValues(alpha: 0.78 * opacity),
          baseColor.withValues(alpha: 0.90 * opacity),
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(rrect, bodyPaint);
    // endregion

    // region 3. Bottom Caustic Refraction Glow
    if (showRefraction && opacity > 0.1) {
      final causticRect = Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.55,
        size.width * 0.76,
        size.height * 0.40,
      );
      final causticPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.0),
            AppColors.white.withValues(alpha: 0.45 * opacity),
          ],
        ).createShader(causticRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(causticRect, Radius.circular(radius * 0.6)),
        causticPaint,
      );
    }
    // endregion

    // region 4. Top Curvature Specular Sheen (Fresnel Wash)
    if (showSheen && opacity > 0.1) {
      final sheenRect = Rect.fromLTWH(
        0.5.w,
        0.5.h,
        size.width - 1.0.w,
        size.height * 0.55,
      );
      final sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.85 * opacity),
            AppColors.white.withValues(alpha: 0.0),
          ],
        ).createShader(sheenRect);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          sheenRect,
          topLeft: rrect.tlRadius,
          topRight: rrect.trRadius,
        ),
        sheenPaint,
      );
    }
    // endregion

    // region 5. Outer Dual-Tone Glass Rim (Directional Light Refraction)
    final outerRimRRect = rrect.deflate(0.6.r);
    final outerRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2.w
      ..shader = LinearGradient(
        begin: const Alignment(-0.8, -1.0),
        end: const Alignment(0.8, 1.0),
        colors: [
          AppColors.white.withValues(alpha: 1.0 * opacity),
          AppColors.white.withValues(alpha: 0.95 * opacity),
          const Color(0xFF94A3B8).withValues(alpha: 0.55 * opacity),
          const Color(0xFF475569).withValues(alpha: 0.65 * opacity),
          const Color(0xFF64748B).withValues(alpha: 0.75 * opacity),
          const Color(0xFF94A3B8).withValues(alpha: 0.50 * opacity),
        ],
        stops: const [0.0, 0.35, 0.60, 0.80, 0.92, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(outerRimRRect, outerRimPaint);
    // endregion

    // region 6. Inner Meniscus Refraction Groove (The "Double Rim" Optical Effect)
    final innerRRect = rrect.deflate(2.0.r);
    if (showRefraction && innerRRect.width > 0 && innerRRect.height > 0) {
      final innerRimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9.w
        ..shader = LinearGradient(
          begin: const Alignment(-0.6, -1.0),
          end: const Alignment(0.6, 1.0),
          colors: [
            AppColors.white.withValues(alpha: 0.80 * opacity),
            AppColors.white.withValues(alpha: 0.50 * opacity),
            AppColors.transparent,
            const Color(0xFF334155).withValues(alpha: 0.30 * opacity),
            const Color(0xFF1E293B).withValues(alpha: 0.40 * opacity),
            AppColors.transparent,
          ],
          stops: const [0.0, 0.30, 0.55, 0.75, 0.90, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRRect(innerRRect, innerRimPaint);
    }
    // endregion

    // region 7. Top Crest Sharp Specular Glint
    if (showGlint && opacity > 0.1) {
      final maxGlint = size.width > 24.0.w ? size.width - 12.0.w : size.width;
      final glintWidth = (size.width * 0.55).clamp(8.0.w, maxGlint);
      final glintLeft = (size.width - glintWidth) / 2;
      final glintRect = Rect.fromLTWH(glintLeft, 1.5.h, glintWidth, 0.9.h);
      final glintPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.white.withValues(alpha: 0.0),
            AppColors.white.withValues(alpha: 0.95 * opacity),
            AppColors.white.withValues(alpha: 1.0 * opacity),
            AppColors.white.withValues(alpha: 0.95 * opacity),
            AppColors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(glintRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(glintRect, Radius.circular(0.5.r)),
        glintPaint,
      );
    }
    // endregion
  }
  // endregion

  // region Repaint Logic
  @override
  bool shouldRepaint(covariant AppCommonLiquidGlassPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isPill != isPill ||
        oldDelegate.tintColor != tintColor ||
        oldDelegate.glassOpacity != glassOpacity ||
        oldDelegate.showShadow != showShadow ||
        oldDelegate.showRefraction != showRefraction ||
        oldDelegate.showSheen != showSheen ||
        oldDelegate.showGlint != showGlint;
  }
  // endregion
}
// endregion
