import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';

class CollectionRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>?> getAdminCollections({
    String? month,
    String? date,
    String? state,
    String? district,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (month != null && month.isNotEmpty) data['month'] = month;
      if (date != null && date.isNotEmpty) data['date'] = date;
      if (state != null && state.isNotEmpty) data['state_id'] = state;
      if (district != null && district.isNotEmpty) data['district_id'] = district;

      final response = await _apiService.get(
        AppConstants.adminCollectionIndex,
        query: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserCollections({
    String? month,
    String? date,
    String? state,
    String? district,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (month != null && month.isNotEmpty) data['month'] = month;
      if (date != null && date.isNotEmpty) data['date'] = date;
      if (state != null && state.isNotEmpty) data['state_id'] = state;
      if (district != null && district.isNotEmpty) data['district_id'] = district;

      final response = await _apiService.get(
        AppConstants.collectionIndex,
        query: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
