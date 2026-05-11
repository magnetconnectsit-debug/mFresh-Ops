import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:core/utils/app_common_toast_message.dart';
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
    int rollSize = 80,
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
              subtitle: "Connect to Bluetooth, USB or WiFi thermal printers",
              onTap: () {
                Get.back();
                PrintUtil.handleExternalPrint(context, booking, useDefault: true, rollSize: rollSize);
              },
            ),
            const SizedBox(height: 12),
            _buildPrintOption(
              icon: Icons.picture_as_pdf_rounded,
              title: "System Print / PDF",
              subtitle: "Print via system dialog or save as PDF",
              onTap: () {
                Get.back();
                PrintUtil.printSystem(booking, encryptedBookingId, rollSize: rollSize);
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
  static void showExternalDeviceSelector(BuildContext context, BookingDetailsModel booking, {int rollSize = 80}) {
    final discoveredPrinters = <Printer>[].obs;
    final isScanning = false.obs;
    StreamSubscription? subscription;

    // Helper for scanning
    Future<void> startScan() async {
      if (isScanning.value) return;
      
      // Comprehensive permissions for BT and WiFi scanning
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();

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
          // Filter out devices with no names (often stale or invalid signals)
          final activePrinters = printers.where((p) => p.name != null && p.name!.isNotEmpty).toList();
          debugPrint("Discovered ${activePrinters.length} valid printers");
          discoveredPrinters.assignAll(activePrinters);
        });

        // Staggered requests for different connection types to improve discovery reliability
        _printerPlugin.getPrinters(connectionTypes: [ConnectionType.BLE]);
        await Future.delayed(const Duration(milliseconds: 300));
        _printerPlugin.getPrinters(connectionTypes: [ConnectionType.USB]);
        await Future.delayed(const Duration(milliseconds: 300));
        _printerPlugin.getPrinters(connectionTypes: [ConnectionType.NETWORK]);
        
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
              const Text("Available Devices", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              Obx(() {
                if (discoveredPrinters.isEmpty && !isScanning.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: Text("No printers found", style: TextStyle(color: Colors.grey))),
                  );
                }

                // Categorize based on connection type name for maximum compatibility
                final blePrinters = <Printer>[];
                final wifiPrinters = <Printer>[];
                final usbPrinters = <Printer>[];

                for (var p in discoveredPrinters) {
                  final String type = (p.connectionType?.name ?? "").toUpperCase();
                  if (type.contains("USB")) {
                    usbPrinters.add(p);
                  } else if (type.contains("WIFI") || type.contains("NETWORK") || type.contains("IP") || type.contains("TCP")) {
                    wifiPrinters.add(p);
                  } else {
                    blePrinters.add(p);
                  }
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Bluetooth Section
                      if (blePrinters.isNotEmpty) ...[
                        _buildSectionHeader("Bluetooth Devices"),
                        ...blePrinters.map((p) => _buildPrinterTile(context, p, Icons.bluetooth, booking, isScanning, subscription, rollSize)),
                      ],
                      
                      // WiFi / WiFi Direct Section
                      if (wifiPrinters.isNotEmpty) ...[
                        _buildSectionHeader("WiFi / Network Devices"),
                        ...wifiPrinters.map((p) => _buildPrinterTile(context, p, Icons.wifi, booking, isScanning, subscription, rollSize)),
                      ],

                      // USB Section
                      if (usbPrinters.isNotEmpty) ...[
                        _buildSectionHeader("USB Devices"),
                        ...usbPrinters.map((p) => _buildPrinterTile(context, p, Icons.usb, booking, isScanning, subscription, rollSize)),
                      ],
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
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Expanded(child: Divider(indent: 10, endIndent: 0, thickness: 0.5)),
        ],
      ),
    );
  }

  static Widget _buildPrinterTile(BuildContext context, Printer printer, IconData icon, BookingDetailsModel booking, RxBool isScanning, StreamSubscription? subscription, int rollSize) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF15A22).withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFFF15A22)),
      ),
      title: Text(printer.name ?? "Unknown Printer", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${printer.connectionType?.name} - ${printer.address ?? 'No Address'}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
          if (printer.address == PrintUtil.lastFailedAddress)
            const Text("Last connection failed", style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: () async {
        Get.back();
        isScanning.value = false;
        subscription?.cancel();
        AppCommonToastMessage.show(message: "Connecting to ${printer.name}...", type: ToastType.info);
        await Future.delayed(const Duration(seconds: 1));
        final success = await PrintUtil.printToExternal(booking, printer, rollSize: rollSize);
        
        if (!success) {
          debugPrint("Print failed, re-showing device selector...");
          // Fallback: Re-show the selector if printing failed
          showExternalDeviceSelector(Get.context!, booking, rollSize: rollSize);
        }
      },
    );
  }
}
