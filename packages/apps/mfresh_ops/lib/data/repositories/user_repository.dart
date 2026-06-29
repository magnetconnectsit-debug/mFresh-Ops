import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';
import 'dart:io';
import 'package:dio/dio.dart' as d;

class UserRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get(AppConstants.profile);
      if (response != null && response['user'] != null) {
        final user = User.fromJson(response);
        await _storageService.saveUser(user);
        
        // Ensure tracking service syncs with the updated user duty status
        try {
          Get.find<TrackingService>().startAutoTracking();
        } catch (_) {}

        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      final response = await _apiService.post(
        AppConstants.passwordUpdate,
        data: {'new_password': newPassword},
      );
      return response != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> updateProfile({required String name, File? image}) async {
    try {
      dynamic data;
      if (image != null) {
        data = d.FormData.fromMap({
          'name': name,
          'folder_path': 'images/profile_Images',
          'image': await d.MultipartFile.fromFile(image.path),
        });
      } else {
        data = {'name': name};
      }

      final response = await _apiService.post(
        AppConstants.profileUpdate,
        data: data,
      );
      
      // If profile update returns user data, update local storage
      if (response != null && (response['user'] != null || response['data'] != null)) {
        // Fetch full profile again to get updated URL, or parse data.
        // Wait, the profile-update API returns {"status": true, "message": "...", "data": {"name": "...", "image": "..."}}
        // The GET profile API returns full user object. It's safer to re-fetch the profile.
        return await getProfile();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
