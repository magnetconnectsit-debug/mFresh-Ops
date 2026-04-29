import 'package:get/get.dart';
import 'package:core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
import 'package:models/auth/user.dart';

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

  Future<User?> updateProfile({required String name}) async {
    try {
      final response = await _apiService.post(
        AppConstants.profileUpdate,
        data: {'name': name},
      );
      // If profile update returns user data, update local storage
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
}
