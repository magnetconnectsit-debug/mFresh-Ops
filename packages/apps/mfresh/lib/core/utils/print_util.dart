import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart' as sys_print;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:services/plutus_service.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_images.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:services/storage_service.dart';
import 'printer_dialog_util.dart';

class PrintUtil {
  static final PlutusService _plutusService = Get.find<PlutusService>();
  static final _printerPlugin = FlutterThermalPrinter.instance;
  static CapabilityProfile? _cachedProfile;
  static Printer? _connectedPrinter;

  /// Silent/Direct Print for Internal Hardware (PineLabs / Udyama / etc.)
  static Future<void> printInternal(BookingDetailsModel booking, ServiceItem service, {String? encryptedBookingId}) async {
    try {
      debugPrint("Attempting internal print via Plutus...");
      await _plutusService.bindToService();
      int repeatCount = int.tryParse(service.quantity.toString()) ?? 1;

      for (int i = 0; i < repeatCount; i++) {
        Map<String, dynamic> printData = _buildPlutusPrintData(booking, service, encryptedBookingId);
        final result = await _plutusService.startPrintJob(jsonEncode(printData));
        debugPrint("Internal Print Result (Ticket ${i + 1}): $result");

        if (repeatCount > 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      debugPrint("Internal Direct Print Error (Likely non-PineLabs device): $e");
      // Fallback to External Printer Discovery for Udyama/Sunmi/Other POS
      AppCommonToastMessage.show(
        message: "Built-in printer not detected. Opening printer selector...",
        type: ToastType.info,
      );
      if (Get.context != null) {
        handleExternalPrint(Get.context!, booking, useDefault: true);
      }
    }
  }

  /// Handle External Printer Discovery logic
  static Future<void> handleExternalPrint(BuildContext context, BookingDetailsModel booking, {bool useDefault = false, int rollSize = 80}) async {
    // Request Permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (!context.mounted) return;
    
    if (useDefault) {
      final storage = Get.find<StorageService>();
      final defaultAddress = storage.getDefaultPrinterAddress();
      
      if (defaultAddress != null) {
        // 1. If already connected to this default printer, print immediately
        if (_connectedPrinter != null && 
            _connectedPrinter!.address == defaultAddress && 
            (_connectedPrinter!.isConnected ?? false)) {
          printToExternal(booking, _connectedPrinter!, rollSize: rollSize);
          return;
        }

        // 2. Otherwise, try to find the printer in a quick scan
        _attemptDefaultPrint(context, booking, defaultAddress, rollSize: rollSize);
        return;
      }
    }
    
    PrinterDialogUtil.showExternalDeviceSelector(context, booking, rollSize: rollSize);
  }

  static void _attemptDefaultPrint(BuildContext context, BookingDetailsModel booking, String address, {int rollSize = 80}) {
    AppCommonToastMessage.show(message: "Connecting to default printer...", type: ToastType.info);
    
    // We need to scan briefly to get the Printer object
    StreamSubscription? sub;
    bool found = false;
    
    Timer(const Duration(seconds: 5), () {
      if (!found) {
        sub?.cancel();
        AppCommonToastMessage.show(message: "Default printer not found. Please select manually.", type: ToastType.warning);
        PrinterDialogUtil.showExternalDeviceSelector(context, booking, rollSize: rollSize);
      }
    });

    sub = _printerPlugin.devicesStream.listen((printers) {
      final printer = printers.where((p) => p.address == address).firstOrNull;
      if (printer != null && !found) {
        found = true;
        sub?.cancel();
        printToExternal(booking, printer, rollSize: rollSize);
      }
    });
    _printerPlugin.getPrinters(connectionTypes: [ConnectionType.BLE, ConnectionType.USB, ConnectionType.NETWORK]);
  }

  /// Core logic for printing to thermal devices
  static Future<void> printToExternal(BookingDetailsModel booking, Printer printer, {int rollSize = 80}) async {
    // Show a persistent loading indicator
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFF15A22)),
              SizedBox(height: 16),
              Text("Printing...", style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // 1. Optimized Connection (Skip if already connected to this printer)
      bool connected = false;
      
      // If we think we are already connected to this printer, skip the connect call
      if (_connectedPrinter != null && _connectedPrinter!.address == printer.address && (printer.isConnected ?? false)) {
        connected = true;
      } else {
        // 1a. Clear any lingering stale connection for this specific printer
        try { await _printerPlugin.disconnect(printer); } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // 1b. Attempt connection with retry and longer delays
        connected = await _printerPlugin.connect(printer);
        if (!connected) {
          debugPrint("First connection attempt failed. Retrying in 2 seconds...");
          await Future.delayed(const Duration(seconds: 2));
          connected = await _printerPlugin.connect(printer);
        }

        if (!connected) {
          debugPrint("Second connection attempt failed. Final retry in 3 seconds...");
          await Future.delayed(const Duration(seconds: 3));
          connected = await _printerPlugin.connect(printer);
        }
      }

      if (connected) {
        _connectedPrinter = printer;
        if (printer.address != null) {
          final displayName = printer.name != null && printer.name!.isNotEmpty
              ? printer.name!
              : "BT Printer (${printer.address?.split(':').last ?? '...' })";
          // Save both as last used and default for direct printing
          final storage = Get.find<StorageService>();
          storage.saveLastPrinter(printer.address!, displayName);
          storage.saveDefaultPrinter(printer.address!, displayName);
        }
      }

      if (!connected) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        AppCommonToastMessage.show(message: "Printer connection failed.", type: ToastType.error);
        return;
      }

      // 2. Extended stabilization delay for BLE
      await Future.delayed(const Duration(milliseconds: 1000));

      // 3. Print each service separately
      for (int i = 0; i < booking.services.length; i++) {
        final service = booking.services[i];
        final int qty = int.tryParse(service.quantity) ?? 1;
        
        for (int q = 0; q < qty; q++) {
          final List<int> bytes = await _generateEscPosBytes(booking, service, rollSize: rollSize);
          
          // Use built-in longData handling for better stability
          await _printerPlugin.printData(printer, bytes, longData: true, chunkSize: 128);
          
          bool isLastReceipt = (i == booking.services.length - 1) && (q == qty - 1);
          if (!isLastReceipt) {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      AppCommonToastMessage.show(message: "Printing successful", type: ToastType.success);
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint("External Print Error: $e");
      AppCommonToastMessage.show(message: "Printer error: $e", type: ToastType.error);
    }
  }

  static Future<List<int>> _generateEscPosBytes(BookingDetailsModel booking, ServiceItem service, {int rollSize = 80}) async {
    _cachedProfile ??= await CapabilityProfile.load();
    
    // Support for 56mm, 58mm, and 80mm
    final PaperSize paperSize = rollSize == 80 ? PaperSize.mm80 : PaperSize.mm58;
    final generator = Generator(paperSize, _cachedProfile!);
    List<int> bytes = [];

    // Adjust separators based on roll size
    String separator = "--------------------------------"; // 80mm default
    if (rollSize == 58) separator = "----------------------------";
    if (rollSize == 56) separator = "--------------------------";

    bytes += generator.reset();

    bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.feed(1);
    
    bytes += [27, 32, 2]; // Set character spacing
    bytes += generator.text("UNIT NO.: ${booking.unitNo}", styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size2));
    bytes += generator.text("Location: ${booking.fullAddress}", styles: const PosStyles(align: PosAlign.left, bold: true));
    bytes += [27, 32, 0]; // Reset
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));

