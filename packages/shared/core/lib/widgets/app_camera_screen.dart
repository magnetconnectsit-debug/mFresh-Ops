// region Imports
import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_image_compressor.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_selfie_camera_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCameraScreen Widget
class AppCameraScreen extends StatefulWidget {
  // region Properties
  final int imageCompressionQuality;
  final int cameraLens;
  final bool frontCameraOnly;
  final bool isSelfieMode;
  // endregion

  // region Constructor
  const AppCameraScreen({
    super.key,
    this.imageCompressionQuality = 80,
    this.cameraLens = 1,
    this.frontCameraOnly = false,
    this.isSelfieMode = true,
  });
  // endregion

  @override
  State<AppCameraScreen> createState() => _AppCameraScreenState();
}
// endregion

// region AppCameraScreenState
class _AppCameraScreenState extends State<AppCameraScreen> {
  // region State Variables
  String? _capturedImagePath;
  bool _isProcessing = false;
  // endregion

  // region Image Actions & Compression
  Future<String?> _compressImage(String originalPath) async {
    return AppImageCompressor.compressPath(
      originalPath,
      quality: widget.imageCompressionQuality,
      deleteOriginal: true,
    );
  }

  void _retakePhoto() {
    if (_capturedImagePath != null) {
      try {
        final file = File(_capturedImagePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('Error deleting temporary captured image: $e');
      }
    }
    if (mounted) {
      setState(() {
        _capturedImagePath = null;
      });
    }
  }

  Future<void> _confirmPhoto() async {
    if (_capturedImagePath == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final compressedPath = await _compressImage(_capturedImagePath!);
      if (!mounted) return;
      Navigator.of(context).pop(compressedPath ?? _capturedImagePath);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      if (!mounted) return;
      Navigator.of(context).pop(_capturedImagePath);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _capturedImagePath == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_capturedImagePath != null) {
          _retakePhoto();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            _buildCameraBody(),
            if (_capturedImagePath != null)
              Positioned.fill(
                child: _buildPreviewView(),
              ),
          ],
        ),
      ),
    );
  }
  // endregion

  // region Camera Body
  Widget _buildCameraBody() {
    final initialSensor = widget.cameraLens == 1
        ? SensorPosition.front
        : SensorPosition.back;

    return CameraAwesomeBuilder.awesome(
      previewFit: CameraPreviewFit.cover,
      sensorConfig: SensorConfig.single(
        flashMode: FlashMode.auto,
        aspectRatio: CameraAspectRatios.ratio_16_9,
        sensor: Sensor.position(initialSensor),
      ),
      saveConfig: SaveConfig.photo(mirrorFrontCamera: false),
      previewDecoratorBuilder: (state, preview) {
        if (!widget.isSelfieMode) return const SizedBox.shrink();
        return const IgnorePointer(
          child: AppSelfieCameraOverlay(),
        );
      },
      middleContentBuilder: widget.isSelfieMode
          ? (state) => const SizedBox.shrink()
          : null,
      topActionsBuilder: (state) => SafeArea(
        bottom: false,
        child: AwesomeTopActions(
          state: state,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.white, size: 24.r),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            AwesomeFlashButton(state: state),
            if (state is PhotoCameraState && !widget.isSelfieMode)
              AwesomeAspectRatioButton(state: state),
          ],
        ),
      ),
      bottomActionsBuilder: (state) => SafeArea(
        top: false,
        child: AwesomeBottomActions(
          state: state,
          left: widget.frontCameraOnly ? const SizedBox(width: 48) : null,
        ),
      ),
      onMediaCaptureEvent: (event) async {
        switch ((event.status, event.isPicture, event.isVideo)) {
          case (MediaCaptureStatus.capturing, true, false):
            debugPrint('Capturing picture...');
          case (MediaCaptureStatus.success, true, false):
            event.captureRequest.when(
              single: (single) {
                final path = single.file?.path;
                debugPrint('Picture saved: $path');
                if (path != null && mounted) {
                  setState(() {
                    _capturedImagePath = path;
                  });
                }
              },
              multiple: (multiple) {
                multiple.fileBySensor.forEach((key, value) {
                  debugPrint('multiple image taken: $key ${value?.path}');
                });
              },
            );
          case (MediaCaptureStatus.failure, true, false):
            debugPrint('Failed to capture picture: ${event.exception}');
          case (MediaCaptureStatus.capturing, false, true):
            debugPrint('Capturing video...');
          case (MediaCaptureStatus.success, false, true):
            event.captureRequest.when(
              single: (single) {
                debugPrint('Video saved: ${single.file?.path}');
              },
              multiple: (multiple) {
                multiple.fileBySensor.forEach((key, value) {
                  debugPrint('multiple video taken: $key ${value?.path}');
                });
              },
            );
          case (MediaCaptureStatus.failure, false, true):
            debugPrint('Failed to capture video: ${event.exception}');
          default:
            debugPrint('Unknown event: $event');
        }
      },
    );
  }
  // endregion

  // region Preview View
  Widget _buildPreviewView() {
    return Container(
      color: AppColors.black,
      child: Stack(
        children: [
          // Captured Image Preview
          Positioned.fill(
            child: Center(
              child: Image.file(
                File(_capturedImagePath!),
                fit: widget.isSelfieMode ? BoxFit.cover : BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    'Failed to load preview',
                    style: AppTextStyle.style_14_500(color: AppColors.white),
                  ),
                ),
              ),
            ),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.white,
                        size: 26.r,
                      ),
                      onPressed: _retakePhoto,
                    ),
                    Text(
                      'Photo Preview',
                      style: AppTextStyle.style_16_700(color: AppColors.white),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  bottom: 24.h,
                  top: 24.h,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.black.withValues(alpha: 0.75),
                      AppColors.black.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              child: Row(
                children: [
                  // Retake Button
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.3),
                            blurRadius: 10.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: AppCommonButton(
                        text: 'Retake',
                        icon: Icons.replay_rounded,
                        iconSize: 18.r,
                        iconColor: AppColors.white,
                        variant: ButtonVariant.primary,
                        useGradient: false,
                        buttonColor: const Color(0xFF26262A),
                        borderColor: AppColors.white.withValues(alpha: 0.28),
                        textColor: AppColors.white,
                        height: 48.h,
                        borderRadius: 24.r,
                        textSize: 14.sp,
                        onPressed: _isProcessing ? null : _retakePhoto,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // Confirm Button
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.38),
                            blurRadius: 12.r,
                            spreadRadius: 1.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: AppCommonButton(
                        text: 'Confirm',
                        icon: Icons.check_circle_rounded,
                        iconSize: 19.r,
                        iconColor: AppColors.white,
                        variant: ButtonVariant.primary,
                        gradientColors: const [
                          AppColors.secondaryGreen,
                          AppColors.primaryGreen,
                        ],
                        useGradient: true,
                        textColor: AppColors.white,
                        height: 48.h,
                        borderRadius: 24.r,
                        textSize: 14.sp,
                        isLoading: _isProcessing,
                        onPressed: _isProcessing ? null : _confirmPhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      )],
      ),
    );
  }
  // endregion
}
// endregion
