// region Imports
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
// endregion

// region AppImageCompressor Class
/// Common utility for compressing images across Magnet Connects.
class AppImageCompressor {
  AppImageCompressor._();

  // region Main Compression Methods
  /// Compresses an image given its file path [sourcePath].
  /// Returns the compressed file path, or the original path if compression fails or is larger.
  static Future<String?> compressPath(
    String sourcePath, {
    int quality = 50,
    int minWidth = 1080,
    int minHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
    bool deleteOriginal = false,
  }) async {
    try {
      final originalFile = File(sourcePath);
      if (!await originalFile.exists()) {
        debugPrint('AppImageCompressor: Source file does not exist at $sourcePath');
        return sourcePath;
      }

      final originalLength = await originalFile.length();
      final dir = await getTemporaryDirectory();
      final extension = format == CompressFormat.png
          ? 'png'
          : format == CompressFormat.webp
              ? 'webp'
              : 'jpg';
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: format,
      );

      if (compressedXFile != null && compressedXFile.path.isNotEmpty) {
        final compressedFile = File(compressedXFile.path);
        final compressedLength = await compressedFile.length();

        // If compressed file is valid and smaller in size, use it
        if (compressedLength < originalLength) {
          if (deleteOriginal) {
            try {
              await originalFile.delete();
            } catch (e) {
              debugPrint('AppImageCompressor: Error deleting original file: $e');
            }
          }
          return compressedXFile.path;
        } else {
          // If compressed is unexpectedly larger, cleanup target and keep original
          try {
            await compressedFile.delete();
          } catch (_) {}
          return sourcePath;
        }
      }
    } catch (e) {
      debugPrint('AppImageCompressor.compressPath error: $e');
    }
    return sourcePath;
  }

  /// Compresses a [File] image and returns the compressed [File].
  static Future<File> compressFile(
    File file, {
    int quality = 50,
    int targetWidth = 1080,
    int minHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
    bool deleteOriginal = false,
  }) async {
    final resultPath = await compressPath(
      file.path,
      quality: quality,
      minWidth: targetWidth,
      minHeight: minHeight,
      format: format,
      deleteOriginal: deleteOriginal,
    );
    if (resultPath != null && resultPath.isNotEmpty) {
      return File(resultPath);
    }
    return file;
  }

  /// Compresses an [XFile] image and returns the compressed [XFile].
  static Future<XFile> compressXFile(
    XFile xFile, {
    int quality = 50,
    int minWidth = 1080,
    int minHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
    bool deleteOriginal = false,
  }) async {
    final resultPath = await compressPath(
      xFile.path,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
      deleteOriginal: deleteOriginal,
    );
    if (resultPath != null && resultPath.isNotEmpty) {
      return XFile(resultPath);
    }
    return xFile;
  }
  // endregion
}
// endregion
