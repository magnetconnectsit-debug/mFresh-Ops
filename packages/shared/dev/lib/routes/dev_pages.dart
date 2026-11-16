import 'package:get/get.dart';
import '../views/dev_passcode_screen.dart';
import '../views/dev_settings_screen.dart';
import '../views/log_viewer_screen.dart';
import 'dev_routes.dart';
import '../controllers/dev_settings_controller.dart';
import '../controllers/dev_passcode_controller.dart';
import '../controllers/log_viewer_controller.dart';

class DevPages {
  static final routes = [
    GetPage(
      name: DevRoutes.devPasscode,
      page: () => const DevPasscodeScreen(),
      binding: BindingsBuilder(() {
        Get.put(DevPasscodeController());
      }),
    ),
    GetPage(
      name: DevRoutes.devSettings,
      page: () => const DevSettingsScreen(),
      binding: BindingsBuilder(() {
        Get.put(DevSettingsController());
      }),
    ),
    GetPage(
      name: DevRoutes.logViewer,
      page: () => const LogViewerScreen(),
      binding: BindingsBuilder(() {
        Get.put(LogViewerController());
      }),
    ),
  ];
}