    // Booking Details
    bytes += generator.text("BOOKING ID: ${booking.bookingId}", styles: const PosStyles(align: PosAlign.left, bold: true));
    bytes += generator.text("Date & Time: ${_formatDate(booking.bookingTimeDate)}", styles: const PosStyles(align: PosAlign.left));

    String paymentModeStr = booking.paymentMode == 1 ? "CASH" : booking.paymentMode == 2 ? "UPI" : "QR";
    bytes += generator.text("Payment: $paymentModeStr", styles: const PosStyles(align: PosAlign.left, bold: true));
    
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));

    // Service & Qty
    bytes += generator.text("${service.servicesName.toUpperCase()}", styles: const PosStyles(bold: true, align: PosAlign.left, height: PosTextSize.size2));
    bytes += generator.text("QTY: 1", styles: const PosStyles(bold: true, align: PosAlign.left));
    bytes += generator.text("Unit Price: RS. ${service.price}", styles: const PosStyles(align: PosAlign.left, bold: true));

    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text("TOTAL: RS. ${service.price}", styles: const PosStyles(bold: true, align: PosAlign.left, height: PosTextSize.size2));
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));

    bytes += generator.qrcode(jsonEncode({
      "BookingID": booking.bookingId,
      "DeviceID": "NA",
      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
    }), size: QRSize.size4, align: PosAlign.left);
    
    bytes += generator.feed(1);
    bytes += generator.text("Thank you for using mFresh!", styles: const PosStyles(align: PosAlign.left));

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  static Future<void> printSystem(BookingDetailsModel booking, String? encryptedBookingId, {int rollSize = 58}) async {
    try {
      final doc = await _generateDocument(booking, encryptedBookingId, rollSize: rollSize);
      await sys_print.Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'receipt_${booking.bookingId}',
      );
    } catch (e) {
      debugPrint("System Print Error: $e");
      AppCommonToastMessage.show(message: "System print failed: $e", type: ToastType.error);
    }
  }

  static Future<void> shareSystem(BookingDetailsModel booking, String? encryptedBookingId, {int rollSize = 58}) async {
    try {
      debugPrint("Generating PDF for sharing...");
      final doc = await _generateDocument(booking, encryptedBookingId, rollSize: rollSize);
      final bytes = await doc.save();
      
      debugPrint("Sharing PDF (${bytes.length} bytes)...");
      await sys_print.Printing.sharePdf(
        bytes: bytes,
        filename: 'receipt_${booking.bookingId}.pdf',
      );
    } catch (e) {
      debugPrint("System Share Error: $e");
      AppCommonToastMessage.show(message: "Failed to share receipt: $e", type: ToastType.error);
    }
  }

  static Future<pw.Document> _generateDocument(BookingDetailsModel booking, String? encryptedBookingId, {int rollSize = 58}) async {
    final doc = pw.Document();
    final rollFormat = PdfPageFormat(rollSize * PdfPageFormat.mm, double.infinity, marginAll: 0);

    final ByteData logoData = await rootBundle.load(AppImages.mFreshLogo);
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    doc.addPage(
      pw.Page(
        pageFormat: rollFormat,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Image(logoImage, width: 100)),
                pw.SizedBox(height: 5),
                pw.Text("UNIT NO.: ${booking.unitNo}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text("Location: ${booking.fullAddress}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text("-----------------------------------------"),
                pw.Text("BOOKING ID: ${booking.bookingId}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                pw.Text("Date & Time: ${_formatDate(booking.bookingTimeDate)}", style: const pw.TextStyle(fontSize: 11)),
                pw.Text("-----------------------------------------"),
                pw.Text("TOTAL: RS. ${booking.totalAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 15),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: jsonEncode({
                      "BookingID": encryptedBookingId ?? booking.bookingId,
                      "DeviceID": "NA",
                      "AccessDate": booking.bookingTimeDate,
                    }),
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc;
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

  static Map<String, dynamic> _buildPlutusPrintData(BookingDetailsModel booking, ServiceItem service, String? encryptedBookingId) {
    return {
      "bookingId": booking.bookingId,
      "unitNo": booking.unitNo,
      "amount": booking.totalAmount,
      "service": service.servicesName,
      "qrData": jsonEncode({
        "BookingID": encryptedBookingId ?? booking.bookingId,
        "DeviceID": "NA",
        "AccessDate": booking.bookingTimeDate,
      }),
    };
  }
}
