import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerUtils {
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
}
