// region Imports
import 'dart:io';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
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
  /// Delete compression cache directly on the filesystem to avoid
  /// the known video_compress Android MethodChannel bug (kotlin.Unit serialization crash).
  static Future<void> clearCache() async {
    try {
      if (Platform.isAndroid) {
        final appDirList = await getExternalStorageDirectories();
        if (appDirList != null) {
          for (final dir in appDirList) {
            final compressDir = Directory('${dir.path}/video_compress');
            if (await compressDir.exists()) {
              await compressDir.delete(recursive: true);
            }
          }
        }
      } else {
        final tempDir = await getTemporaryDirectory();
        final compressDir = Directory('${tempDir.path}/video_compress');
        if (await compressDir.exists()) {
          await compressDir.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Error clearing compressor cache: $e');
    }
  }
  // endregion
}
// endregion
