import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:services/api_services.dart';

class AssetCategoryRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetch all asset categories
  Future<List<AssetCategoryModel>> fetchCategories() async {
    try {
      final response = await _apiService.get(AppConstants.assetCategoryList);
      if (response != null && response['status'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((e) => AssetCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[AssetCategoryRepository] fetchCategories error: $e');
      rethrow;
    }
    return [];
  }

  /// Store new asset category
  Future<Map<String, dynamic>?> storeCategory({required String name}) async {
    try {
      final response = await _apiService.post(
        AppConstants.assetCategoryStore,
        data: {'asset_cat_name': name},
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
    } catch (e) {
      debugPrint('[AssetCategoryRepository] storeCategory error: $e');
      rethrow;
    }
    return null;
  }

  /// Update existing asset category
  Future<Map<String, dynamic>?> updateCategory({
    required int id,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.assetCategoryUpdate,
        data: {
          'category_id': id,
          'asset_cat_name': name,
        },
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
    } catch (e) {
      debugPrint('[AssetCategoryRepository] updateCategory error: $e');
      rethrow;
    }
    return null;
  }

  /// Delete asset category
  Future<Map<String, dynamic>?> deleteCategory({required int id}) async {
    try {
      final response = await _apiService.post(
        AppConstants.assetCategoryDelete,
        data: {'category_id': id},
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
    } catch (e) {
      debugPrint('[AssetCategoryRepository] deleteCategory error: $e');
      rethrow;
    }
    return null;
  }
}
