import 'package:get/get.dart';
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

  Future<User?> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.login,
        data: {'mobile': mobile, 'password': password},
      );

      if (response != null && response['token'] != null) {
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
        data: {'phone_no': mobile},
      );
      return response != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> verifyOtp({required String mobile, required String otp}) async {
    try {
      final response = await _apiService.post(
        AppConstants.verifyOtp,
        data: {'phone_no': mobile, 'otp': otp},
      );

      if (response != null && response['data'] != null) {
        final user = User.fromJson(response['data']);
        final String token = response['data']['access_token'] ?? '';

        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
        rxUserPermissions.assignAll(user.permissions ?? []);

        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
