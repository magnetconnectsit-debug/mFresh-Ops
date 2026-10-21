import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// region Chart Full Screen Viewer Widget
class ChartFullScreenViewer extends StatefulWidget {
  // region Properties
  final Widget child;
  final String title;
  // endregion

  // region Constructor
  const ChartFullScreenViewer({
    super.key,
    required this.child,
    required this.title,
  });
  // endregion

  // region State Creation
  @override
  State<ChartFullScreenViewer> createState() => _ChartFullScreenViewerState();
  // endregion
}
// endregion

// region Chart Full Screen Viewer State
class _ChartFullScreenViewerState extends State<ChartFullScreenViewer> {
  // region State Variables
  final GlobalKey _globalKey = GlobalKey();
  int _rotationQuarterTurns = 0;
  bool _isCapturing = false;
  // endregion

  // region Actions & Event Handlers
  void _rotateChart() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  Future<void> _shareChart(BuildContext btnContext) async {
    if (_isCapturing) return;

    // Calculate anchor rect for iPadOS / iOS popover presentation (safe on Android as well)
    Rect? shareRect;
    try {
      final box = btnContext.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        shareRect = box.localToGlobal(Offset.zero) & box.size;
      }
    } catch (e) {
      debugPrint('Error getting share anchor box: $e');
    }

    if (shareRect == null ||
        shareRect.isEmpty ||
        shareRect.width <= 0 ||
        shareRect.height <= 0) {
      final mediaQuery = MediaQuery.of(context);
      shareRect = Rect.fromLTWH(
        mediaQuery.size.width > 60.w ? mediaQuery.size.width - 60.w : 0,
        40.h,
        40.w,
        40.h,
      );
    }

    try {
      setState(() => _isCapturing = true);

      final imageBytes = await _captureChart();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imageFile = File('${directory.path}/chart_$timestamp.png');
        await imageFile.writeAsBytes(imageBytes);

        if (!mounted) return;

        await Share.shareXFiles(
          [XFile(imageFile.path, mimeType: 'image/png')],
          text: 'Chart: ${widget.title}',
          sharePositionOrigin: shareRect,
        );
      } else {
        if (mounted) {
          AppCommonToastMessage.show(
            message: 'Failed to generate chart image for sharing',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('Error sharing chart: $e');
      if (mounted) {
        AppCommonToastMessage.show(
          message: 'Failed to share chart: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }
  // endregion

  // region Chart Capture Operations
  Future<Uint8List?> _captureChart() async {
    try {
      // 1. Ensure any pending frame triggered by setState has rendered on both Android and iOS
      if (!SchedulerBinding.instance.hasScheduledFrame) {
        SchedulerBinding.instance.scheduleFrame();
      }
      final completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future.timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {},
      );

      // Brief buffer to ensure layer tree rasterization is ready
      await Future.delayed(const Duration(milliseconds: 50));

      final currentContext = _globalKey.currentContext;
      if (currentContext == null) return null;

      final boundary =
          currentContext.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // 2. Multi-tier pixelRatio attempt:
      // Try 3.0 first (crisp high-resolution capture as on Android),
      // then fall back gracefully to 2.0, 1.5, 1.0 if device GPU/memory constraint occurs
      ui.Image? image;
      final pixelRatios = [3.0, 2.0, 1.5, 1.0];
      for (final ratio in pixelRatios) {
        try {
          image = await boundary.toImage(pixelRatio: ratio);
          if (image != null) break;
        } catch (captureErr) {
          debugPrint(
            'RepaintBoundary.toImage attempt at pixelRatio $ratio failed: $captureErr',
          );
        }
      }

      if (image == null) return null;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing chart: $e');
      return null;
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              _buildHeader(context),
              Divider(color: AppColors.grey50, height: 16.h),
              SizedBox(height: 8.h),
              _buildChartArea(),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Sub-view Builders
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: AppTextStyle.style_16_600(color: AppColors.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.rotate_right, size: 22.r),
              onPressed: _rotateChart,
              tooltip: 'Rotate',
              color: AppColors.grey700,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 12.w),
            _isCapturing
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CustomAppLoader(size: 20),
                  )
                : Builder(
                    builder: (btnContext) {
                      return IconButton(
                        icon: Icon(Icons.share, size: 22.r),
                        onPressed: () => _shareChart(btnContext),
                        tooltip: 'Share',
                        color: AppColors.grey700,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    },
                  ),
            SizedBox(width: 12.w),
            IconButton(
              icon: Icon(Icons.close, size: 22.r),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
              color: AppColors.grey700,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartArea() {
    return Expanded(
      child: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: RepaintBoundary(
            key: _globalKey,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: RotatedBox(
                  quarterTurns: _rotationQuarterTurns,
                  child: SizedBox(
                    width: 800.w,
                    height: 450.h,
                    child: widget.child,
                  ),
                ),
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
