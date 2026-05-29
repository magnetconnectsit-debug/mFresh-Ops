import 'package:get/get.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';

class InventoryRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<dynamic> getStates() async {
    try {
      return await _apiService.post(AppConstants.invGetStates);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getDistricts(String stateId) async {
    try {
      return await _apiService.post(AppConstants.invStatesWiseDistrict, data: {'state': stateId});
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getStores(String stateId, String districtId) async {
    try {
      return await _apiService.post(AppConstants.invStores, data: {
        'state': stateId,
        'district': districtId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getCategories() async {
    try {
      return await _apiService.post(AppConstants.invCategory);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAllItems() async {
    try {
      return await _apiService.post(AppConstants.inventoryAllItems);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getInventoryStock({
    required String itemId,
    required String storeId,
    required String categoryId,
    required String stateId,
    required String districtId,
  }) async {
    try {
      return await _apiService.post(AppConstants.invStoreStockView, data: {
        "item_id": itemId,
        "store_id": storeId,
        "category_id": categoryId,
        "state_id": stateId,
        "district_id": districtId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> allocateStock(Map<String, dynamic> data) async {
    try {
      return await _apiService.post(AppConstants.invStoreToUnitAllocate, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> consumeStock(Map<String, dynamic> data) async {
    try {
      return await _apiService.post(AppConstants.inventoryConsume, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSupportUnits() async {
    try {
      return await _apiService.post(AppConstants.supportUnits, data: {});
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUnitInventoryStock() async {
    try {
      return await _apiService.post(AppConstants.inventoryUnitStock, data: {
        "item_id": "",
        "unit_id": "",
        "category_id": "",
        "state_id": "",
        "district_id": "",
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getItemsByCategory(String categoryId) async {
    try {
      return await _apiService.post(AppConstants.invCategoryWiseItem, data: {
        "category_id": categoryId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addStoreStock(Map<String, dynamic> data) async {
    try {
      return await _apiService.post(AppConstants.invEntryStoreStock, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
