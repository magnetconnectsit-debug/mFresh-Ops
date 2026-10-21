// region Imports
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
// endregion

// region AppCameraScreen
class AppCameraScreen extends StatefulWidget {
  final int imageCompressionQuality;
  final int cameraLens;
  final bool frontCameraOnly;

  const AppCameraScreen({
    super.key,
    this.imageCompressionQuality = 50,
    this.cameraLens = 1,
    this.frontCameraOnly = true,
  });

  @override
  State<AppCameraScreen> createState() => _AppCameraScreenState();
}
// endregion

// region AppCameraScreenState
class _AppCameraScreenState extends State<AppCameraScreen> {
  // region Image Compression
  Future<String?> _compressImage(String originalPath) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: widget.imageCompressionQuality,
    );

    if (compressedFile?.path != null) {
      try {
        final originalFile = File(originalPath);
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
      } catch (e) {
        debugPrint('Error deleting original file: $e');
      }
    }

    return compressedFile?.path;
  }

  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(child: _buildCameraBody()),
    );
  }

  // endregion

  // region Camera Body
  Widget _buildCameraBody() {
    final isFront = widget.frontCameraOnly || widget.cameraLens == 1;

    return CameraAwesomeBuilder.awesome(
      sensorConfig: SensorConfig.single(
        flashMode: FlashMode.auto,
        sensor: Sensor.position(
          isFront ? SensorPosition.front : SensorPosition.back,
        ),
      ),
      saveConfig: SaveConfig.photo(mirrorFrontCamera: true),
      topActionsBuilder: (state) => AwesomeTopActions(
        state: state,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.white, size: 26.r),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AwesomeFlashButton(state: state),
          if (state is PhotoCameraState) AwesomeAspectRatioButton(state: state),
        ],
      ),
      bottomActionsBuilder: (state) => AwesomeBottomActions(
        state: state,
        left: isFront ? const SizedBox(width: 48) : null,
      ),
      onMediaCaptureEvent: (event) async {
        switch ((event.status, event.isPicture, event.isVideo)) {
          case (MediaCaptureStatus.capturing, true, false):
            debugPrint('Capturing picture...');
          case (MediaCaptureStatus.success, true, false):
            event.captureRequest.when(
              single: (single) async {
                debugPrint('Picture saved: ${single.file?.path}');
                String? originalPath = single.file?.path;
                if (originalPath != null) {
                  final compressedPath = await _compressImage(originalPath);
                  if (!mounted) return;
                  Navigator.pop(context, compressedPath);
                } else {
                  if (!mounted) return;
                  Navigator.pop(context, null);
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
}

// endregion
