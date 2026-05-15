import 'dart:convert';

import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/dashboard/controllers/dashboard_controller.dart';
// import 'package:mfresh/modules/dashboard/views/widgets/search_bar_tool.dart';
import 'package:mfresh/modules/dashboard/views/widgets/unit_card.dart';
import 'package:mfresh/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:services/plutus_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final dashboardController = Get.put(DashboardController());
  final profileController = Get.put(ProfileController());
  final plutusService = Get.find<PlutusService>();

  DateTime? _lastPressedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bindService();
    });
  }

  Future<void> _bindService() async {
    try {
      final result = await plutusService.bindToService();
      if (result == "SUCCESS" || result == "BINDING SUCCESS.") {
        debugPrint("BINDING SUCCESS.");
      } else {
        debugPrint("BINDING FAILED: $result");
      }
    } catch (e) {
      debugPrint("BINDING EXCEPTION: $e");
    }
  }

  Future<bool> _onWillPop() async {
    final currentTime = DateTime.now();
    final isBackPressed =
        _lastPressedTime == null ||
        currentTime.difference(_lastPressedTime!) > const Duration(seconds: 2);

    if (isBackPressed) {
      _lastPressedTime = currentTime;
      AppCommonToastMessage.show(
        message: 'Press back again to exit',
        type: ToastType.info,
      );
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final bool isTablet = screenWidth > 600;
          final bool isDesktop = screenWidth > 1000;

          double fontSizeTitle = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);
          double fontSizeSubTitle = isDesktop ? 12.0 : (isTablet ? 10.0 : 9.0);

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Text('Dashboard'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () => Get.toNamed(AppRoutes.bookingHistory),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    Get.toNamed(AppRoutes.profile);
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await dashboardController.fetchUnits();
                await profileController.fetchProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Container(
                      width: double.infinity,
                      height: isDesktop ? 270 : (isTablet ? 150 : 120),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppImages.dashboardBanner),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Heading & Scanner Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Select a Unit',
                                  style: TextStyle(
                                    fontSize: fontSizeTitle,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'State-of-the-art sanitation facilities, where luxury meets immaculate cleanliness',
                                  style: TextStyle(
                                    fontSize: fontSizeSubTitle,
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Obx(() {
                            final user = profileController.user.value;
                            final bool canScan =
                                user?.appPermissions?.scannerAccess ?? false;

                            if (user != null && canScan) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => _openScanner(),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          AppImages.scanIcon,
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Scan',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
/*                    if (!isDesktop)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: SearchBarTool(),
                      ),*/
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() {
                        if (dashboardController.isLoading.value) {
                          return const Center(child: CustomAppLoader(size: 60));
                        }
                        if (dashboardController.allUnitsList.isEmpty) {
                          return const Center(
                            child: Text('No units available'),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isDesktop
                                    ? 5
                                    : (isTablet ? 3 : 2),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: isDesktop
                                    ? 1.1
                                    : (isTablet ? 1.0 : 0.8),
                              ),
                          itemCount: dashboardController.allUnitsList.length,
                          itemBuilder: (context, index) {
                            final unit =
                                dashboardController.allUnitsList[index];
                            return UnitCard(
                              unitName: unit.unitId,
                              description: unit.unitLocation,
                              image: unit.unitImage,
                              date: unit.timing,
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.serviceDetails,
                                  arguments: {
                                    'unitNo': unit.unitId,
                                    'location': unit.unitLocation,
                                    'unitImage': unit.unitImage,
                                  },
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isProcessingScan = false;

  void _showAccessResult(bool success, String message) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: (success ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: success ? Colors.green : Colors.red,
                  size: 60.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                success ? "ACCESS GRANTED" : "ACCESS DENIED",
                style: AppTextStyle.style_18_700(
                  color: success ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyle.style_14_500(color: AppColors.grey400),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  Future<void> _openScanner() async {
    if (_isProcessingScan) return;

    final int cameraCount = await plutusService.getCameraCount();

    if (cameraCount > 0) {
      final MobileScannerController scannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.qrCode],
      );

      Get.to(
        () => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text("Scan QR Code"),
            backgroundColor: const Color(0xFFF15A22),
            foregroundColor: Colors.white,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: () => scannerController.switchCamera(),
              ),
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: scannerController,
                  builder: (context, state, child) {
                    final torchState = state.torchState;
                    switch (torchState) {
                      case TorchState.off:
                        return const Icon(
                          Icons.flash_off,
                          color: Colors.white54,
                        );
                      case TorchState.on:
                        return const Icon(Icons.flash_on, color: Colors.yellow);
                      default:
                        return const Icon(
                          Icons.flash_off,
                          color: Colors.white54,
                        );
                    }
                  },
                ),
                onPressed: () => scannerController.toggleTorch(),
              ),
            ],
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: scannerController,
                onDetect: (capture) async {
                  if (_isProcessingScan) return;

                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    _isProcessingScan = true;
                    final String code = barcodes.first.rawValue!;
                    
                    // Close scanner immediately to feel faster
                    Get.back();
                    
                    // Show a loader on the dashboard while calling API
                    Get.dialog(
                      const Center(child: CustomAppLoader(size: 60)), 
                      barrierDismissible: false
                    );
                    
                    final result = await dashboardController.handleScannedCode(code);
                    
                    if (Get.isDialogOpen ?? false) {
                      Get.back(); // Close loader
                    }
                    
                    if (result != null) {
                      final bool isSuccess = result['StatusCode'] == 200;
                      final String msg = result['ErrorMessage'] ?? "";
                      _showAccessResult(isSuccess, msg);
                    }
                    
                    _isProcessingScan = false;
                  }
                },
              ),
              // Zoom Slider Overlay
              Positioned(
                bottom: 40.h,
                left: 20.w,
                right: 20.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: scannerController,
                          builder: (context, state, child) {
                            return Slider(
                              value: state.zoomScale,
                              onChanged: (value) =>
                                  scannerController.setZoomScale(value),
                              activeColor: const Color(0xFFF15A22),
                              inactiveColor: Colors.white24,
                            );
                          },
                        ),
                      ),
                      const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Hardware Scanner Fallback
      try {
        _isProcessingScan = true;
        AppCommonToastMessage.show(
          message: "Initializing Terminal Scanner...",
          type: ToastType.info,
        );
        final user = profileController.user.value;
        final scannerPayload = {
          "Header": {
            "ApplicationId": "com.mFresh",
            "UserId": user?.customeUserID ?? "NA",
            "MethodId": "1007",
            "VersionNo": "1.0",
          },
        };

        final result = await plutusService.startScanner(
          jsonEncode(scannerPayload),
        );
        final data = jsonDecode(result);
        if (data['Response']?['ScannedValue'] != null &&
            data['Response']['ScannedValue'].toString().isNotEmpty) {
          String scannedValue = data['Response']['ScannedValue'].toString();
          final apiResult = await dashboardController.handleScannedCode(
            scannedValue,
          );
          if (apiResult != null) {
            _showAccessResult(
              apiResult['StatusCode'] == 200,
              apiResult['ErrorMessage'] ?? "",
            );
          }
        } else {
          String errorMsg =
              data['Response']?['ResponseMessage'] ?? "Scan cancelled";
          AppCommonToastMessage.show(message: errorMsg, type: ToastType.info);
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Scanning not supported",
          type: ToastType.error,
        );
      } finally {
        _isProcessingScan = false;
      }
    }
  }
}
