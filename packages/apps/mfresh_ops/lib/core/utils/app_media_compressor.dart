// region Imports
import 'dart:io';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';
// endregion

// region AppMediaCompressor Class
class AppMediaCompressor {
  AppMediaCompressor._();

  // region Video Compression
  /// Compress video using video_compress
  static Future<File> compressVideo(File file) async {
    try {
      final mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      if (mediaInfo != null && mediaInfo.path != null) {
        return File(mediaInfo.path!);
      }
    } catch (e) {
      debugPrint('Video compression error: $e');
    }
    return file;
  }
  // endregion

  // region Image Compression
  /// Compress image using centralized AppImageCompressor
  static Future<File> compressImage(File file, {int targetWidth = 1080}) async {
    return AppImageCompressor.compressFile(
      file,
      targetWidth: targetWidth,
      quality: 70,
    );
  }
  // endregion

  // region Cache Management
  /// Delete compression cache
  static Future<void> clearCache() async {
    try {
      await VideoCompress.deleteAllCache().catchError((e, stack) {
        debugPrint('Error clearing compressor cache: $e');
        return null;
      });
    } catch (e) {
      debugPrint('Error clearing compressor cache: $e');
    }
  }
  // endregion
}
// endregion
