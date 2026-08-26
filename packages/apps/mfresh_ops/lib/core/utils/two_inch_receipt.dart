import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mfresh_ops/data/models/booking_details_model.dart';
import 'package:intl/intl.dart';
import 'package:core/constants/app_images.dart';

class TwoInchReceipt {
  static String _formatReceiptDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static Future<List<int>> generateEscPosBytes(
    BookingDetailsModel booking,
    ServiceItem service,
    CapabilityProfile profile, {
    String? encryptedBookingId,
  }) async {
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final PosAlign align = PosAlign.center;
    final PosAlign centerAlign = PosAlign.center;
    final int maxChars = 30; 
    String separator = "-" * maxChars;

    bytes += generator.reset();

    // Header
    bytes += [27, 32, 2];
    bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += [27, 32, 0];

    bytes += [27, 32, 4];
    bytes += generator.text("UNIT NO.: ${booking.unitNo}", styles: PosStyles(align: align, bold: true, height: PosTextSize.size1));
    bytes += [27, 32, 0];
    
    bytes += generator.text("Location: ${booking.fullAddress}", styles: PosStyles(align: align));
    bytes += generator.text(separator, styles: PosStyles(align: centerAlign));

    bytes += generator.text("BOOKING ID: ${booking.bookingId}", styles: PosStyles(align: align, bold: true));
    final printDate = booking.bookingTimeDate.isNotEmpty ? _formatReceiptDate(booking.bookingTimeDate) : DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now());
    bytes += generator.text("Date & Time: $printDate", styles: PosStyles(align: align));
    
    String paymentModeStr = booking.paymentMode == 1 ? "CASH" : booking.paymentMode == 2 ? "UPI" : "QR";
    bytes += generator.text("Payment: $paymentModeStr", styles: PosStyles(align: align));
    bytes += generator.text(separator, styles: PosStyles(align: centerAlign));

    bytes += generator.text(service.servicesName.toUpperCase(), styles: PosStyles(bold: true, align: align, height: PosTextSize.size1));
    bytes += generator.text("QTY: 1", styles: PosStyles(align: align));
    bytes += generator.text(separator, styles: PosStyles(align: centerAlign));
    
    final finalPrice = service.price.isNotEmpty ? service.price : booking.totalAmount;
    bytes += [27, 32, 2];
    bytes += generator.text("TOTAL: RS. $finalPrice", styles: PosStyles(bold: true, align: align, height: PosTextSize.size2, width: PosTextSize.size1));
    bytes += [27, 32, 0];
    bytes += generator.text(separator, styles: PosStyles(align: centerAlign));

    bytes += generator.qrcode(
      jsonEncode({
        "BookingID": encryptedBookingId ?? booking.encryptBookingId ?? booking.bookingId,
        "DeviceID": "NA",
        "AccessDate": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      }),
      size: QRSize.size4,
      cor: QRCorrection.M,
      align: centerAlign,
    );

    bytes += generator.feed(1);
    bytes += generator.text("Thank you for using mFresh!", styles: PosStyles(align: centerAlign, bold: true));
    bytes += generator.text(separator, styles: PosStyles(align: centerAlign));

    bytes += generator.cut();

    return bytes;
  }

  static Future<pw.Document> generateDocument(
    BookingDetailsModel booking,
    String? encryptedBookingId,
  ) async {
    final doc = pw.Document();
    final rollFormat = const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity, marginAll: 0);
    final ByteData logoData = await rootBundle.load(AppImages.mFreshLogo);
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);
    final String pdfSeparator = "-" * 28;

    for (int i = 0; i < booking.services.length; i++) {
      final service = booking.services[i];
      final int qty = int.tryParse(service.quantity.toString()) ?? 1;
      for (int q = 0; q < qty; q++) {
        final finalPrice = service.price.isNotEmpty ? service.price : booking.totalAmount;
        doc.addPage(
          pw.Page(
            pageFormat: rollFormat,
            build: (pw.Context context) {
              return pw.Padding(
                padding: pw.EdgeInsets.only(left: 0, right: 8, top: 2, bottom: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Image(logoImage, width: 20, height: 20),
                          pw.SizedBox(height: 2),
                          pw.Text("mFresh", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, letterSpacing: 2.0))
                        ]
                      )
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text("UNIT NO.: ${booking.unitNo}", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
                    pw.Text("Location: ${booking.fullAddress}", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.normal)),
                    pw.Text(pdfSeparator, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),
                    
                    pw.Text("BOOKING ID: ${booking.bookingId}", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text("Date & Time: ${booking.bookingTimeDate.isNotEmpty ? _formatReceiptDate(booking.bookingTimeDate) : DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),
                    
                    pw.Text("Payment: ${booking.paymentMode == 1 ? 'CASH' : booking.paymentMode == 2 ? 'UPI' : 'QR'}", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),
                    pw.Text(pdfSeparator, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),

                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(service.servicesName.toUpperCase(), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.Text("QTY: 1", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),
                        pw.SizedBox(height: 2),
                      ]
                    ),

                    pw.Text(pdfSeparator, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),
                    pw.Text("TOTAL: RS. $finalPrice", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
                    pw.Text(pdfSeparator, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8)),
                    
                    pw.SizedBox(height: 4),
                    pw.Center(
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high),
                        data: jsonEncode({
                          "BookingID": encryptedBookingId ?? booking.encryptBookingId ?? booking.bookingId,
                          "DeviceID": "NA",
                          "AccessDate": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                        }),
                        width: 100,
                        height: 100,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Center(
                      child: pw.Text("Thank you for using mFresh!", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    }
    return doc;
  }
}
