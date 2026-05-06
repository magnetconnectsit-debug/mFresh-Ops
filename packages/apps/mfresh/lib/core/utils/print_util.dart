import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:services/plutus_service.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mfresh/core/config/app_config.dart';

class PrintUtil {
  static final PlutusService _plutusService = Get.find<PlutusService>();

  /// Shows the selection dialog
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
                subtitle: "Direct Device Printing (Silent)",
                onTap: () {
                  Get.back();
                  for (var service in booking.services) {
                    printInternal(booking, service, encryptedBookingId: encryptedBookingId);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildPrintOption(
                icon: Icons.bluetooth_audio_rounded,
                title: "External Printer",
                subtitle: "Bluetooth Thermal Printer",
                onTap: () {
                  Get.back();
                  _handleBluetoothPrint(context, booking);
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

  /// Silent/Direct Print for Internal Hardware
  static Future<void> printInternal(BookingDetailsModel booking, ServiceItem service, {String? encryptedBookingId}) async {
    try {
      // Ensure service is bound before printing
      await _plutusService.bindToService();

      // Loop through quantity to print separate tickets (matching legacy behavior)
      int repeatCount = int.tryParse(service.quantity.toString()) ?? 1;

      for (int i = 0; i < repeatCount; i++) {
        // Build dynamic print data for this ticket
        Map<String, dynamic> printData = _buildPlutusPrintData(booking, service, encryptedBookingId);

        // Call the Plutus print job
        final result = await _plutusService.startPrintJob(jsonEncode(printData));
        debugPrint("Internal Print Result (Ticket ${i + 1}): $result");

        // Small delay to avoid sending multiple jobs too fast (matching legacy behavior)
        if (repeatCount > 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      debugPrint("Internal Direct Print Error: $e");
      AppCommonToastMessage.show(message: "Direct Print Error: $e", type: ToastType.error);
    }
  }

  /// System Print Dialog
  static Future<void> _handleBluetoothPrint(BuildContext context, BookingDetailsModel booking) async {
    // Request Permissions
    final status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (status[Permission.bluetoothConnect]?.isGranted != true) {
      AppCommonToastMessage.show(message: "Bluetooth permissions required", type: ToastType.error);
      return;
    }

    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isEnabled) {
      AppCommonToastMessage.show(message: "Please turn on Bluetooth", type: ToastType.error);
      return;
    }

    if (!context.mounted) return;

    // Show Scanning Dialog
    _showBluetoothDeviceSelector(context, booking);
  }

  static void _showBluetoothDeviceSelector(BuildContext context, BookingDetailsModel booking) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Printer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FutureBuilder<List<BluetoothInfo>>(
                future: PrintBluetoothThermal.pairedBluetooths,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No paired devices found");
                  }
                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final device = snapshot.data![index];
                        return ListTile(
                          leading: const Icon(Icons.print_outlined),
                          title: Text(device.name),
                          subtitle: Text(device.macAdress),
                          onTap: () async {
                            Get.back();
                            _printViaBluetooth(booking, device.macAdress);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () => Get.back(), child: const Text("Close")),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _printViaBluetooth(BookingDetailsModel booking, String mac) async {
    try {
      final bool connected = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      if (!connected) {
        AppCommonToastMessage.show(message: "Connection failed", type: ToastType.error);
        return;
      }

      final List<int> bytes = [];
      bytes.addAll([0x1B, 0x40]); // Initialize
      bytes.addAll([0x1B, 0x61, 0x01]); // Align Center
      bytes.addAll(utf8.encode("MAGNET CONNECTS\n"));
      bytes.addAll(utf8.encode("Booking Confirmation\n\n"));
      
      bytes.addAll([0x1B, 0x61, 0x00]); // Align Left
      bytes.addAll(utf8.encode("Booking ID: ${booking.bookingId}\n"));
      bytes.addAll(utf8.encode("Unit No: ${booking.unitNo}\n"));
      bytes.addAll(utf8.encode("Amount: Rs. ${booking.totalAmount}\n"));
      bytes.addAll(utf8.encode("Date: ${_formatDate(booking.bookingTimeDate)}\n"));
      bytes.addAll(utf8.encode("--------------------------------\n"));
      
      bytes.addAll(utf8.encode("SERVICES:\n"));
      for (var s in booking.services) {
        bytes.addAll(utf8.encode("- ${s.servicesName} x${s.quantity}\n"));
      }
      bytes.addAll(utf8.encode("--------------------------------\n"));
      bytes.addAll(utf8.encode("\n\nThank You!\n\n\n\n"));

      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      if (result) {
        AppCommonToastMessage.show(message: "Printing success", type: ToastType.success);
      } else {
        AppCommonToastMessage.show(message: "Printing failed", type: ToastType.error);
      }
      
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      AppCommonToastMessage.show(message: "Bluetooth Error: $e", type: ToastType.error);
    }
  }

  static Future<void> printSystem(BookingDetailsModel booking, String? encryptedBookingId) async {
    try {
      final doc = await _generateDocument(booking, encryptedBookingId);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'receipt_${booking.bookingId}',
      );
    } catch (e) {
      debugPrint("System Print Error: $e");
    }
  }

  static Future<pw.Document> _generateDocument(BookingDetailsModel booking, String? encryptedBookingId) async {
    final doc = pw.Document();
    const rollFormat = PdfPageFormat(58 * PdfPageFormat.mm, double.infinity, marginAll: 0);

    doc.addPage(
      pw.Page(
        pageFormat: rollFormat,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text("MAGNET CONNECTS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))),
                pw.Center(child: pw.Text("Booking Confirmation", style: const pw.TextStyle(fontSize: 9))),
                pw.SizedBox(height: 8),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 4),
                pw.Text("Booking ID: ${booking.bookingId}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text("Unit No: ${booking.unitNo}", style: const pw.TextStyle(fontSize: 9)),
                pw.Text("Date: ${_formatDate(booking.bookingTimeDate)}", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL AMOUNT:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text("Rs. ${booking.totalAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 4),
                pw.Text("SERVICES:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                for (var s in booking.services)
                   pw.Padding(
                     padding: const pw.EdgeInsets.only(top: 2),
                     child: pw.Text("- ${s.servicesName} x${s.quantity}", style: const pw.TextStyle(fontSize: 9)),
                   ),
                pw.SizedBox(height: 4),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 12),
                pw.Center(child: pw.Text("SCAN QR AT UNIT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: jsonEncode({
                      "BookingID": encryptedBookingId ?? booking.bookingId,
                      "DeviceID": "NA",
                      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
                    }),
                    width: 110,
                    height: 110,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text("Thank You! Visit Again", style: const pw.TextStyle(fontSize: 9))),
                pw.SizedBox(height: 30),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          );
        },
      ),
    );
    return doc;
  }

  static Map<String, dynamic> _buildPlutusPrintData(BookingDetailsModel booking, ServiceItem service, String? encryptedBookingId) {
    List<Map<String, dynamic>> printItems = [];

    // Title
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Booking Confirmation", "ImagePath": "0", "ImageData": "0"});

    // Booking ID
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Booking ID: ${booking.bookingId}", "ImagePath": "0", "ImageData": "0"});

    // Unit No.
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Unit No.: ${booking.unitNo}", "ImagePath": "0", "ImageData": "0"});

    // Amount Paid
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Amount Paid: Rs. ${booking.totalAmount}", "ImagePath": "0", "ImageData": "0"});

    // Date & Time
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Date & Time: ${_formatDate(booking.bookingTimeDate)}", "ImagePath": "0", "ImageData": "0"});

    // Payment Mode
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Payment Mode: ${booking.paymentMode == 3 ? 'External QR' : booking.paymentMode == 2 ? 'Online' : 'Cash'}", "ImagePath": "0", "ImageData": "0"});

    // Separator
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "------------------------", "ImagePath": "0", "ImageData": "0"});

    // Service Name
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Service: ${service.servicesName} x1", "ImagePath": "0", "ImageData": "0"});

    // Location
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Location: ${booking.fullAddress}", "ImagePath": "0", "ImageData": "0"});

    // QR Section Title
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Scan QR at Unit", "ImagePath": "0", "ImageData": "0"});

    // QR Code
    printItems.add({
      "PrintDataType": "4",
      "PrinterWidth": 24,
      "IsCenterAligned": true,
      "DataToPrint": jsonEncode({
        "BookingID": booking.bookingId, // Matches legacy code: uses raw bookingId
        "DeviceID": "NA",
        "AccessDate": _formatDateRaw(booking.bookingTimeDate),
      }),
      "ImagePath": "",
      "ImageData": ""
    });

    // Spacing
    for (int i = 0; i < 2; i++) {
      printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": " ", "ImagePath": "0", "ImageData": "0"});
    }

    // Thank You
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Thank You!", "ImagePath": "0", "ImageData": "0"});

    // Extra Feed for tear space
    for (int i = 0; i < 4; i++) {
      printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": " ", "ImagePath": "0", "ImageData": "0"});
    }

    return {
      "Header": {
        "ApplicationId": AppConfig.applicationId,
        "UserId": "user1234",
        "MethodId": "1002",
        "VersionNo": "1.0"
      },
      "Detail": {
        "PrintRefNo": booking.bookingId,
        "SavePrintData": false,
        "Data": printItems
      }
    };
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
