import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/data/models/user.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  Future<User?> login({required String mobile, required String password}) async {
    try {
      final response = await _apiService.post(
        AppConstants.login,
        data: {
          'mobile': mobile,
          'password': password,
        },
      );

      if (response != null && response['token'] != null) {
        final String token = response['token'];
        final user = User.fromJson(response);
        
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
        
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      final response = await _apiService.post(AppConstants.logout);
      if (response != null && response['status'] == true) {
        await _storageService.clearAllStorage();
        return true;
      }
      return false;
    } catch (e) {
      // Even if API fails, we should clear local storage for safety on logout
      await _storageService.clearAllStorage();
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
        data: {
          'phone_no': mobile,
          'otp': otp,
        },
      );

      if (response != null && response['data'] != null) {
        final user = User.fromJson(response['data']);
        final String token = response['data']['access_token'] ?? '';
        
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
        
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
