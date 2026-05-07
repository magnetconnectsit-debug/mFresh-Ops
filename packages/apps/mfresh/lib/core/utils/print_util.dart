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
import 'package:services/storage_service.dart';

class PrintUtil {
  static final PlutusService _plutusService = Get.find<PlutusService>();
  static final _printerPlugin = FlutterThermalPrinter.instance;
  static CapabilityProfile? _cachedProfile;
  static img.Image? _cachedLogo;
  static Printer? _connectedPrinter;

  static Widget _buildPrintOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFFF15A22)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey.shade50,
    );
  }

  /// Shows the selection dialog (Now bypassed to go straight to discovery or default)
  static void showPrintSelectionDialog({
    required BuildContext context,
    required BookingDetailsModel booking,
    String? encryptedBookingId,
  }) {
    // We bypass the old selection dialog and go straight to the external print handler
    // which handles Default Printer auto-connect or shows the discovery list.
    _handleExternalPrint(context, booking, useDefault: true);
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
  static Future<void> _handleExternalPrint(BuildContext context, BookingDetailsModel booking, {bool useDefault = false}) async {
    // Request Permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (!context.mounted) return;
    
    if (useDefault) {
      final defaultAddress = Get.find<StorageService>().getDefaultPrinterAddress();
      if (defaultAddress != null) {
        // Try to find the printer in a quick scan
        _attemptDefaultPrint(context, booking, defaultAddress);
        return;
      }
    }
    
    _showExternalDeviceSelector(context, booking);
  }

  static void _attemptDefaultPrint(BuildContext context, BookingDetailsModel booking, String address) {
    AppCommonToastMessage.show(message: "Connecting to default printer...", type: ToastType.info);
    
    // We need to scan briefly to get the Printer object
    StreamSubscription? sub;
    bool found = false;
    
    Timer(const Duration(seconds: 5), () {
      if (!found) {
        sub?.cancel();
        AppCommonToastMessage.show(message: "Default printer not found. Please select manually.", type: ToastType.warning);
        _showExternalDeviceSelector(context, booking);
      }
    });

    sub = _printerPlugin.devicesStream.listen((printers) {
      final printer = printers.firstWhereOrNull((p) => p.address == address);
      if (printer != null && !found) {
        found = true;
        sub?.cancel();
        _printToExternal(booking, printer);
      }
    });

    _printerPlugin.getPrinters(connectionTypes: [ConnectionType.BLE]);
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
          final lastAddress = Get.find<StorageService>().getLastPrinterAddress();
          if (lastAddress != null) {
            // Sort to put last connected printer at the top
            final sortedList = List<Printer>.from(printers);
            sortedList.sort((a, b) {
              if (a.address == lastAddress) return -1;
              if (b.address == lastAddress) return 1;
              return 0;
            });
            discoveredPrinters.assignAll(sortedList);
          } else {
            discoveredPrinters.assignAll(printers);
          }
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

              Obx(() {
                final lastAddress = Get.find<StorageService>().getLastPrinterAddress();
                final lastUsedName = Get.find<StorageService>().getLastPrinterName();
                
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Last Used Section
                      if (lastAddress != null) ...[
                        const Text("LAST USED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF15A22))),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history, size: 20, color: Color(0xFFF15A22)),
                          title: Text(lastUsedName ?? "Unknown Printer", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text(lastAddress, style: const TextStyle(fontSize: 10)),
                          onTap: () {
                            Get.back();
                            // Attempt to connect to this address specifically if possible, 
                            // but our plugin usually needs the Printer object.
                            // So we search for it in the discovered list first.
                            final printer = discoveredPrinters.firstWhereOrNull((p) => p.address == lastAddress);
                            if (printer != null) {
                              _printToExternal(booking, printer);
                            } else {
                              AppCommonToastMessage.show(message: "Printer not found in scan. Please wait or refresh.", type: ToastType.warning);
                            }
                          },
                          trailing: IconButton(
                            icon: Icon(
                              Get.find<StorageService>().getDefaultPrinterAddress() == lastAddress
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFF15A22),
                            ),
                            onPressed: () {
                              final storage = Get.find<StorageService>();
                              if (storage.getDefaultPrinterAddress() == lastAddress) {
                                storage.clearDefaultPrinter();
                                AppCommonToastMessage.show(message: "Default printer cleared", type: ToastType.info);
                              } else {
                                storage.saveDefaultPrinter(lastAddress, lastUsedName ?? "Printer");
                                AppCommonToastMessage.show(message: "Set as default printer", type: ToastType.success);
                              }
                              discoveredPrinters.refresh();
                            },
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                      ],

                      // Discovered List
                      if (discoveredPrinters.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text("Scanning for printers...", style: TextStyle(fontSize: 12, color: Colors.grey))),
                        )
                      else
                        ...discoveredPrinters.map((printer) {
                          // Skip if it's the last used (already shown at top)
                          if (printer.address == lastAddress) return const SizedBox.shrink();

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
                              Get.back();
                              isScanning.value = false;
                              subscription?.cancel();
                              AppCommonToastMessage.show(message: "Connecting...", type: ToastType.info);
                              await Future.delayed(const Duration(seconds: 1));
                              _printToExternal(booking, printer);
                            },
                            trailing: IconButton(
                              icon: Icon(
                                Get.find<StorageService>().getDefaultPrinterAddress() == printer.address
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFF15A22),
                                size: 20,
                              ),
                              onPressed: () {
                                if (printer.address != null) {
                                  final storage = Get.find<StorageService>();
                                  if (storage.getDefaultPrinterAddress() == printer.address) {
                                    storage.clearDefaultPrinter();
                                    AppCommonToastMessage.show(message: "Default printer cleared", type: ToastType.info);
                                  } else {
                                    storage.saveDefaultPrinter(printer.address!, printer.name ?? "Printer");
                                    AppCommonToastMessage.show(message: "Set as default printer", type: ToastType.success);
                                  }
                                  discoveredPrinters.refresh();
                                }
                              },
                            ),
                          );
                        }),
                    ],
                  ),
                );
              }),
              
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
      // 1. Optimized Connection (Skip if already connected to this printer)
      bool connected = false;
      
      // If we think we are already connected to this printer, skip the connect call
      if (_connectedPrinter != null && _connectedPrinter!.address == printer.address) {
        connected = true;
      } else {
        // Disconnect old one if exists before connecting new
        if (_connectedPrinter != null) {
          try { await _printerPlugin.disconnect(_connectedPrinter!); } catch (_) {}
        }
        
        connected = await _printerPlugin.connect(printer);
        if (!connected) {
          await Future.delayed(const Duration(milliseconds: 500));
          connected = await _printerPlugin.connect(printer);
        }
      }

      if (connected) {
        _connectedPrinter = printer;
        if (printer.address != null) {
          final displayName = printer.name != null && printer.name!.isNotEmpty
              ? printer.name!
              : "BT Printer (${printer.address?.split(':').last ?? '...' })";
          Get.find<StorageService>().saveLastPrinter(printer.address!, displayName);
        }
      }

      if (!connected) {
        // Ensure all dialogs (including the loader) are closed
        while (Get.isDialogOpen ?? false) {
          Get.back();
        }
        AppCommonToastMessage.show(message: "Printer connection failed.", type: ToastType.error);
        return;
      }

      // 2. Minimum stabilization delay
      await Future.delayed(const Duration(milliseconds: 200));

      // 3. Print each service separately, and each quantity as a unique receipt
      for (int i = 0; i < booking.services.length; i++) {
        final service = booking.services[i];
        final int qty = int.tryParse(service.quantity) ?? 1;
        
        // Loop through the quantity to print separate receipts for each unit
        for (int q = 0; q < qty; q++) {
          final bytes = await _generateEscPosBytes(booking, service, quantityIndex: q + 1);
          
          // Large chunks for high-speed transmission
          const int chunkSize = 1024; 
          for (int j = 0; j < bytes.length; j += chunkSize) {
            int end = (j + chunkSize < bytes.length) ? j + chunkSize : bytes.length;
            await _printerPlugin.printData(printer, bytes.sublist(j, end));
          }
          
          // Smart delay: 3 seconds between multiple receipts
          // (Only delay if there's another receipt coming: either more quantity or more services)
          bool isLastReceipt = (i == booking.services.length - 1) && (q == qty - 1);
          if (!isLastReceipt) {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }
      
      // 4. Stay Connected (Removed disconnect call for persistent connection)
      // We don't call disconnect here anymore so subsequent prints are instant
      
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

  static Future<List<int>> _generateEscPosBytes(
    BookingDetailsModel booking, 
    ServiceItem service, 
    {int? quantityIndex}
  ) async {
    _cachedProfile ??= await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, _cachedProfile!);
    List<int> bytes = [];

    bytes += generator.reset();

    // 1. App Title with Stylized "Chakra" Brand (Optimized with Caching)
    try {
      if (_cachedLogo == null) {
        final ByteData data = await rootBundle.load(AppImages.appLogo);
        final Uint8List imgBytes = data.buffer.asUint8List();
        final img.Image? logo = img.decodeImage(imgBytes);
        if (logo != null) {
           _cachedLogo = img.copyResize(logo, width: 180); // Slightly larger for visibility
           _cachedLogo = img.grayscale(_cachedLogo!);
        }
      }

      if (_cachedLogo != null) {
        bytes += generator.imageRaster(_cachedLogo!, align: PosAlign.center);
      } else {
        bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
      }
    } catch (e) {
      bytes += generator.text("mFresh", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    }
    bytes += generator.feed(1);

    // 2. Unit & Location with slight character spacing
    bytes += [27, 32, 2]; // Set character spacing to 2 dots
    bytes += generator.text("Unit No.: ${booking.unitNo}");
    bytes += [27, 32, 0]; // Reset
    bytes += generator.text("Location: ${booking.fullAddress}");
    bytes += generator.text("-----------------------------------------------");

    // 3. Booking Info
    String originalId = booking.bookingId;
    bytes += [27, 32, 1]; // Set character spacing to 1 dot
    bytes += generator.text("Booking ID: $originalId");
    bytes += [27, 32, 0]; // Reset
    bytes += generator.text("Date & Time: ${_formatDate(booking.bookingTimeDate)}");
    
    // Payment Mode
    String paymentModeStr = "Unknown";
    switch (booking.paymentMode.toString()) {
      case "1": paymentModeStr = "Cash"; break;
      case "2": paymentModeStr = "Online"; break;
      case "3": paymentModeStr = "External QR"; break;
    }
    bytes += generator.text("Payment Mode: $paymentModeStr");

    // 3. Service Details
    bytes += generator.text("Service: ${service.servicesName}", styles: const PosStyles(bold: true));
    bytes += generator.text("Quantity: 1", styles: const PosStyles(align: PosAlign.left));

    // 5. Total
    bytes += generator.text("-----------------------------------------------");
    bytes += generator.text("Total Paid: Rs. ${booking.totalAmount}", styles: const PosStyles(bold: true, height: PosTextSize.size2, width: PosTextSize.size1));
    bytes += generator.text("-----------------------------------------------");

    // 6. Footer & QR
    bytes += generator.text("Thank you!", styles: const PosStyles(align: PosAlign.center, bold: true));
    
    bytes += generator.qrcode(jsonEncode({
      "BookingID": booking.bookingId,
      "DeviceID": "NA",
      "AccessDate": _formatDateRaw(booking.bookingTimeDate),
    }), size: QRSize.size4);

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
    const rollFormat = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 0);

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
