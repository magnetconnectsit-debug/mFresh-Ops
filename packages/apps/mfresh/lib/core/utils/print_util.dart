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
import 'package:mfresh/core/config/app_config.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class PrintUtil {
  static final PlutusService _plutusService = Get.find<PlutusService>();
  static final _printerPlugin = FlutterThermalPrinter.instance;

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
                subtitle: "BT / USB / WiFi Printer",
                onTap: () {
                  Get.back();
                  _handleExternalPrint(context, booking);
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
      debugPrint("Internal Direct Print Error: $e");
      AppCommonToastMessage.show(message: "Direct Print Error: $e", type: ToastType.error);
    }
  }

  /// Handle External Printer Discovery
  static Future<void> _handleExternalPrint(BuildContext context, BookingDetailsModel booking) async {
    // Request Permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (!context.mounted) return;
    _showExternalDeviceSelector(context, booking);
  }

  static void _showExternalDeviceSelector(BuildContext context, BookingDetailsModel booking) {
    final discoveredPrinters = <Printer>[].obs;
    final isScanning = false.obs;
    StreamSubscription? subscription;

    // Helper for scanning
    Future<void> startScan() async {
      if (isScanning.value) return;
      
      // Check Permissions first (don't touch plugin if no permission)
      final status = await Permission.bluetoothScan.status;
      if (!status.isGranted) {
        await Permission.bluetoothScan.request();
        await Permission.bluetoothConnect.request();
      }

      isScanning.value = true;
      discoveredPrinters.clear();
      
      try {
        // Only call plugin if we really intend to scan
        bool isBleOn = await _printerPlugin.isBleTurnedOn();
        if (!isBleOn) {
          AppCommonToastMessage.show(message: "Please turn on Bluetooth & Location", type: ToastType.info);
          // Try to turn on natively ONLY once
          await _printerPlugin.turnOnBluetooth();
          await Future.delayed(const Duration(seconds: 4));
          isBleOn = await _printerPlugin.isBleTurnedOn();
        }

        if (!isBleOn) {
          isScanning.value = false;
          return;
        }

        subscription?.cancel();
        subscription = _printerPlugin.devicesStream.listen((printers) {
          discoveredPrinters.assignAll(printers);
        });

        await _printerPlugin.getPrinters(
          connectionTypes: [ConnectionType.BLE, ConnectionType.USB, ConnectionType.NETWORK],
        );

        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Scan Error: $e");
      } finally {
        isScanning.value = false;
      }
    }

    // Initial check when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isBleOn = await _printerPlugin.isBleTurnedOn();
      if (!isBleOn) {
         AppCommonToastMessage.show(message: "Enabling Bluetooth...", type: ToastType.info);
         await _printerPlugin.turnOnBluetooth();
         
         // Wait longer initially to let the radio power up before first poll
         await Future.delayed(const Duration(seconds: 4));
         
         // Poll for status change (up to 6 times, every 2 seconds)
         for (int i = 0; i < 6; i++) {
           isBleOn = await _printerPlugin.isBleTurnedOn();
           if (isBleOn) {
             startScan();
             return;
           }
           await Future.delayed(const Duration(seconds: 2));
         }
         AppCommonToastMessage.show(message: "Bluetooth still off. Please enable manually.", type: ToastType.warning);
      } else {
         startScan();
      }
    });

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Printer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Obx(() => isScanning.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFFF15A22)),
                        onPressed: startScan,
                      )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text("Detected Printers (BT/USB/WiFi)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),

              Obx(() => discoveredPrinters.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No printers found. Tap Refresh.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: discoveredPrinters.length,
                      itemBuilder: (context, index) {
                        final Printer printer = discoveredPrinters[index];
                        IconData icon;
                        switch (printer.connectionType) {
                          case ConnectionType.USB: icon = Icons.usb; break;
                          case ConnectionType.NETWORK: icon = Icons.wifi; break;
                          default: icon = Icons.bluetooth;
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(icon, size: 20, color: const Color(0xFFF15A22)),
                          title: Text(printer.name ?? "Unknown Printer", style: const TextStyle(fontSize: 13)),
                          subtitle: Text("${printer.connectionType?.name} - ${printer.address ?? 'No Address'}", style: const TextStyle(fontSize: 10)),
                          onTap: () async {
                          Get.back(); // Close dialog
                          
                          // Stop any active scanning before connecting
                          isScanning.value = false;
                          subscription?.cancel();
                          
                          // Wait a moment to let the BT stack settle (prevents 133 error)
                          AppCommonToastMessage.show(message: "Connecting...", type: ToastType.info);
                          await Future.delayed(const Duration(seconds: 1));
                          
                          _printToExternal(booking, printer);
                        },
                        );
                      },
                    ),
                  )
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  subscription?.cancel();
                  Get.back();
                }, 
                child: const Text("Cancel", style: TextStyle(color: Colors.red))
              ),
            ],
          ),
        ),
      ),
    ).then((_) => subscription?.cancel());
  }

  static Future<void> _printToExternal(BookingDetailsModel booking, Printer printer) async {
    // Show Printing Loader
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFF15A22)),
                SizedBox(height: 15),
                Text("Printing Receipt...", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, decoration: TextDecoration.none, color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // 1. Connect with Retry for 133 error
      bool connected = false;
      for (int i = 0; i < 2; i++) {
        connected = await _printerPlugin.connect(printer);
        if (connected) break;
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!connected) {
        // Ensure all dialogs (including the loader) are closed
        while (Get.isDialogOpen ?? false) {
          Get.back();
        }
        AppCommonToastMessage.show(message: "Printer connection failed. Please check printer power & distance.", type: ToastType.error);
        return;
      }

      // 2. Generate ESC/POS bytes
      final bytes = await _generateEscPosBytes(booking);
      
      // 3. Print
      await _printerPlugin.printData(printer, bytes);
      
      // 4. Disconnect
      await Future.delayed(const Duration(seconds: 2));
      await _printerPlugin.disconnect(printer);
      
      while (Get.isDialogOpen ?? false) {
        Get.back();
      }
      AppCommonToastMessage.show(message: "Printing successful", type: ToastType.success);
    } catch (e) {
      while (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint("External Print Error: $e");
      // Use specific message to avoid "No Internet" catch
      AppCommonToastMessage.show(message: "Printer error: $e", type: ToastType.error);
    }
  }

  static Future<List<int>> _generateEscPosBytes(BookingDetailsModel booking) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // 1. Logo
    try {
      final ByteData data = await rootBundle.load(AppImages.appLogo);
      final Uint8List imgBytes = data.buffer.asUint8List();
      final img.Image? logo = img.decodeImage(imgBytes);
      if (logo != null) {
        // Prepare image for thermal printing (Increased size to ~320 for 58mm paper)
        img.Image processedLogo = img.copyResize(logo, width: 320);
        processedLogo = img.grayscale(processedLogo);
        
        // imageRaster is often faster on some thermal printers
        bytes += generator.imageRaster(processedLogo, align: PosAlign.center);
      } else {
        bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
      }
    } catch (e) {
      debugPrint("Logo load error: $e");
      bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    }

    bytes += generator.feed(1);
    
    // 2. Unit & Location
    bytes += generator.text("Unit No.: ${booking.unitNo}", styles: const PosStyles(bold: true));
    bytes += generator.text("Location: ${booking.fullAddress}");
    bytes += generator.text("--------------------------------");

    // 3. Booking Info
    bytes += generator.text("Booking ID: ${booking.bookingId}", styles: const PosStyles(bold: true));
    bytes += generator.text("Date & Time: ${_formatDate(booking.bookingTimeDate)}");
    
    // Payment Mode
    String paymentModeStr = "Unknown";
    switch (booking.paymentMode.toString()) {
      case "1": paymentModeStr = "Cash"; break;
      case "2": paymentModeStr = "Online"; break;
      case "3": paymentModeStr = "External QR"; break;
    }
    bytes += generator.text("Payment Mode: $paymentModeStr");
    bytes += generator.feed(1);

    // 4. Services
    bytes += generator.text("Services:", styles: const PosStyles(bold: true));
    int count = 1;
    for (var s in booking.services) {
      bytes += generator.text("$count. ${s.servicesName} (x${s.quantity})");
      count++;
    }
    bytes += generator.feed(1);

    // 5. Total
    bytes += generator.text("--------------------------------");
    bytes += generator.text("Total Paid: Rs. ${booking.totalAmount}", styles: const PosStyles(bold: true, height: PosTextSize.size1));
    bytes += generator.text("--------------------------------");

    // 6. Footer & QR
    bytes += generator.text("Thank you!", styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(1);
    
    bytes += generator.qrcode(jsonEncode({
      "BookingID": booking.bookingId,
      "DeviceID": "NA",
      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
    }), size: QRSize.size8); // Increased QR size

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  static Future<void> printSystem(BookingDetailsModel booking, String? encryptedBookingId) async {
    try {
      final doc = await _generateDocument(booking, encryptedBookingId);
      await sys_print.Printing.layoutPdf(
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

    // Load logo for PDF
    final ByteData logoData = await rootBundle.load(AppImages.appLogo);
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

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
                pw.Center(child: pw.Image(logoImage, width: 120)),
                pw.SizedBox(height: 8),
                pw.Text("Unit No.: ${booking.unitNo}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text("Location: ${booking.fullAddress}", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 4),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 4),
                pw.Text("Booking ID: ${booking.bookingId}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text("Date & Time: ${_formatDate(booking.bookingTimeDate)}", style: const pw.TextStyle(fontSize: 8)),
                
                // Payment Mode
                pw.Text("Payment Mode: ${booking.paymentMode == 1 ? "Cash" : booking.paymentMode == 2 ? "Online" : "External QR"}", style: const pw.TextStyle(fontSize: 8)),
                
                pw.SizedBox(height: 8),
                pw.Text("Services:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                for (int i = 0; i < booking.services.length; i++)
                   pw.Padding(
                     padding: const pw.EdgeInsets.only(top: 2),
                     child: pw.Text("${i + 1}. ${booking.services[i].servicesName} (x${booking.services[i].quantity})", style: const pw.TextStyle(fontSize: 9)),
                   ),
                pw.SizedBox(height: 4),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total Paid:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text("Rs. ${booking.totalAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ],
                ),
                pw.Text("-------------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 8),
                pw.Center(child: pw.Text("Thank you!", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: jsonEncode({
                      "BookingID": encryptedBookingId ?? booking.bookingId,
                      "DeviceID": "NA",
                      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
                    }),
                    width: 130,
                    height: 130,
                  ),
                ),
                pw.SizedBox(height: 20),
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

    // Header / Logo area
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "mFresh", "ImagePath": "0", "ImageData": "0"});
    
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Unit No.: ${booking.unitNo}", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Location: ${booking.fullAddress}", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "------------------------", "ImagePath": "0", "ImageData": "0"});
    
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Booking ID: ${booking.bookingId}", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Date & Time: ${_formatDate(booking.bookingTimeDate)}", "ImagePath": "0", "ImageData": "0"});
    
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": " ", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Services:", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "1. ${service.servicesName} (x${service.quantity})", "ImagePath": "0", "ImageData": "0"});
    
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "------------------------", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Total Paid: Rs. ${booking.totalAmount}", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "------------------------", "ImagePath": "0", "ImageData": "0"});
    
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Thank you!", "ImagePath": "0", "ImageData": "0"});
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": " ", "ImagePath": "0", "ImageData": "0"});

    printItems.add({
      "PrintDataType": "4",
      "PrinterWidth": 24,
      "IsCenterAligned": true,
      "DataToPrint": jsonEncode({
        "BookingID": encryptedBookingId ?? booking.bookingId,
        "DeviceID": "NA",
        "AccessDate": _formatDateRaw(booking.bookingTimeDate),
      }),
      "ImagePath": "",
      "ImageData": ""
    });

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
