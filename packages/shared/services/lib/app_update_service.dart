// region Imports
import 'dart:io';

import 'package:models/app/app_update_config.dart';
import 'package:services/remote_config_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
// endregion

class UpdateInfo {
  final bool isAvailable;
  final bool isForceUpdate;
  final String message;
  final String storeUrl;
  final String versionName;

  UpdateInfo({
    required this.isAvailable,
    this.isForceUpdate = false,
    this.message = '',
    this.storeUrl = '',
    this.versionName = '',
  });

  factory UpdateInfo.none() => UpdateInfo(isAvailable: false);
}

class AppUpdateService extends GetxService {
  final _remoteConfigService = Get.find<RemoteConfigService>();

  bool _sessionUpdateSkipped = false;

  void setUpdateSkipped(bool value) {
    _sessionUpdateSkipped = value;
  }

  Future<UpdateInfo> getUpdateInfo() async {
    try {
      if (Platform.isAndroid) {
        final info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
            return UpdateInfo(
                isAvailable: true,
                isForceUpdate: true, // Android is always immediate/force as per current logic
            );
        }
      } else if (Platform.isIOS) {
        String jsonStr = _remoteConfigService.getStringValue('app_update_settings');
        if (jsonStr.isNotEmpty) {
            final config = AppUpdateConfig.fromRemoteConfig(jsonStr);
            if (_sessionUpdateSkipped && !config.isIosForceUpdate) {
                return UpdateInfo.none();
            }
            final packageInfo = await PackageInfo.fromPlatform();
            final currentVersion = packageInfo.version;
            final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

            if (_isUpdateAvailable(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                storeVersion: config.currentIosAppVersion,
                storeBuild: config.currentIosAppBuildNumber,
            )) {
                return UpdateInfo(
                    isAvailable: true,
                    isForceUpdate: config.isIosForceUpdate,
                    message: config.updateMessage,
                    storeUrl: config.appleStoreUrl,
                    versionName: config.currentIosAppVersion,
                );
            }
        }
      }
    } catch (e) {
      debugPrint("AppUpdateService Error: $e");
    }
    return UpdateInfo.none();
  }

  Future<void> performAndroidUpdate() async {
      try {
          await InAppUpdate.performImmediateUpdate();
      } catch (e) {
          debugPrint("AppUpdateService Android Update Error: $e");
      }
  }

  bool _isUpdateAvailable({
    required String currentVersion,
    required int currentBuild,
    required String storeVersion,
    required int storeBuild,
  }) {
    int versionComparison = _compareVersion(currentVersion, storeVersion);
    if (versionComparison < 0) return true;
    if (versionComparison > 0) return false;
    return storeBuild > currentBuild;
  }

  int _compareVersion(String current, String store) {
    try {
      List<int> cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> sParts = store.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      int maxLength = cParts.length > sParts.length ? cParts.length : sParts.length;
      for (int i = 0; i < maxLength; i++) {
        int cV = i < cParts.length ? cParts[i] : 0;
        int sV = i < sParts.length ? sParts[i] : 0;
        if (sV > cV) return -1;
        if (cV > sV) return 1;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}




