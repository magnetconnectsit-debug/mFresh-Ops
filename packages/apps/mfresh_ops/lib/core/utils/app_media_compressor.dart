import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class AppMediaCompressor {
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

  /// Compress image by resizing and re-encoding it using Flutter's native ImageCodec
  static Future<File> compressImage(File file, {int targetWidth = 1080}) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final frameInfo = await codec.getNextFrame();
      final byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final compressedBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(compressedBytes);
        
        // Only return if it's actually smaller in size
        if (await tempFile.length() < await file.length()) {
          return tempFile;
        }
      }
    } catch (e) {
      debugPrint('Image compression error: $e');
    }
    return file;
  }

  /// Delete compression cache
  static Future<void> clearCache() async {
    try {
      await VideoCompress.deleteAllCache();
    } catch (e) {
      debugPrint('Error clearing compressor cache: $e');
    }
  }
}
