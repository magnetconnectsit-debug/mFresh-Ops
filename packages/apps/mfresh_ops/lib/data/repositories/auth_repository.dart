// region Imports
import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/booking/booking_guest_auth_models.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:services/api_services.dart';
import 'package:services/settings_service.dart';
import 'package:services/storage_service.dart';
// endregion

// region AuthRepository Class
class AuthRepository extends GetxService {
  // region Dependencies & Services
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  // endregion

  // region Observables & State Variables
  final rxUserPermissions = <String>[].obs;
  final rxIsCheckedIn = false.obs;
  final isSubmittingAttendance = false.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    final user = _storageService.getUser() as User?;
    rxUserPermissions.assignAll(user?.permissions ?? []);
    rxIsCheckedIn.value = user?.isCheckedIn ?? false;
  }
  // endregion

  // region Device & FCM Info
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
        const _androidIdPlugin = AndroidId();
        final String? realAndroidId = await _androidIdPlugin.getId();
        deviceId = realAndroidId ?? androidInfo.id;
        deviceInfo = {
          "imei_no": deviceId,
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
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // On iOS, the FCM token requires the APNs token to be generated first.
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await messaging.getAPNSToken();
        }
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken = token;
      }
    } catch (e) {
      debugPrint("Error fetching real FCM token: $e");
    }

    return {
      'device_id': deviceId,
      'fcm_token': fcmToken,
      'device_info': deviceInfo,
      'is_dev': isDev ? 1 : 0,
    };
  }
  // endregion

  // region Authentication API Operations
  Future<User?> login({
    required String mobile,
    required String password,
    String loginMode = 'operation',
  }) async {
    try {
      final devInfo = await _getDeviceAndFcmInfo();

      final response = await _apiService.post(
        AppConstants.login,
        data: {
          'mobile': mobile,
          'login_id': mobile,
          'user_id': mobile,
          'password': password,
          'device_id': devInfo['device_id'],
          'is_dev': devInfo['is_dev'],
          'fcm_token': devInfo['fcm_token'],
          'device_info': devInfo['device_info'],
          'login_mode': loginMode,
        },
      );

      if (response != null) {
        if (response['token'] != null) {
          final String token = response['token'];
          final String? refreshToken = response['refresh_token'];
          final user = User.fromJson(response);

          await _storageService.saveToken(token);
          await _storageService.saveLoginMode(loginMode);
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);
          rxIsCheckedIn.value = user.isCheckedIn ?? false;

          final bool isOnDuty = user.isOnDuty == 1;
          try {
            if (Get.isRegistered<TrackingService>()) {
              await Get.find<TrackingService>().syncDutyStatus(isOnDuty);
            }
          } catch (_) {}

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

      if (response != null) {
        // Direct permission extraction to guarantee permissions refresh even if response payload format varies
        final permissionsSource =
            response['permissions'] ??
            (response['data'] is Map
                ? response['data']['permissions']
                : null) ??
            (response['user'] is Map ? response['user']['permissions'] : null);

        final List<String> extractedPermissions = [];
        if (permissionsSource is Map) {
          permissionsSource.forEach((key, value) {
            final bool isGranted =
                value == true ||
                value == 1 ||
                value == 'true' ||
                value == '1' ||
                value == 'yes';
            if (isGranted) {
              extractedPermissions.add(key.toString());
            }
          });
          rxUserPermissions.assignAll(extractedPermissions);
        } else if (permissionsSource is List) {
          for (final item in permissionsSource) {
            if (item is String) {
              extractedPermissions.add(item);
            } else if (item is Map) {
              final name = item['name'] ?? item['permission'] ?? item['title'];
              final val = item['value'] ?? item['status'] ?? item['is_active'];
              final bool isGranted =
                  val == true ||
                  val == 1 ||
                  val == 'true' ||
                  val == '1' ||
                  val == 'yes';
              if (name != null && isGranted) {
                extractedPermissions.add(name.toString());
              }
            }
          }
          rxUserPermissions.assignAll(extractedPermissions);
        }

        if (response['user'] != null ||
            response['id'] != null ||
            response['data'] != null) {
          final user = User.fromJson(response);
          final userToSave =
              (extractedPermissions.isNotEmpty || permissionsSource is Map)
              ? user.copyWith(permissions: extractedPermissions)
              : user;
          await _storageService.saveUser(userToSave);
          if (userToSave.permissions != null) {
            rxUserPermissions.assignAll(userToSave.permissions!);
          }
          rxIsCheckedIn.value = userToSave.isCheckedIn ?? false;

          final bool isOnDuty = userToSave.isOnDuty == 1;
          try {
            if (Get.isRegistered<TrackingService>()) {
              await Get.find<TrackingService>().syncDutyStatus(isOnDuty);
            }
          } catch (_) {}

          return userToSave;
        }
      }
      return null;
    } catch (e) {
      debugPrint("AuthRepository.fetchProfile error: $e");
      return null;
    }
  }

  /// Explicit refresh method for pull-to-refresh to reload permissions and user state
  Future<void> refreshPermissions() async {
    await fetchProfile();
  }

  Future<bool> logout() async {
    try {
      try {
        await _apiService.post(AppConstants.trackingDutyOff);
        try {
          await Get.find<TrackingService>().stopTracking();
        } catch (e) {
          debugPrint(
            'AuthRepository: stopTracking Exception during logout: $e',
          );
        }
      } catch (e) {
        debugPrint('AuthRepository: dutyOff Exception during logout: $e');
      }

      final response = await _apiService.post(AppConstants.logout);
      if (response != null && response['status'] == true) {
        await _storageService.clearAllStorage();
        rxUserPermissions.clear();
        rxIsCheckedIn.value = false;
        return true;
      }
      return false;
    } catch (e) {
      // Even if API fails, we should clear local storage for safety on logout
      await _storageService.clearAllStorage();
      rxUserPermissions.clear();
      rxIsCheckedIn.value = false;
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

  Future<User?> verifyOtp({
    required String mobile,
    required String otp,
    String loginMode = 'operation',
  }) async {
    try {
      final devInfo = await _getDeviceAndFcmInfo();

      final response = await _apiService.post(
        AppConstants.verifyOtp,
        data: {
          'mob': mobile,
          'otp': otp,
          'device_id': devInfo['device_id'],
          'is_dev': devInfo['is_dev'],
          'fcm_token': devInfo['fcm_token'],
          'device_info': devInfo['device_info'],
          'login_mode': loginMode,
        },
      );

      if (response != null) {
        if (response['token'] != null) {
          final String token = response['token'];
          final String? refreshToken = response['refresh_token'];
          final user = User.fromJson(response);

          await _storageService.saveToken(token);
          await _storageService.saveLoginMode(loginMode);
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);
          rxIsCheckedIn.value = user.isCheckedIn ?? false;

          final bool isOnDuty = user.isOnDuty == 1;
          try {
            if (Get.isRegistered<TrackingService>()) {
              await Get.find<TrackingService>().syncDutyStatus(isOnDuty);
            }
          } catch (_) {}

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
  // endregion

  // region Booking & Guest Authentication Operations
  Future<Map<String, dynamic>> bookingPasswordLogin({
    required String loginId,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.login,
        data: {
          'login_id': loginId,
          'password': password,
          'login_mode': 'booking',
        },
      );

          if (response != null && response is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response);

        // If Employee direct JWT login
        if (data['status'] == true && data['token'] != null) {
          final String token = data['token'];
          final String? refreshToken = data['refresh_token'];
          final user = User.fromJson(data);

          await _storageService.saveToken(token);
          await _storageService.saveLoginMode('booking');
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);
          rxIsCheckedIn.value = user.isCheckedIn ?? false;
        }

        return data;
      }
      return {'status': false, 'message': 'Invalid response from server'};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> employeeBookingSendOtp({
    required String mobile,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.bookingSendOtp,
        data: {'mob': mobile},
      );
      if (response != null && response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {'status': false, 'message': 'Failed to send OTP'};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> employeeBookingVerifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.bookingVerifyOtp,
        data: {'mob': mobile, 'otp': otp},
      );

      if (response != null && response is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response);
        if (data['status'] == true && data['token'] != null) {
          final String token = data['token'];
          final String? refreshToken = data['refresh_token'];
          final user = User.fromJson(data);

          await _storageService.saveToken(token);
          await _storageService.saveLoginMode('booking');
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);
          rxIsCheckedIn.value = user.isCheckedIn ?? false;
        }
        return data;
      }
      return {'status': false, 'message': 'Failed to verify OTP'};
    } catch (e) {
      rethrow;
    }
  }

  Future<GuestCheckMobileResult> guestCheckMobile({
    required String mobile,
    required String guestFlowToken,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.bookingGuestCheckMobile,
        data: {'mob': mobile},
        options: dio.Options(
          headers: {'Authorization': 'Bearer $guestFlowToken'},
        ),
      );

      if (response != null && response is Map) {
        return GuestCheckMobileResult.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
      return GuestCheckMobileResult(
        status: false,
        message: 'Invalid response from server',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<GuestCheckMobileResult> guestRegister({
    required String mobile,
    required String name,
    required String guestFlowToken,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.bookingGuestRegister,
        data: {'mob': mobile, 'name': name},
        options: dio.Options(
          headers: {'Authorization': 'Bearer $guestFlowToken'},
        ),
      );

      if (response != null && response is Map) {
        return GuestCheckMobileResult.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
      return GuestCheckMobileResult(
        status: false,
        message: 'Registration failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<GuestSendOtpResult> guestSendOtp({
    required String mobile,
    required String guestFlowToken,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.bookingGuestSendOtp,
        data: {'mob': mobile},
        options: dio.Options(
          headers: {'Authorization': 'Bearer $guestFlowToken'},
        ),
      );

      if (response != null && response is Map) {
        return GuestSendOtpResult.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
      return GuestSendOtpResult(
        status: false,
        message: 'Failed to send OTP to guest cashier',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> guestVerifyOtp({
    required String mobile,
    required String otp,
    required String otpVerificationToken,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.bookingGuestVerifyOtp,
        data: {'mob': mobile, 'otp': otp},
        options: dio.Options(
          headers: {'Authorization': 'Bearer $otpVerificationToken'},
        ),
      );

      if (response != null && response is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response);

        if (data['status'] == true && data['token'] != null) {
          final String token = data['token'];
          final String? refreshToken = data['refresh_token'];
          final user = User.fromJson(data);

          await _storageService.saveToken(token);
          await _storageService.saveLoginMode('booking');
          if (refreshToken != null) {
            await _storageService.saveRefreshToken(refreshToken);
          }
          await _storageService.saveUser(user);
          rxUserPermissions.assignAll(user.permissions ?? []);
          rxIsCheckedIn.value = user.isCheckedIn ?? false;
        }

        return data;
      }
      return {'status': false, 'message': 'Failed to verify guest OTP'};
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.post(
        AppConstants.refreshToken,
      );

      if (response != null && response is Map) {
        final String? newToken =
            response['access_token']?.toString() ?? response['token']?.toString();
        if (newToken != null && newToken.isNotEmpty) {
          await _storageService.saveToken(newToken);
          final String? newRefreshToken = response['refresh_token']?.toString();
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("AuthRepository.refreshToken error: $e");
      return false;
    }
  }
  // endregion

  // region Attendance (Check-In & Check-Out)
  Future<bool> attendanceCheckIn({
    required String imagePath,
    String? unitId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      isSubmittingAttendance.value = true;
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Captured image file not found.');
      }

      double? lat = latitude;
      double? lng = longitude;
      if (lat == null || lng == null) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
          lat ??= pos.latitude;
          lng ??= pos.longitude;
        } catch (_) {
          try {
            final lastPos = await Geolocator.getLastKnownPosition();
            if (lastPos != null) {
              lat ??= lastPos.latitude;
              lng ??= lastPos.longitude;
            }
          } catch (e) {
            debugPrint('Failed to get location for check-in: $e');
          }
        }
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final Map<String, dynamic> dataMap = {
        'image': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (unitId != null && unitId.isNotEmpty) 'unit_id': unitId,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        if (lat != null) 'lat': lat,
        if (lng != null) 'long': lng,
      };
      final formData = dio.FormData.fromMap(dataMap);

      final response = await _apiService.post(
        AppConstants.attendanceCheckIn,
        data: formData,
      );

      if (response != null &&
          (response['status'] == true ||
              response['status'] == 'success' ||
              response['success'] == true)) {
        rxIsCheckedIn.value = true;

        final currentUser = _storageService.getUser() as User?;
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(isCheckedIn: true);
          await _storageService.saveUser(updatedUser);
        }

        final msg =
            response['message']?.toString() ?? 'Checked in successfully.';
        AppCommonToastMessage.show(message: msg, type: ToastType.success);

        fetchProfile();
        return true;
      } else {
        final errorMsg =
            response?['message']?.toString() ??
            response?['error']?.toString() ??
            'Failed to check in. Please try again.';
        AppCommonToastMessage.show(
          message: errorMsg,
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in attendanceCheckIn: $e');
      AppCommonToastMessage.show(
        message:
            'Error during check-in: ${e.toString().replaceAll("Exception: ", "")}',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmittingAttendance.value = false;
    }
  }

  Future<bool> attendanceCheckOut({
    required String imagePath,
    double? latitude,
    double? longitude,
  }) async {
    try {
      isSubmittingAttendance.value = true;
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Captured image file not found.');
      }

      double? lat = latitude;
      double? lng = longitude;
      if (lat == null || lng == null) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
          lat ??= pos.latitude;
          lng ??= pos.longitude;
        } catch (_) {
          try {
            final lastPos = await Geolocator.getLastKnownPosition();
            if (lastPos != null) {
              lat ??= lastPos.latitude;
              lng ??= lastPos.longitude;
            }
          } catch (e) {
            debugPrint('Failed to get location for check-out: $e');
          }
        }
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final Map<String, dynamic> dataMap = {
        'image': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        if (lat != null) 'lat': lat,
        if (lng != null) 'long': lng,
      };
      final formData = dio.FormData.fromMap(dataMap);

      final response = await _apiService.post(
        AppConstants.attendanceCheckOut,
        data: formData,
      );

      if (response != null &&
          (response['status'] == true ||
              response['status'] == 'success' ||
              response['success'] == true)) {
        rxIsCheckedIn.value = false;

        final currentUser = _storageService.getUser() as User?;
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(isCheckedIn: false);
          await _storageService.saveUser(updatedUser);
        }

        final msg =
            response['message']?.toString() ?? 'Checked out successfully.';
        AppCommonToastMessage.show(message: msg, type: ToastType.success);

        fetchProfile();
        return true;
      } else {
        final errorMsg =
            response?['message']?.toString() ??
            response?['error']?.toString() ??
            'Failed to check out. Please try again.';
        AppCommonToastMessage.show(
          message: errorMsg,
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in attendanceCheckOut: $e');
      AppCommonToastMessage.show(
        message:
            'Error during check-out: ${e.toString().replaceAll("Exception: ", "")}',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmittingAttendance.value = false;
    }
  }
  // endregion
}

// endregion

