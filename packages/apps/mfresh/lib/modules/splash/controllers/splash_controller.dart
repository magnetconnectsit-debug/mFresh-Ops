import 'package:get/get.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for a few seconds for the splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (_storage.getToken() != null) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
