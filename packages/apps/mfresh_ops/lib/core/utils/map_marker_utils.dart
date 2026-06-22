import 'dart:ui' as ui;
import 'package:core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:core/constants/app_images.dart';

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
    double size = 120, // Increased for wider aspect ratio
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double width = size;
    final double height = size * 0.85; // Slightly shorter than wide

    final Paint paint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Define dimensions for the pill
    final double pillHeight = height * 0.7;
    final double pillRadius = pillHeight / 2;
    final Rect pillRect = Rect.fromLTRB(10, 10, width - 10, 10 + pillHeight);

    // Define the downward pointing triangle
    final double arrowWidth = 20.0;
    final double arrowHeight = 15.0;
    final double centerX = width / 2;
    final double bottomY = 10 + pillHeight;

    final Path path = Path();
    // Start at bottom center (tip of arrow)
    path.moveTo(centerX, bottomY + arrowHeight);
    // Draw right side of arrow
    path.lineTo(centerX + arrowWidth / 2, bottomY);
    // Draw pill shape
    path.addRRect(RRect.fromRectAndRadius(pillRect, Radius.circular(pillRadius)));
    // Draw left side of arrow
    path.moveTo(centerX - arrowWidth / 2, bottomY);
    path.lineTo(centerX, bottomY + arrowHeight);
    path.lineTo(centerX + arrowWidth / 2, bottomY);
    
    // Combine path (the addRRect and arrow paths can be merged)
    final Path combinedPath = Path();
    combinedPath.addRRect(RRect.fromRectAndRadius(pillRect, Radius.circular(pillRadius)));
    
    final Path arrowPath = Path();
    arrowPath.moveTo(centerX - arrowWidth / 2, bottomY - 1); // overlap slightly
    arrowPath.lineTo(centerX + arrowWidth / 2, bottomY - 1);
    arrowPath.lineTo(centerX, bottomY + arrowHeight);
    arrowPath.close();

    final Path finalPath = Path.combine(PathOperation.union, combinedPath, arrowPath);

    // Draw Shadow
    canvas.drawPath(
      finalPath.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Draw Filled Shape
    canvas.drawPath(finalPath, paint);
    
    // Draw Border
    canvas.drawPath(finalPath, borderPaint);

    // Draw text (initials) in the center of the pill
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: pillHeight * 0.45,
        color: textColor,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
    textPainter.layout();
    
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        10 + (pillHeight - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createClusterMarker({
    required int count,
    Color color = Colors.blue,
    double size = 110,
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
      Paint()..color = Colors.black38..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
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

    iconPainter.paint(
      canvas,
      Offset(startX, (size - iconPainter.height) / 2),
    );
    textPainter.paint(
      canvas,
      Offset(startX + iconPainter.width + 4, (size - textPainter.height) / 2),
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

