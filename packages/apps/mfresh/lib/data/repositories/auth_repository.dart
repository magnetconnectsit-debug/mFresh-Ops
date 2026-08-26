import 'package:get/get.dart';
import 'package:mfresh/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh/data/models/user.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  Future<User?> login({required String mobile, required String password}) async {
    try {
      final response = await _apiService.post(
        AppConstants.login,
        data: {
          'mob': mobile,
          'password': password,
        },
      );

      if (response != null && response['status'] == 'error' && response['message'] != null) {
        throw response['message'].toString();
      }

      if (response != null && response['data'] is Map<String, dynamic> && response['data']['access_token'] != null) {
        final String token = response['data']['access_token'];
        await _storageService.saveToken(token);
        
        // Parse user from the whole response (contains 'user' and 'permissions' inside 'data')
        final user = User.fromJson(response); 
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
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
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
      if (response != null && response['status'] == 'error' && response['message'] != null) {
        throw response['message'].toString();
      }
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

      if (response != null && response['status'] == 'error' && response['message'] != null) {
        throw response['message'].toString();
      }

      if (response != null && response['data'] is Map<String, dynamic>) {
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

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.signup,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response != null && response['data'] != null && response['data']['access_token'] != null) {
        final String token = response['data']['access_token'];
        await _storageService.saveToken(token);
        
        final user = User.fromJson(response); 
        await _storageService.saveUser(user);
        
        return response;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
