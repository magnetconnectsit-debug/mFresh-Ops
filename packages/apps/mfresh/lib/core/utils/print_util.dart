import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:services/plutus_service.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mfresh/core/config/app_config.dart';

class PrintUtil {
  static final PlutusService _plutusService = Get.find<PlutusService>();

  /// Shows a simplified dialog for internal or external printing
  static void showPrintSelectionDialog({
    required BuildContext context,
    required BookingDetailsModel booking,
    String? encryptedBookingId,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Receipt Printer",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Select printer destination",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildPrintOption(
                icon: Icons.print_rounded,
                title: "Internal Printer",
                subtitle: "PineLabs / Built-in Device",
                onTap: () {
                  Get.back();
                  printInternal(booking, encryptedBookingId);
                },
              ),
              const SizedBox(height: 16),
              _buildPrintOption(
                icon: Icons.settings_suggest_rounded,
                title: "External Printer",
                subtitle: "Standard Android Print Dialog",
                onTap: () {
                  Get.back();
                  printSystem(booking, encryptedBookingId);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// System Print Dialog (The Standard Android Method)
  static Future<void> printSystem(BookingDetailsModel booking, String? encryptedBookingId) async {
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll57,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text("MAGNET CONNECTS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Center(child: pw.Text("Booking Confirmation")),
                pw.Divider(),
                pw.Text("Booking ID: ${booking.bookingId}"),
                pw.Text("Unit No: ${booking.unitNo}"),
                pw.Text("Date: ${_formatDate(booking.bookingTimeDate)}"),
                pw.Text("Total: Rs. ${booking.totalAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text("SERVICES:"),
                for (var s in booking.services)
                   pw.Text("- ${s.servicesName} x${s.quantity}"),
                pw.Divider(),
                pw.Center(child: pw.Text("Scan QR at Unit")),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: jsonEncode({
                      "BookingID": encryptedBookingId ?? booking.bookingId,
                      "DeviceID": "NA",
                      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
                    }),
                    width: 100,
                    height: 100,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text("Thank You!")),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'booking_receipt_${booking.bookingId}',
      );
    } catch (e) {
      debugPrint("System Print Error: $e");
    }
  }

  static Widget _buildPrintOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF15A22).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFF15A22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static Future<void> printInternal(BookingDetailsModel booking, String? encryptedBookingId) async {
    try {
      for (var service in booking.services) {
        int repeatCount = int.tryParse(service.quantity) ?? 1;
        for (int i = 0; i < repeatCount; i++) {
          final printData = _buildPlutusPrintData(booking, service, encryptedBookingId);
          await _plutusService.startPrintJob(jsonEncode(printData));
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      debugPrint("PineLabs Print Error: $e");
    }
  }

  static Map<String, dynamic> _buildPlutusPrintData(BookingDetailsModel booking, ServiceItem service, String? encryptedBookingId) {
    List<Map<String, dynamic>> printItems = [];
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Booking Confirmation"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Booking ID: ${booking.bookingId}"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Unit No.: ${booking.unitNo}"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Amount: Rs. ${booking.totalAmount}"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Date: ${_formatDate(booking.bookingTimeDate)}"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "------------------------"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Service: ${service.servicesName} x${service.quantity}"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Scan QR at Unit"});
    printItems.add({
      "PrintDataType": "4",
      "PrinterWidth": 24,
      "IsCenterAligned": true,
      "DataToPrint": jsonEncode({
        "BookingID": encryptedBookingId ?? booking.bookingId,
        "DeviceID": "NA",
        "AccessDate": _formatDateRaw(booking.bookingTimeDate),
      }),
    });
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "\nThank You!\n\n\n\n"});

    return {
      "Header": {
        "ApplicationId": AppConfig.applicationId,
        "UserId": "user1234",
        "MethodId": "1002",
        "VersionNo": "1.0",
      },
      "Detail": {
        "PrintRefNo": booking.bookingId,
        "SavePrintData": false,
        "Data": printItems
      }
    };
  }

  static String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String _formatDateRaw(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toLocal());
    } catch (e) {
      return dateString;
    }
  }
}
