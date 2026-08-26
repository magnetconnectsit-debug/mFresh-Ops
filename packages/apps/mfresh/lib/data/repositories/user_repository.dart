import 'package:get/get.dart';
import 'package:mfresh/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh/data/models/user.dart';
import 'package:mfresh/data/models/booking_history_model.dart';

class UserRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  Future<User?> getProfile() async {
    try {
      final response = await _apiService.post(AppConstants.profile);
      if (response != null && response['data'] != null) {
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

  Future<Map<String, dynamic>?> editProfile({
    required String name,
    required String email,
    required String mob,
    required String profileImage,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.profileEdit,
        data: {
          "name": name,
          "email": email,
          "mob": mob,
          "profile_image": profileImage,
          "pass": password,
        },
      );
      if (response != null && response['status'] == 'success') {
         return response;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BookingHistoryModel>> getBookingHistory() async {
    try {
      final response = await _apiService.post(AppConstants.bookingHistory);
      if (response != null && response['status'] == 'success') {
        final Map<String, dynamic> data = response['data'] ?? {};
        return data.values.map((e) => BookingHistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> deleteAccount(int userId) async {
    try {
      final response = await _apiService.post(
        AppConstants.deleteProfile,
        data: {"id": userId},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
