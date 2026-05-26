import 'package:get/get.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onReady() {
    super.onReady();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for 3 seconds to ensure visibility
    await Future.delayed(const Duration(seconds: 2));

    final token = _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
