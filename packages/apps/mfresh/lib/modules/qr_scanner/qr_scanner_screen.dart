import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Text(
          'Scan QR Code',
          style: AppTextStyle.style_16_600(color: AppColors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.white, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            color: AppColors.white,
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: AppColors.grey200);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: AppColors.warning);
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: AppColors.red);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: AppColors.info);
                }
              },
            ),
            iconSize: 24.sp,
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            color: AppColors.white,
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 24.sp,
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  Get.back(result: code);
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                children: [
                  // Corner accents could be added here
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: AppTextStyle.style_14_400(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
