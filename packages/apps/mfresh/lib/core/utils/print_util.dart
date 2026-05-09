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
    debugPrint("printToExternal: Initiating process for ${printer.name}");
    
    // Show loading dialog immediately
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFF15A22)),
              SizedBox(height: 16),
              Text("Printing...", style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Run the rest in a microtask to avoid blocking the current frame
    Future.microtask(() async {
      try {
        _cachedProfile ??= await CapabilityProfile.load();
        await Future.delayed(const Duration(milliseconds: 100));

        bool connected = false;
        if (_connectedPrinter != null && _connectedPrinter!.address == printer.address && (printer.isConnected ?? false)) {
          connected = true;
        } else {
          // Attempt direct connection without pre-disconnecting to avoid potential hangs
          connected = await _printerPlugin.connect(printer);
          if (!connected) {
            await Future.delayed(const Duration(seconds: 1));
            connected = await _printerPlugin.connect(printer);
          }
        }

        if (connected) {
          _connectedPrinter = printer;
          if (printer.address != null) {
            Get.find<StorageService>().saveDefaultPrinter(printer.address!, printer.name ?? "BT Printer");
          }
          await Future.delayed(const Duration(milliseconds: 500));

          for (int i = 0; i < booking.services.length; i++) {
            final service = booking.services[i];
            final int qty = int.tryParse(service.quantity) ?? 1;
            
            for (int q = 0; q < qty; q++) {
              // Yield to engine and allow hardware buffer to settle
              await Future.delayed(const Duration(milliseconds: 200)); 
              
              final List<int> bytes = await _generateEscPosBytes(booking, service, rollSize: rollSize);
              
              // Use a safe chunk size (256) to avoid buffer overflow on smaller printers
              await _printerPlugin.printData(printer, bytes, longData: true, chunkSize: 256);
              
              // Give the printer time to actually physicalize the print before sending more
              if (!(i == booking.services.length - 1 && q == qty - 1)) {
                await Future.delayed(const Duration(milliseconds: 2000)); 
              } else {
                // Final delay to ensure last cut command is processed
                await Future.delayed(const Duration(milliseconds: 500));
              }
            }
          }
          AppCommonToastMessage.show(message: "Printing successful", type: ToastType.success);
        } else {
          AppCommonToastMessage.show(message: "Printer connection failed.", type: ToastType.error);
        }
      } catch (e) {
        debugPrint("Print Error: $e");
        AppCommonToastMessage.show(message: "Printer error: $e", type: ToastType.error);
      } finally {
        debugPrint("Print process finished. Cleaning up dialogs...");
        int attempts = 3;
        while (Get.isDialogOpen == true && attempts > 0) {
          Get.back();
          attempts--;
          await Future.delayed(const Duration(milliseconds: 200));
        }
        if (Get.isDialogOpen == true) {
          final context = Get.overlayContext ?? Get.context;
          if (context != null) Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });
  }

  static Future<List<int>> _generateEscPosBytes(BookingDetailsModel booking, ServiceItem service, {int rollSize = 80}) async {
    _cachedProfile ??= await CapabilityProfile.load();
    
    // Determine paper size and column count
    final PaperSize paperSize = rollSize >= 80 ? PaperSize.mm80 : PaperSize.mm58;
    final int maxChars = rollSize >= 80 ? 42 : (rollSize >= 58 ? 32 : 30);
    final generator = Generator(paperSize, _cachedProfile!);
    List<int> bytes = [];

    // Create dynamic separator
    String separator = "-" * maxChars;

    bytes += generator.reset();

    // Header - Centered and Tall
    bytes += [27, 32, 2]; // Set character spacing
    bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size1));
    bytes += [27, 32, 0]; // Reset spacing
    bytes += generator.feed(1);
    
    bytes += [27, 32, 4]; // Increased spacing for Unit Number
    bytes += generator.text("UNIT NO.: ${booking.unitNo}", styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1));
    bytes += [27, 32, 0]; // Reset spacing to prevent separator wrapping
    // Standard size for location text
    bytes += generator.text("Location: ${booking.fullAddress}", styles: const PosStyles(align: PosAlign.left, bold: false));
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));

    // Booking Details
    bytes += generator.text("BOOKING ID: ${booking.bookingId}", styles: const PosStyles(align: PosAlign.left, bold: true));
    bytes += generator.text("Date & Time: ${_formatDate(booking.bookingTimeDate)}", styles: const PosStyles(align: PosAlign.left));

    String paymentModeStr = booking.paymentMode == 1 ? "CASH" : booking.paymentMode == 2 ? "UPI" : "QR";
    bytes += generator.text("Payment: $paymentModeStr", styles: const PosStyles(align: PosAlign.left, bold: false));
    
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));

    // Service & Qty - Standard size
    bytes += generator.text(service.servicesName.toUpperCase(), styles: const PosStyles(bold: true, align: PosAlign.left, height: PosTextSize.size1));
    bytes += generator.text("QTY: 1", styles: const PosStyles(bold: false, align: PosAlign.left));
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));
    bytes += [27, 32, 2]; // Wide spacing for Total
    bytes += generator.text("TOTAL: RS. ${service.price}", styles: const PosStyles(bold: true, align: PosAlign.left, height: PosTextSize.size2, width: PosTextSize.size1));
    bytes += [27, 32, 0]; // Reset spacing
    bytes += generator.text(separator, styles: const PosStyles(align: PosAlign.left));

    // QR Code - Size adjusted for paper width but always left aligned
    final QRSize qrSize = rollSize >= 80 ? QRSize.size6 : QRSize.size4;
    bytes += generator.qrcode(jsonEncode({
      "BookingID": booking.bookingId,
      "DeviceID": "NA",
      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
    }), size: qrSize, align: PosAlign.left);
    
    bytes += generator.feed(1);
    bytes += generator.text("Thank you for using mFresh!", styles: const PosStyles(align: PosAlign.left, bold: true));

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
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text("mFresh", 
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, letterSpacing: 2.0)
                  )
                ),
                pw.SizedBox(height: 12),
                pw.Text("UNIT NO.: ${booking.unitNo}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                pw.Text("Location: ${booking.fullAddress}", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal)),
                pw.Text("---------------------------------------", style: pw.TextStyle(fontSize: 10)),
                
                pw.Text("BOOKING ID: ${booking.bookingId}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text("Date & Time: ${_formatDate(booking.bookingTimeDate)}", style: pw.TextStyle(fontSize: 11)),
                
                pw.Text("Payment: ${booking.paymentMode == 1 ? 'CASH' : booking.paymentMode == 2 ? 'UPI' : 'QR'}", style: pw.TextStyle(fontSize: 11)),
                pw.Text("---------------------------------------", style: pw.TextStyle(fontSize: 10)),

                // Services List
                ...booking.services.map((service) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(service.servicesName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text("QTY: 1", style: pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 6),
                  ]
                )),

                pw.Text("---------------------------------------", style: pw.TextStyle(fontSize: 10)),
                pw.Text("TOTAL: RS. ${booking.totalAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
                pw.Text("---------------------------------------", style: pw.TextStyle(fontSize: 10)),
                
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: jsonEncode({
                      "BookingID": encryptedBookingId ?? booking.bookingId,
                      "DeviceID": "NA",
                      "AccessDate": booking.bookingTimeDate,
                    }),
                    width: 100,
                    height: 100,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text("Thank you for using mFresh!", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
