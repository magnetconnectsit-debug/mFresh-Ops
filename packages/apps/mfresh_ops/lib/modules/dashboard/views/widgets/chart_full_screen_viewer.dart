import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ChartFullScreenViewer extends StatefulWidget {
  final Widget child;
  final String title;

  const ChartFullScreenViewer({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  State<ChartFullScreenViewer> createState() => _ChartFullScreenViewerState();
}

class _ChartFullScreenViewerState extends State<ChartFullScreenViewer> {
  final GlobalKey _globalKey = GlobalKey();
  int _rotationQuarterTurns = 0;
  bool _isCapturing = false;

  void _rotateChart() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  Future<void> _shareChart() async {
    if (_isCapturing) return;

    Rect? originRect;
    if (mounted) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        originRect = box.localToGlobal(Offset.zero) & box.size;
      }
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

        final mediaQuery = MediaQuery.of(context);
        final fallbackRect = Rect.fromLTWH(
          0,
          0,
          mediaQuery.size.width > 0 ? mediaQuery.size.width : 300,
          mediaQuery.size.height > 0 ? mediaQuery.size.height / 2 : 300,
        );
        final shareRect = (originRect != null &&
                !originRect.isEmpty &&
                originRect.width > 0 &&
                originRect.height > 0)
            ? originRect
            : fallbackRect;

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

  Future<Uint8List?> _captureChart() async {
    try {
      // Small delay to ensure rendering is complete
      await Future.delayed(const Duration(milliseconds: 100));

      final currentContext = _globalKey.currentContext;
      if (currentContext == null) return null;

      RenderRepaintBoundary? boundary =
          currentContext.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing chart: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              // Header
              Row(
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
                        icon: const Icon(Icons.rotate_right),
                        onPressed: _rotateChart,
                        tooltip: 'Rotate',
                        color: AppColors.grey700,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 8.w),
                      _isCapturing
                          ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(strokeWidth: 2))
                          : IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: _shareChart,
                              tooltip: 'Share',
                              color: AppColors.grey700,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                        color: AppColors.grey700,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 16.h),
              
              // Chart Area
              Expanded(
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
                          color: Colors.white,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
