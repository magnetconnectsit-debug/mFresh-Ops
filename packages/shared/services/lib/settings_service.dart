// region Imports
import 'package:services/storage_service.dart';
import 'package:get/get.dart';
// endregion

// region SettingsService
class SettingsService extends GetxService {
  // region Variables
  final StorageService _storageService = Get.find<StorageService>();

  /// This is the reactive variable your UI will listen to.
  final RxBool showLogger = false.obs;
  final RxBool isDevMode = false.obs;
  // endregion

  // region Lifecycle
  @override
  void onInit() {
    super.onInit();

    showLogger.value = _storageService.getShowLogger();
    isDevMode.value = _storageService.getIsDevMode();
  }

  // endregion
}

// endregion










