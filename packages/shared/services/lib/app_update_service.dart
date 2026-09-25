// region Imports
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
// endregion

class AppUpdateService extends GetxService {

  Future<bool> checkForUpdate() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidUpdate();
      } else if (Platform.isIOS) {
        return await _checkIosUpdate();
      }
    } catch (e) {
      debugPrint("AppUpdateService Error: $e");
    }
    return false;
  }

  Future<bool> _checkAndroidUpdate() async {
    try {
      final plugin = InAppUpdateFlutter();
      final info = await plugin.checkUpdateAndroid();
      if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable) {
        if (info.isImmediateUpdateAllowed) {
          await plugin.startImmediateUpdateAndroid();
          return true;
        }
      }
    } catch (e) {
      debugPrint("AppUpdateService Android Error: $e");
    }
    return false;
  }

  Future<bool> _checkIosUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final bundleId = packageInfo.packageName;
      final currentVersion = packageInfo.version;
      
      final response = await Dio().get('https://itunes.apple.com/lookup?bundleId=$bundleId');
      
      if (response.statusCode == 200) {
        var json = response.data;
        if (json is String) {
          json = jsonDecode(json);
        }
        
        if (json['resultCount'] != null && json['resultCount'] > 0) {
          final storeVersion = json['results'][0]['version']?.toString();
          final trackId = json['results'][0]['trackId']?.toString();
          
          if (storeVersion != null && trackId != null) {
            if (_isUpdateAvailable(currentVersion: currentVersion, storeVersion: storeVersion)) {
              debugPrint("AppUpdateService: iOS Update detected. Showing StoreKit...");
              await InAppUpdateFlutter().showUpdateForIos(appStoreId: trackId);
              return true;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("AppUpdateService iOS Error: $e");
    }
    return false;
  }

  bool _isUpdateAvailable({
    required String currentVersion,
    required String storeVersion,
  }) {
    int versionComparison = _compareVersion(currentVersion, storeVersion);
    if (versionComparison < 0) return true; // Store version is higher
    return false;
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
