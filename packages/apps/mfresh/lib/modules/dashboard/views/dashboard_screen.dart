import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mfresh/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh/modules/dashboard/views/widgets/unit_card.dart';
import 'package:mfresh/modules/dashboard/views/widgets/search_bar_tool.dart';
import 'package:services/plutus_service.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_images.dart';
import 'package:mfresh/data/models/unit_model.dart';
import 'package:mfresh/core/config/app_config.dart';

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
            body: SingleChildScrollView(
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
                          if (user != null && user.role == "3") {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () async {
                                  final scannerPayload = {
                                    "Header": {
                                      "ApplicationId": AppConfig.applicationId,
                                      "UserId": "user1234",
                                      "MethodId": "1007",
                                      "VersionNo": "1.0",
                                    },
                                  };
                                  try {
                                    final result = await plutusService
                                        .startScanner(
                                          jsonEncode(scannerPayload),
                                        );
                                    final data = jsonDecode(result);
                                    if (data['Response']?['ScannedValue'] !=
                                        null) {
                                      String scannedUnitId =
                                          data['Response']['ScannedValue'];
                                      // Find the unit in the list to get its location
                                      final unit = dashboardController
                                          .allUnitsList
                                          .firstWhere(
                                            (u) => u.unitId == scannedUnitId,
                                            orElse: () => UnitModel(
                                              id: 0,
                                              unitId: scannedUnitId,
                                              unitImage: '',
                                              unitLocation: 'Scanned Location',
                                              timing: '',
                                            ),
                                          );

                                      Get.toNamed(
                                        AppRoutes.serviceDetails,
                                        arguments: {
                                          'unitNo': unit.unitId,
                                          'location': unit.unitLocation,
                                          'unitImage': unit.unitImage,
                                        },
                                      );
                                    } else {
                                      AppCommonToastMessage.show(
                                        message: "Scanner: No value scanned",
                                        type: ToastType.info,
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint("Scanner Error: $e");
                                  }
                                },
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

                  if (!isDesktop)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SearchBarTool(),
                    ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() {
                      if (dashboardController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (dashboardController.allUnitsList.isEmpty) {
                        return const Center(child: Text('No units available'));
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 5 : (isTablet ? 3 : 2),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: isDesktop ? 1.1 : (isTablet ? 1.0 : 0.8),
                        ),
                        itemCount: dashboardController.allUnitsList.length,
                        itemBuilder: (context, index) {
                          final unit = dashboardController.allUnitsList[index];
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
          );
        },
      ),
    );
  }
}
