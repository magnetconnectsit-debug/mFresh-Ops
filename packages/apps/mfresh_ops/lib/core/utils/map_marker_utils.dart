// ignore_for_file: deprecated_member_use
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerUtils {
  static Future<BitmapDescriptor> createAssetMarker(
    String assetPath, {
    int width = 100,
  }) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createIconMarker({
    required Color color,
    required IconData iconData,
    Color iconColor = Colors.white,
    double size = 80,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final double radius = size / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size / 1.8,
        color: iconColor,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
      ),
    );
    painter.layout();

    painter.paint(
      canvas,
      Offset((size - painter.width) / 2, (size - painter.height) / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createCustomMarker({
    required Color color,
    required String text,
    required String fullName,
    Color textColor = Colors.white,
    Color borderColor = Colors.white,
    double size = 120,
    bool showLiveWifi = false,
    bool showStaleWifi = false,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double width = size * 1.2;
    final double height = size * 1.6;

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;

    final double avatarRadius = width / 2 - 10;
    final Offset avatarCenter = Offset(width / 2, avatarRadius + 10);

    final double arrowWidth = width * 0.25;
    final double arrowHeight = width * 0.2;
    final double arrowBottomY = avatarCenter.dy + avatarRadius + arrowHeight;

    final Path markerPath = Path();
    markerPath.addOval(
      Rect.fromCircle(center: avatarCenter, radius: avatarRadius),
    );

    final Path arrowPath = Path();
    arrowPath.moveTo(
      avatarCenter.dx - arrowWidth / 2,
      avatarCenter.dy + avatarRadius - 5,
    );
    arrowPath.lineTo(
      avatarCenter.dx + arrowWidth / 2,
      avatarCenter.dy + avatarRadius - 5,
    );
    arrowPath.lineTo(avatarCenter.dx, arrowBottomY);
    arrowPath.close();

    final Path combinedPath = Path.combine(
      PathOperation.union,
      markerPath,
      arrowPath,
    );

    // Draw Shadow
    canvas.drawPath(
      combinedPath.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Draw Filled Shape
    canvas.drawPath(combinedPath, paint);

    // Draw Border
    canvas.drawPath(combinedPath, borderPaint);

    // Draw large initials in the center
    TextPainter initialsPainter = TextPainter(textDirection: TextDirection.ltr);
    initialsPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: avatarRadius * 1.4,
        color: textColor,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
    initialsPainter.layout();

    initialsPainter.paint(
      canvas,
      Offset(
        avatarCenter.dx - initialsPainter.width / 2,
        avatarCenter.dy - initialsPainter.height / 2,
      ),
    );

    // Draw name pill at the bottom
    final double pillWidth = width * 0.95;
    final double pillHeight = width * 0.28;
    final Rect pillRect = Rect.fromCenter(
      center: Offset(width / 2, avatarCenter.dy + avatarRadius),
      width: pillWidth,
      height: pillHeight,
    );
    final RRect pillRRect = RRect.fromRectAndRadius(
      pillRect,
      Radius.circular(pillHeight / 2),
    );

    canvas.drawRRect(
      pillRRect.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(pillRRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    TextPainter namePainter = TextPainter(textDirection: TextDirection.ltr);
    namePainter.text = TextSpan(
      text: fullName,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
        fontWeight: FontWeight.w900,
      ),
    );
    namePainter.layout();

    TextPainter? iconPainter;
    if (showLiveWifi || showStaleWifi) {
      iconPainter = TextPainter(textDirection: TextDirection.ltr);
      iconPainter.text = TextSpan(
        text: String.fromCharCode(
          showLiveWifi ? Icons.wifi.codePoint : Icons.wifi_off.codePoint,
        ),
        style: TextStyle(
          fontSize: 26,
          color: showLiveWifi ? Colors.green : Colors.red,
          fontFamily: Icons.wifi.fontFamily,
          package: Icons.wifi.fontPackage,
          fontWeight: FontWeight.w900,
        ),
      );
      iconPainter.layout();
    }

    final double totalTextWidth =
        namePainter.width + (iconPainter != null ? iconPainter.width + 2 : 0);
    final double startX = (width - totalTextWidth) / 2;

    if (iconPainter != null) {
      iconPainter.paint(
        canvas,
        Offset(startX, pillRect.top + (pillHeight - iconPainter.height) / 2),
      );
    }
    namePainter.paint(
      canvas,
      Offset(
        startX + (iconPainter != null ? iconPainter.width + 2 : 0),
        pillRect.top + (pillHeight - namePainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createNetworkImageMarker({
    required String imageUrl,
    required Color color,
    required String fallbackText,
    Color textColor = Colors.white,
    Color borderColor = Colors.white,
    double size = 120,
    bool showLiveWifi = false,
    bool showStaleWifi = false,
  }) async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client.getUrl(
        Uri.parse(imageUrl),
      );
      final HttpClientResponse response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load image, status code: ${response.statusCode}',
        );
      }

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
      );

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final double width = size * 1.2;
      final double height = size * 1.6;

      final Paint paint = Paint()..color = color;
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0;

      final double avatarRadius = width / 2 - 10;
      final Offset avatarCenter = Offset(width / 2, avatarRadius + 10);

      final double arrowWidth = width * 0.25;
      final double arrowHeight = width * 0.2;
      final double arrowBottomY = avatarCenter.dy + avatarRadius + arrowHeight;

      final Path markerPath = Path();
      markerPath.addOval(
        Rect.fromCircle(center: avatarCenter, radius: avatarRadius),
      );

      final Path arrowPath = Path();
      arrowPath.moveTo(
        avatarCenter.dx - arrowWidth / 2,
        avatarCenter.dy + avatarRadius - 5,
      );
      arrowPath.lineTo(
        avatarCenter.dx + arrowWidth / 2,
        avatarCenter.dy + avatarRadius - 5,
      );
      arrowPath.lineTo(avatarCenter.dx, arrowBottomY);
      arrowPath.close();

      final Path combinedPath = Path.combine(
        PathOperation.union,
        markerPath,
        arrowPath,
      );

      canvas.drawPath(
        combinedPath.shift(const Offset(0, 5)),
        Paint()
          ..color = Colors.black26
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      canvas.drawPath(combinedPath, paint);
      canvas.drawPath(combinedPath, borderPaint);

      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image avatarImage = fi.image;

      canvas.save();
      Path clipPath = Path()
        ..addOval(
          Rect.fromCircle(center: avatarCenter, radius: avatarRadius - 1.5),
        );
      canvas.clipPath(clipPath);

      final double scaleX = (avatarRadius * 2) / avatarImage.width;
      final double scaleY = (avatarRadius * 2) / avatarImage.height;
      final double scale = scaleX > scaleY ? scaleX : scaleY;

      final Rect srcRect = Rect.fromLTWH(
        0,
        0,
        avatarImage.width.toDouble(),
        avatarImage.height.toDouble(),
      );
      final Rect dstRect = Rect.fromCenter(
        center: avatarCenter,
        width: avatarImage.width * scale,
        height: avatarImage.height * scale,
      );

      canvas.drawImageRect(avatarImage, srcRect, dstRect, Paint());
      canvas.restore();

      // Draw inner border for avatar
      canvas.drawCircle(
        avatarCenter,
        avatarRadius - 3.0,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0,
      );

      // Draw name/initials pill at bottom
      final double pillWidth = width * 0.95;
      final double pillHeight = width * 0.28;
      final Rect pillRect = Rect.fromCenter(
        center: Offset(width / 2, avatarCenter.dy + avatarRadius),
        width: pillWidth,
        height: pillHeight,
      );
      final RRect pillRRect = RRect.fromRectAndRadius(
        pillRect,
        Radius.circular(pillHeight / 2),
      );

      canvas.drawRRect(
        pillRRect.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black26
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(pillRRect, Paint()..color = Colors.white);
      canvas.drawRRect(
        pillRRect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      TextPainter namePainter = TextPainter(textDirection: TextDirection.ltr);
      namePainter.text = TextSpan(
        text: fallbackText,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w900,
        ),
      );
      namePainter.layout();

      TextPainter? iconPainter;
      if (showLiveWifi || showStaleWifi) {
        iconPainter = TextPainter(textDirection: TextDirection.ltr);
        iconPainter.text = TextSpan(
          text: String.fromCharCode(
            showLiveWifi ? Icons.wifi.codePoint : Icons.wifi_off.codePoint,
          ),
          style: TextStyle(
            fontSize: 26,
            color: showLiveWifi ? Colors.green : Colors.red,
            fontFamily: Icons.wifi.fontFamily,
            package: Icons.wifi.fontPackage,
            fontWeight: FontWeight.w900,
          ),
        );
        iconPainter.layout();
      }

      final double totalTextWidth =
          namePainter.width + (iconPainter != null ? iconPainter.width + 2 : 0);
      final double startX = (width - totalTextWidth) / 2;

      if (iconPainter != null) {
        iconPainter.paint(
          canvas,
          Offset(startX, pillRect.top + (pillHeight - iconPainter.height) / 2),
        );
      }
      namePainter.paint(
        canvas,
        Offset(
          startX + (iconPainter != null ? iconPainter.width + 2 : 0),
          pillRect.top + (pillHeight - namePainter.height) / 2,
        ),
      );

      final ui.Image image = await pictureRecorder.endRecording().toImage(
        width.toInt(),
        height.toInt(),
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } catch (e) {
      debugPrint('Failed to create network image marker: $e');
      return createCustomMarker(
        color: color,
        text: fallbackText.isNotEmpty ? fallbackText[0] : 'U',
        fullName: fallbackText,
        textColor: textColor,
        borderColor: borderColor,
        size: size,
        showLiveWifi: showLiveWifi,
        showStaleWifi: showStaleWifi,
      );
    }
  }

  static Future<BitmapDescriptor> createClusterMarker({
    required int count,
    Color color = Colors.blue,
    double size = 100,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final double radius = size / 2;
    // Draw shadow
    canvas.drawCircle(
      Offset(radius, radius + 4),
      radius - 2,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(radius, radius), radius - 4, paint);
    canvas.drawCircle(Offset(radius, radius), radius - 4, borderPaint);

    // Draw person icon
    final IconData iconData = Icons.person;
    TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size / 2.5,
        color: Colors.white,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
      ),
    );
    iconPainter.layout();

    // Draw text (count)
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: count.toString(),
      style: TextStyle(
        fontSize: size / 2.8,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();

    // Layout side by side
    final double totalWidth = iconPainter.width + 4 + textPainter.width;
    final double startX = (size - totalWidth) / 2;

    iconPainter.paint(canvas, Offset(startX, (size - iconPainter.height) / 2));
    textPainter.paint(
      canvas,
      Offset(startX + iconPainter.width + 4, (size - textPainter.height) / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createNavigationArrowMarker({
    required Color color,
    double size = 60,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final double radius = size / 2.0;

    // Draw navigation arrow shape pointing straight up (0 degrees bearing)
    final Path path = Path();
    path.moveTo(radius, size * 0.1); // Tip of arrow
    path.lineTo(size * 0.8, size * 0.85); // Bottom right
    path.lineTo(radius, size * 0.65); // Indent center
    path.lineTo(size * 0.2, size * 0.85); // Bottom left
    path.close();

    // Draw shadow
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Draw filled path
    canvas.drawPath(path, paint);
    // Draw white border
    canvas.drawPath(path, borderPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createDotMarker({
    required Color color,
    double size = 20,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final double radius = size / 2;
    // Draw shadow
    canvas.drawCircle(
      Offset(radius, radius + 2),
      radius - 2,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(Offset(radius, radius), radius - 2, paint);
    canvas.drawCircle(Offset(radius, radius), radius - 2, borderPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
