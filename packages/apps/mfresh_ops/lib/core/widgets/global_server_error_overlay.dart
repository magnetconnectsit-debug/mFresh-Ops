// region Imports
import 'package:core/widgets/server_maintenance_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
// endregion

// region ServerErrorService
class ServerErrorService extends GetxService {
  // region Observables & State Variables
  final isServerError = false.obs;
  final serverErrorMessage = ''.obs;
  VoidCallback? _lastRetryAction;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    if (AppConfig.simulateServerMaintenance) {
      notifyServerError(
        message: 'Simulation: Server is currently under maintenance.',
      );
    }
  }
  // endregion

  // region Public API
  void notifyServerError({String? message, VoidCallback? onRetry}) {
    serverErrorMessage.value = message ?? 'Internal server error occurred.';
    _lastRetryAction = onRetry;
    isServerError.value = true;
  }

  void clearServerError() {
    isServerError.value = false;
    serverErrorMessage.value = '';
    _lastRetryAction = null;
  }

  void retry() {
    final retryAction = _lastRetryAction;
    clearServerError();
    retryAction?.call();
  }
  // endregion
}
// endregion

// region GlobalServerErrorOverlay
class GlobalServerErrorOverlay extends StatelessWidget {
  const GlobalServerErrorOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ServerErrorService>()) {
      return const SizedBox.shrink();
    }

    final service = Get.find<ServerErrorService>();

    return Obx(() {
      final shouldShow =
          service.isServerError.value || AppConfig.simulateServerMaintenance;

      if (!shouldShow) {
        return const SizedBox.shrink();
      }

      return Positioned.fill(
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: ServerMaintenanceWidget(
              message: service.serverErrorMessage.value.isNotEmpty
                  ? service.serverErrorMessage.value
                  : null,
              onRefresh: () => service.retry(),
            ),
          ),
        ),
      );
    });
  }
}
// endregion
