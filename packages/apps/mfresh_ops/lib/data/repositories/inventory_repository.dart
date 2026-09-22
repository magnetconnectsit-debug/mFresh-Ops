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
    required List<int> itemId,
    required List<int> storeId,
    required List<int> categoryId,
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

  Future<dynamic> submitInventoryAudit({
    required int unitId,
    required int auditedBy,
    required String auditDate,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      return await _apiService.post(AppConstants.inventoryAuditSubmit, data: {
        'unit_id': unitId,
        'audited_by': auditedBy,
        'audit_date': auditDate,
        'items': items,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAuditReport({
    int page = 1,
    int perPage = 25,
    String? unitId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      return await _apiService.post(
        AppConstants.inventoryAuditReport,
        query: {'page': page},
        data: {
          if (unitId != null && unitId.isNotEmpty) 'unit_id': unitId,
          if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
          if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
          'per_page': perPage,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAuditDetail(int auditId) async {
    try {
      return await _apiService.post(AppConstants.inventoryAuditDetail, data: {
        'audit_id': auditId,
      });
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

  Future<dynamic> getUnitInventoryStock({
    required List<int> itemId,
    required List<int> unitId,
    required List<int> categoryId,
    required String stateId,
    required String districtId,
  }) async {
    try {
      return await _apiService.post(AppConstants.inventoryUnitStock, data: {
        "item_id": itemId,
        "unit_id": unitId,
        "category_id": categoryId,
        "state_id": stateId,
        "district_id": districtId,
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

  Future<dynamic> createMeasurement(String name) async {
    try {
      return await _apiService.post(AppConstants.measurementCreate, data: {
        "mesNm": name,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateMeasurement(int id, String name) async {
    try {
      return await _apiService.post(AppConstants.measurementUpdate, data: {
        "id": id,
        "mesNm": name,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteMeasurement(int id) async {
    try {
      return await _apiService.post(AppConstants.measurementDelete, data: {
        "id": id,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMeasurements() async {
    try {
      return await _apiService.get(AppConstants.measurementList);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getInventoryOrders() async {
    try {
      return await _apiService.get(AppConstants.inventoryOrders);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> receiveStoreOrder(int orderId, int receivedQty) async {
    try {
      return await _apiService.post(
        AppConstants.inventoryOrdersReceive(orderId),
        data: {'received_qty': receivedQty},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> completeOrder({
    required int orderId,
    dynamic unitId,
    dynamic storeId,
    required int itemId,
    required dynamic qty,
  }) async {
    try {
      num parsedQty = 0;
      if (qty is num) {
        parsedQty = qty;
      } else if (qty != null) {
        parsedQty = num.tryParse(qty.toString().replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }

      final Map<String, dynamic> data = {
        'item_id': itemId,
        'qty': parsedQty,
      };
      if (unitId != null) {
        data['unit_id'] = unitId is int ? unitId : int.tryParse(unitId.toString());
      }
      if (storeId != null) {
        data['store_id'] = storeId is int ? storeId : int.tryParse(storeId.toString());
      }

      return await _apiService.post(
        AppConstants.inventoryOrdersComplete(orderId),
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> requestStoreOrder({
    required int storeId,
    required int itemId,
    required dynamic qty,
  }) async {
    try {
      num parsedQty = 0;
      if (qty is num) {
        parsedQty = qty;
      } else if (qty != null) {
        parsedQty = num.tryParse(qty.toString().replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }

      return await _apiService.post(
        AppConstants.inventoryOrdersStoreRequest,
        data: {
          'store_id': storeId,
          'item_id': itemId,
          'qty': parsedQty,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> requestUnitOrder({
    required int unitId,
    required int itemId,
    required dynamic qty,
  }) async {
    try {
      num parsedQty = 0;
      if (qty is num) {
        parsedQty = qty;
      } else if (qty != null) {
        parsedQty = num.tryParse(qty.toString().replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }

      return await _apiService.post(
        AppConstants.inventoryOrdersUnitRequest,
        data: {
          'unit_id': unitId,
          'item_id': itemId,
          'qty': parsedQty,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createBulkStoreOrder() async {
    try {
      return await _apiService.post(
        AppConstants.inventoryStoreOrdersBulkStore,
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createBulkUnitOrder() async {
    try {
      return await _apiService.post(
        AppConstants.inventoryUnitOrdersBulkStore,
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOrderReceiveLogs() async {
    try {
      return await _apiService.get(AppConstants.inventoryOrderReceiveLogs);
    } catch (e) {
      rethrow;
    }
  }
}
