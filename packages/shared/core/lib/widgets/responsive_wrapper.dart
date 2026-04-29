import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Alignment alignment;
  final Color? backgroundColor;

  /// A wrapper that constrains the width of its child on large screens (tablets/web)
  /// and centers it.
  ///
  /// [maxWidth] defaults to 650.
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 650,
    this.alignment = Alignment.topCenter,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.w),
        child: child,
      ),
    );
  }
}










