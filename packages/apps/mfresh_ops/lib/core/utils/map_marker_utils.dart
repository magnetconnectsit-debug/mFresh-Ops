import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerUtils {
  static Future<BitmapDescriptor> createAssetMarker(String assetPath, {int width = 100}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
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

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createCustomMarker({
    required Color color,
    required String text,
    Color textColor = Colors.white,
    double size = 80,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final double radius = size / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size / 2.5,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
    painter.layout();
    
    painter.paint(
      canvas,
      Offset((size - painter.width) / 2, (size - painter.height) / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createNavigationArrowMarker({
    required Color color,
    double size = 100,
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

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createDotMarker({
    required Color color,
    double size = 30,
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
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
    );
    canvas.drawCircle(Offset(radius, radius), radius - 2, paint);
    canvas.drawCircle(Offset(radius, radius), radius - 2, borderPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}

