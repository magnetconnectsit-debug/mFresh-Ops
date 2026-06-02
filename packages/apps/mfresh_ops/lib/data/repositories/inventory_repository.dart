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

  Future<dynamic> getAllotmentReport({
    required String fromMonth,
    required String toMonth,
    required int page,
    required int perPage,
  }) async {
    try {
      return await _apiService.post(
        AppConstants.allotmentReport,
        query: {'page': page},
        data: {
          "fromMonth": fromMonth,
          "toMonth": toMonth,
          "per_page": perPage,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> reverseAllotment(int allotmentId) async {
    try {
      return await _apiService.post(AppConstants.allotmentReverse, data: {
        "allotment_id": allotmentId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createStoreRoom({
    required int stateId,
    required int districtId,
    required String storeName,
  }) async {
    try {
      return await _apiService.post(AppConstants.storeRoomCreate, data: {
        "unit_state": stateId,
        "unit_dist": districtId,
        "storenm": storeName,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateStoreRoom({
    required int id,
    required int stateId,
    required int districtId,
    required String storeName,
  }) async {
    try {
      return await _apiService.post(AppConstants.storeRoomUpdate, data: {
        "id": id,
        "unit_state": stateId,
        "unit_dist": districtId,
        "storenm": storeName,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createItem({
    required String itemName,
    required String itemId,
    required int measurementUnitId,
    required int categoryId,
    required int lowQtyStore,
    required String lowQtyUnit,
  }) async {
    try {
      return await _apiService.post(AppConstants.inventoryCreate, data: {
        "Itmm": itemName,
        "Itid": itemId,
        "mes": measurementUnitId,
        "item_catagory": categoryId,
        "lowqnty": lowQtyStore,
        "lowqnty_unit": lowQtyUnit,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateItem({
    required int primaryId,
    required String itemName,
    required String itemId,
    required int measurementUnitId,
    required int categoryId,
    required int lowQtyStore,
    required String lowQtyUnit,
  }) async {
    try {
      return await _apiService.post(AppConstants.inventoryUpdate, data: {
        "inv_primaryID": primaryId,
        "inv_item_name": itemName,
        "item_idval": itemId,
        "inv_measurement_unit_id": measurementUnitId,
        "categoryIDval": categoryId,
        "low_qty": lowQtyStore,
        "low_qty_unit": lowQtyUnit,
      });
    } catch (e) {
      rethrow;
    }
  }
}
