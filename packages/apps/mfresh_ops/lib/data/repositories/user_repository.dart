import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';

class UserRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get(AppConstants.profile);
      if (response != null && response['user'] != null) {
        final user = User.fromJson(response);
        await _storageService.saveUser(user);
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

      if (response != null &&
          (response['user'] != null || response['data'] != null)) {
        return await getProfile();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
