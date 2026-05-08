import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/storage_service.dart';
import 'print_util.dart';

class PrinterDialogUtil {
  static final _printerPlugin = FlutterThermalPrinter.instance;

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

  /// Shows the selection dialog to choose between Thermal or System printing
  static void showPrintSelectionDialog({
    required BuildContext context,
    required BookingDetailsModel booking,
    String? encryptedBookingId,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const Text("Print Receipt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPrintOption(
              icon: Icons.bluetooth_searching,
              title: "Thermal Printer",
              subtitle: "Connect to Bluetooth or USB thermal printers",
              onTap: () {
                Get.back();
                PrintUtil.handleExternalPrint(context, booking, useDefault: true);
              },
            ),
            const SizedBox(height: 12),
            _buildPrintOption(
              icon: Icons.picture_as_pdf_rounded,
              title: "System Print / PDF",
              subtitle: "Print via system dialog or save as PDF",
              onTap: () {
                Get.back();
                PrintUtil.printSystem(booking, encryptedBookingId);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// UI for discovered devices
  static void showExternalDeviceSelector(BuildContext context, BookingDetailsModel booking) {
    final discoveredPrinters = <Printer>[].obs;
    final isScanning = false.obs;
    StreamSubscription? subscription;

    // Helper for scanning
    Future<void> startScan() async {
      if (isScanning.value) return;
      
      final status = await Permission.bluetoothScan.status;
      if (!status.isGranted) {
        await Permission.bluetoothScan.request();
        await Permission.bluetoothConnect.request();
      }

      isScanning.value = true;
      discoveredPrinters.clear();
      
      try {
        bool isBleOn = await _printerPlugin.isBleTurnedOn();
        if (!isBleOn) {
          AppCommonToastMessage.show(message: "Please turn on Bluetooth & Location", type: ToastType.info);
          isScanning.value = false;
          return;
        }

        subscription = _printerPlugin.devicesStream.listen((printers) {
          discoveredPrinters.assignAll(printers);
        });

        _printerPlugin.getPrinters(connectionTypes: [ConnectionType.BLE, ConnectionType.USB]);
      } catch (e) {
        debugPrint("Scan Error: $e");
      }
    }

    // Initial scan
    startScan();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Printer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Obx(() => isScanning.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(icon: const Icon(Icons.refresh), onPressed: startScan)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Detected Printers (BT/USB/WiFi)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),

              Obx(() {
                final storage = Get.find<StorageService>();
                final lastAddress = storage.getLastPrinterAddress();
                final lastUsedName = storage.getLastPrinterName();
                
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (lastAddress != null) ...[
                        const Text("LAST USED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF15A22))),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history, size: 20, color: Color(0xFFF15A22)),
                          title: Text(lastUsedName ?? "Unknown Printer", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text(lastAddress, style: const TextStyle(fontSize: 10)),
                          onTap: () {
                            Get.back();
                            final printer = discoveredPrinters.firstWhereOrNull((p) => p.address == lastAddress);
                            if (printer != null) {
                              PrintUtil.printToExternal(booking, printer);
                            } else {
                              AppCommonToastMessage.show(message: "Printer not found in scan. Please wait or refresh.", type: ToastType.warning);
                            }
                          },
                          trailing: IconButton(
                            icon: Icon(
                              storage.getDefaultPrinterAddress() == lastAddress
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFF15A22),
                            ),
                            onPressed: () {
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

                      if (discoveredPrinters.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text("Scanning for printers...", style: TextStyle(fontSize: 12, color: Colors.grey))),
                        )
                      else
                        ...discoveredPrinters.map((printer) {
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
                              PrintUtil.printToExternal(booking, printer);
                            },
                          );
                        }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    subscription?.cancel();
                    Get.back();
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => subscription?.cancel());
  }
}
