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
import 'package:core/widgets/custom_app_loader.dart';

class PrintUtil {
  static final PlutusService _plutusService = Get.find<PlutusService>();
  static final _printerPlugin = FlutterThermalPrinter.instance;
  static CapabilityProfile? _cachedProfile;
  static Printer? _connectedPrinter;
  static String? lastFailedAddress;

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
        handleExternalPrint(Get.context!, booking, useDefault: true, encryptedBookingId: encryptedBookingId);
      }
    }
  }

  /// Handle External Printer Discovery logic
  static Future<void> handleExternalPrint(BuildContext context, BookingDetailsModel booking, {bool useDefault = false, int rollSize = 80, String? encryptedBookingId}) async {
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
          final success = await printToExternal(booking, _connectedPrinter!, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
          if (!success) {
            debugPrint("Default printer connected but failed to print, opening selector...");
            await Future.delayed(const Duration(milliseconds: 300));
            if (context.mounted) {
              PrinterDialogUtil.showExternalDeviceSelector(context, booking, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
            } else {
              debugPrint("Context not mounted, cannot show selector.");
            }
          }
          return;
        }

        // 2. Otherwise, try to find the printer in a quick scan
        _attemptDefaultPrint(context, booking, defaultAddress, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
        return;
      }
    }
    
    PrinterDialogUtil.showExternalDeviceSelector(context, booking, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
  }

  static void _attemptDefaultPrint(BuildContext context, BookingDetailsModel booking, String address, {int rollSize = 80, String? encryptedBookingId}) {
    AppCommonToastMessage.show(message: "Connecting to default printer...", type: ToastType.info);
    
    // We need to scan briefly to get the Printer object
    StreamSubscription? sub;
    Timer? timeoutTimer;
    bool found = false;
    bool attemptInProgress = false;
    
    timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (!found && !attemptInProgress) {
        sub?.cancel();
        debugPrint("Default printer search timed out.");
        AppCommonToastMessage.show(message: "Default printer not found. Please select manually.", type: ToastType.warning);
        PrinterDialogUtil.showExternalDeviceSelector(context, booking, rollSize: rollSize);
      }
    });

    sub = _printerPlugin.devicesStream.listen((printers) async {
      final printer = printers.where((p) => p.address == address).firstOrNull;
      if (printer != null && !found) {
        found = true;
        attemptInProgress = true;
        timeoutTimer?.cancel(); // CANCEL TIMER IMMEDIATELY
        sub?.cancel();
        
        final success = await printToExternal(booking, printer, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
        attemptInProgress = false;
        
        if (!success) {
          debugPrint("Target printer failed, opening selector dialog now...");
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            PrinterDialogUtil.showExternalDeviceSelector(context, booking, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
          } else {
            debugPrint("Context not mounted, cannot show selector.");
          }
        }
      }
    });
    _printerPlugin.getPrinters(connectionTypes: [ConnectionType.BLE, ConnectionType.USB, ConnectionType.NETWORK]);
  }

  /// Core logic for printing to thermal devices
  static Future<bool> printToExternal(BookingDetailsModel booking, Printer printer, {int rollSize = 80, String? encryptedBookingId}) async {
    debugPrint("printToExternal: Initiating process for ${printer.name}");
    
    // Show loading dialog immediately
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomAppLoader(size: 60),
              SizedBox(height: 16),
              Text("Printing...", style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      _cachedProfile ??= await CapabilityProfile.load();
      await Future.delayed(const Duration(milliseconds: 100));

      bool connected = false;
      debugPrint("Checking existing connection for ${printer.address}...");
      
      if (_connectedPrinter != null && _connectedPrinter!.address == printer.address && (printer.isConnected ?? false)) {
        debugPrint("Already connected to ${printer.address}. Using existing session.");
        connected = true;
      } else {
        debugPrint("No valid existing connection. Attempting fresh connect to ${printer.address}...");
        
        // Manual cleanup before connect can help some BLE stacks
        try {
          debugPrint("Pre-emptive disconnect for ${printer.address}...");
          await _printerPlugin.disconnect(printer).timeout(const Duration(seconds: 2));
        } catch (_) {}

        try {
          debugPrint("Calling _printerPlugin.connect...");
          connected = await _printerPlugin
              .connect(printer)
              .timeout(const Duration(seconds: 12));
          debugPrint("Connection result for ${printer.address}: $connected");
        } catch (e) {
          debugPrint("Connection timeout/error for ${printer.address}: $e");
          connected = false;
        }
      }

      if (connected) {
        debugPrint("Connection established. Waiting for BLE handshake (1.5s)...");
        // Wait for BLE handshake to fully settle before sending data
        await Future.delayed(const Duration(milliseconds: 1500)); 
        
        _connectedPrinter = printer;
        lastFailedAddress = null; // Clear failure state on success
        if (printer.address != null) {
          Get.find<StorageService>().saveDefaultPrinter(printer.address!, printer.name ?? "BT Printer");
        }
        debugPrint("Handshake finished. Ready to send data.");
        await Future.delayed(const Duration(milliseconds: 500));

        for (int i = 0; i < booking.services.length; i++) {
          final service = booking.services[i];
          final int qty = int.tryParse(service.quantity) ?? 1;
          
          for (int q = 0; q < qty; q++) {
            // Yield to engine and allow hardware buffer to settle
            await Future.delayed(const Duration(milliseconds: 200)); 
            
            final List<int> bytes = await _generateEscPosBytes(booking, service, rollSize: rollSize, encryptedBookingId: encryptedBookingId);
            
            // Reduced chunk size to 128 for better BLE reliability
            debugPrint("Sending data to printer (Chunk: 128)...");
            try {
              // Add a timeout to printing to prevent hanging the UI
              await _printerPlugin
                  .printData(printer, bytes, longData: true, chunkSize: 128)
                  .timeout(const Duration(seconds: 15));
            } catch (e) {
              debugPrint("Data transmission error: $e");
              _connectedPrinter = null; // Clear state so we reconnect next time
              return false;
            }
            
            if (!(i == booking.services.length - 1 && q == qty - 1)) {
              debugPrint("Receipt printed. Pausing 4 seconds for tearing...");
              await Future.delayed(const Duration(seconds: 4)); 
            } else {
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }

        AppCommonToastMessage.show(message: "Printing successful", type: ToastType.success);
        return true;
      } else {
        debugPrint("Connection failed, clearing printer states...");
        _connectedPrinter = null;
        lastFailedAddress = printer.address;
        Get.find<StorageService>().clearDefaultPrinter();
        AppCommonToastMessage.show(message: "Printer connection failed. Please select again.", type: ToastType.error);
        return false;
      }
    } catch (e) {
      debugPrint("Print Error Caught in printToExternal: $e");
      final errorStr = e.toString();
      if (errorStr.contains("deviceNotFound") || errorStr.contains("DEVICE_NOT_FOUND") || errorStr.contains("133")) {
        debugPrint("Explicitly caught DEVICE_NOT_FOUND or GATT error");
        lastFailedAddress = printer.address;
        Get.find<StorageService>().clearDefaultPrinter();
        AppCommonToastMessage.show(message: "Printer connection lost. Please select again.", type: ToastType.warning);
      } else {
        AppCommonToastMessage.show(message: "Printer error: $e", type: ToastType.error);
      }
      return false;
    } finally {
      debugPrint("Print process finished. Cleaning up loading dialogs...");
      
      // Use Navigator.pop specifically for dialogs to avoid hitting snackbars
      // which causes "Cannot remove entry from a disposed snackbar" crash in GetX.
      // We check Get.isDialogOpen to ensure we only pop if a dialog is actually present.
      if (Get.isDialogOpen == true) {
        try {
          Navigator.of(Get.context!, rootNavigator: true).pop();
        } catch (e) {
          debugPrint("Error popping dialog: $e");
          // Fallback if context is invalid
          if (Get.isDialogOpen == true) Get.back();
        }
      }
      
      // Safety delay to ensure GetX stack is settled
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  static Future<List<int>> _generateEscPosBytes(BookingDetailsModel booking, ServiceItem service, {int rollSize = 80, String? encryptedBookingId}) async {
    _cachedProfile ??= await CapabilityProfile.load();
    
    // Determine paper size and column count
    final PaperSize paperSize = rollSize >= 80 ? PaperSize.mm80 : PaperSize.mm58;
    final int maxChars = rollSize >= 80 ? 42 : (rollSize >= 58 ? 32 : 30);
    final generator = Generator(paperSize, _cachedProfile!);
    List<int> bytes = [];

    final PosAlign align = rollSize >= 80 ? PosAlign.center : PosAlign.left;
    final PosFontType? fontType = rollSize >= 80 ? PosFontType.fontB : null;
    final PosTextSize titleSize = rollSize >= 80 ? PosTextSize.size1 : PosTextSize.size2;
    final PosTextSize totalSize = rollSize >= 80 ? PosTextSize.size1 : PosTextSize.size2;

    // Create dynamic separator
    String separator = "-" * maxChars;

    bytes += generator.reset();

    // Header - Centered and Tall
    bytes += [27, 32, 2]; // Set character spacing
    bytes += generator.text("mFresh", styles: PosStyles(align: PosAlign.center, bold: true, height: titleSize, width: titleSize, fontType: fontType));
    bytes += [27, 32, 0]; // Reset spacing
    bytes += generator.feed(1);
    
    bytes += [27, 32, 4]; // Increased spacing for Unit Number
    bytes += generator.text("UNIT NO.: ${booking.unitNo}", styles: PosStyles(align: align, bold: true, height: PosTextSize.size1, fontType: fontType));
    bytes += [27, 32, 0]; // Reset spacing to prevent separator wrapping
    // Standard size for location text
    bytes += generator.text("Location: ${booking.fullAddress}", styles: PosStyles(align: align, bold: false, fontType: fontType));
    bytes += generator.text(separator, styles: PosStyles(align: align, fontType: fontType));

    // Booking Details
    bytes += generator.text("BOOKING ID: ${booking.bookingId}", styles: PosStyles(align: align, bold: true, fontType: fontType));
    
    final printDate = booking.bookingTimeDate.isNotEmpty ? booking.bookingTimeDate : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    bytes += generator.text("Date & Time: $printDate", styles: PosStyles(align: align, fontType: fontType));

    String paymentModeStr = booking.paymentMode == 1 ? "CASH" : booking.paymentMode == 2 ? "UPI" : "QR";
    bytes += generator.text("Payment: $paymentModeStr", styles: PosStyles(align: align, bold: false, fontType: fontType));
    
    bytes += generator.text(separator, styles: PosStyles(align: align, fontType: fontType));

    // Service & Qty - Standard size
    bytes += generator.text(service.servicesName.toUpperCase(), styles: PosStyles(bold: true, align: align, height: PosTextSize.size1, fontType: fontType));
    bytes += generator.text("QTY: 1", styles: PosStyles(bold: false, align: align, fontType: fontType));
    bytes += generator.text(separator, styles: PosStyles(align: align, fontType: fontType));
    bytes += [27, 32, 2]; // Wide spacing for Total
    bytes += generator.text("TOTAL: RS. ${service.price}", styles: PosStyles(bold: true, align: align, height: totalSize, width: PosTextSize.size1, fontType: fontType));
    bytes += [27, 32, 0]; // Reset spacing
    bytes += generator.text(separator, styles: PosStyles(align: align, fontType: fontType));

    // QR Code - Size adjusted for paper width but always left aligned
    final QRSize qrSize = rollSize >= 80 ? QRSize.size6 : QRSize.size4;
    bytes += generator.qrcode(jsonEncode({
      "BookingID": encryptedBookingId ?? booking.encryptBookingId ?? booking.bookingId,
      "DeviceID": "NA",
      "AccessDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    }), size: qrSize, align: align);
    
    bytes += generator.feed(1);
    bytes += generator.text("Thank you for using mFresh!", styles: PosStyles(align: align, bold: true, fontType: fontType));

    // Send explicit cut commands to trigger auto-cutters on 80mm printers
    bytes += generator.feed(3);
    bytes += [29, 86, 65, 0]; // GS V A 0 (Full Cut)
    bytes += [27, 105];       // ESC i (Full Cut)
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

    for (int i = 0; i < booking.services.length; i++) {
      final service = booking.services[i];
      final int qty = int.tryParse(service.quantity.toString()) ?? 1;

      for (int q = 0; q < qty; q++) {
        doc.addPage(
          pw.Page(
            pageFormat: rollFormat,
            build: (pw.Context context) {
              final align = rollSize >= 80 ? pw.TextAlign.center : pw.TextAlign.left;
              final crossAlign = rollSize >= 80 ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start;
              
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: pw.Column(
                  crossAxisAlignment: crossAlign,
                  children: [
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Image(logoImage, width: 40, height: 40),
                          pw.SizedBox(height: 4),
                          pw.Text("mFresh", 
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, letterSpacing: 2.0)
                          )
                        ]
                      )
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text("UNIT NO.: ${booking.unitNo}", textAlign: align, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                    pw.Text("Location: ${booking.fullAddress}", textAlign: align, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal)),
                    pw.Text("---------------------------------------", textAlign: align, style: pw.TextStyle(fontSize: 10)),
                    
                    pw.Text("BOOKING ID: ${booking.bookingId}", textAlign: align, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text("Date & Time: ${booking.bookingTimeDate.isNotEmpty ? booking.bookingTimeDate : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}", textAlign: align, style: pw.TextStyle(fontSize: 11)),
                    
                    pw.Text("Payment: ${booking.paymentMode == 1 ? 'CASH' : booking.paymentMode == 2 ? 'UPI' : 'QR'}", textAlign: align, style: pw.TextStyle(fontSize: 11)),
                    pw.Text("---------------------------------------", textAlign: align, style: pw.TextStyle(fontSize: 10)),

                    // Service List (Only one service per page)
                    pw.Column(
                      crossAxisAlignment: crossAlign,
                      children: [
                        pw.Text(service.servicesName.toUpperCase(), textAlign: align, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.Text("QTY: 1", textAlign: align, style: pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 6),
                      ]
                    ),

                    pw.Text("---------------------------------------", textAlign: align, style: pw.TextStyle(fontSize: 10)),
                    pw.Text("TOTAL: RS. ${service.price}", textAlign: align, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
                    pw.Text("---------------------------------------", textAlign: align, style: pw.TextStyle(fontSize: 10)),
                    
                    pw.SizedBox(height: 10),
                    pw.Center(
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: jsonEncode({
                          "BookingID": encryptedBookingId ?? booking.encryptBookingId ?? booking.bookingId,
                          "DeviceID": "NA",
                          "AccessDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
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
      }
    }

    return doc;
  }


  static Map<String, dynamic> _buildPlutusPrintData(BookingDetailsModel booking, ServiceItem service, String? encryptedBookingId) {
    return {
      "bookingId": encryptedBookingId ?? booking.encryptBookingId ?? booking.bookingId,
      "unitNo": booking.unitNo,
      "amount": booking.totalAmount,
      "service": service.servicesName,
      "qrData": jsonEncode({
        "BookingID": encryptedBookingId ?? booking.encryptBookingId ?? booking.bookingId,
        "DeviceID": "NA",
        "AccessDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      }),
    };
  }
}
