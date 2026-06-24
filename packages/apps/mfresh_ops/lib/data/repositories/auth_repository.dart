import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:services/settings_service.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/data/models/user.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final rxUserPermissions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final user = _storageService.getUser() as User?;
    rxUserPermissions.assignAll(user?.permissions ?? []);
  }

  Future<Map<String, dynamic>> _getDeviceAndFcmInfo() async {
    bool isDev = kDebugMode;
    try {
      if (Get.isRegistered<SettingsService>()) {
        isDev = isDev || AppConfig.isDevToggle;
      }
    } catch (_) {}

    String deviceId = "";
    String appVersion = "1.0.0";

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (e) {
      debugPrint("Error fetching package info: $e");
    }

    Map<String, dynamic> deviceInfo = {
      "imei_no": "",
      "brand": "Unknown",
      "model": "Unknown",
      "manufacturer": "Unknown",
      "os": "Unknown",
      "os_version": "Unknown",
      "app_version": appVersion,
    };

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        deviceInfo = {
          "imei_no": androidInfo.id,
          "brand": androidInfo.brand,
          "model": androidInfo.model,
          "manufacturer": androidInfo.manufacturer,
          "os": "Android",
          "os_version": androidInfo.version.release,
          "app_version": appVersion,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        final resolvedId = iosInfo.identifierForVendor ?? "";
        deviceId = resolvedId;
        deviceInfo = {
          "imei_no": resolvedId,
          "brand": "Apple",
          "model": iosInfo.model,
          "manufacturer": "Apple",
          "os": "iOS",
          "os_version": iosInfo.systemVersion,
          "app_version": appVersion,
        };
      }
    } catch (e) {
      debugPrint("Error fetching device info: $e");
    }

    String fcmToken = '';
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken = token;
      }
    } catch (e) {
      debugPrint("Error fetching real FCM token: $e");
    }

    if (isDev) {
      deviceId = "W1VBS36.62-22-17-2";
      deviceInfo["imei_no"] = "W1VBS36.62-22-17-2";
      fcmToken = "firebase_token";
    }

    return {
      'device_id': deviceId,
      'fcm_token': fcmToken,
      'device_info': deviceInfo,
    };
  }

  Future<User?> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final devInfo = await _getDeviceAndFcmInfo();

      final response = await _apiService.post(
        AppConstants.login,
        data: {
          'mobile': mobile,
          'password': password,
          'device_id': devInfo['device_id'],
          'fcm_token': devInfo['fcm_token'],
          'device_info': devInfo['device_info'],
        },
      );

      if (response != null) {
        if (response['token'] != null) {
          final String token = response['token'];
          final String? refreshToken = response['refresh_token'];
          final user = User.fromJson(response);

          await _storageService.saveToken(token);
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);

          return user;
        } else if (response['error'] != null) {
          throw Exception(response['error'].toString());
        } else if (response['message'] != null) {
          throw Exception(response['message'].toString());
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> fetchProfile() async {
    try {
      final response = await _apiService.get(AppConstants.profile);

      if (response != null && response['user'] != null) {
        final user = User.fromJson(response);
        await _storageService.saveUser(user);
        rxUserPermissions.assignAll(user.permissions ?? []);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      try {
        await _apiService.post(AppConstants.trackingDutyOff);
      } catch (e) {
        debugPrint('AuthRepository: dutyOff Exception during logout: $e');
      }

      final response = await _apiService.post(AppConstants.logout);
      if (response != null && response['status'] == true) {
        await _storageService.clearAllStorage();
        rxUserPermissions.clear();
        return true;
      }
      return false;
    } catch (e) {
      // Even if API fails, we should clear local storage for safety on logout
      await _storageService.clearAllStorage();
      rxUserPermissions.clear();
      return true;
    }
  }

  Future<bool> sendOtp({required String mobile}) async {
    try {
      final response = await _apiService.post(
        AppConstants.sendOtp,
        data: {'mob': mobile},
      );
      
      if (response != null) {
        if (response['status'] == true) {
          return true;
        } else if (response['message'] != null) {
          throw Exception(response['message'].toString());
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> verifyOtp({required String mobile, required String otp}) async {
    try {
      final devInfo = await _getDeviceAndFcmInfo();

      final response = await _apiService.post(
        AppConstants.verifyOtp,
        data: {
          'mob': mobile, 
          'otp': otp,
          'device_id': devInfo['device_id'],
          'fcm_token': devInfo['fcm_token'],
          'device_info': devInfo['device_info'],
        },
      );

      if (response != null) {
        if (response['token'] != null) {
          final String token = response['token'];
          final String? refreshToken = response['refresh_token'];
          final user = User.fromJson(response);

          await _storageService.saveToken(token);
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);

          return user;
        } else if (response['error'] != null) {
          throw Exception(response['error'].toString());
        } else if (response['message'] != null) {
          throw Exception(response['message'].toString());
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
