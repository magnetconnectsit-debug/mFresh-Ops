import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import '../../../data/models/inventory/inventory_order_model.dart';

enum InventoryOrderStatusFilter {
  allActive,
  pending,
  waitingForReceive,
  completed,
}

class InventoryOrdersController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  final RxList<InventoryOrderModel> allOrders = <InventoryOrderModel>[].obs;
  final Rx<InventoryOrderSummary> summary = InventoryOrderSummary().obs;

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  final Rx<InventoryOrderStatusFilter> selectedFilter = InventoryOrderStatusFilter.allActive.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await _repository.getInventoryOrders();
      if (response != null && response['status'] == true) {
        if (response['summary'] != null) {
          summary.value = InventoryOrderSummary.fromJson(response['summary']);
        }

        final List<InventoryOrderModel> fetchedList = [];

        if (response['data'] != null) {
          final data = response['data'];
          if (data['unit_orders'] != null && data['unit_orders'] is List) {
            for (var item in data['unit_orders']) {
              fetchedList.add(InventoryOrderModel.fromJson(item));
            }
          }
          if (data['store_orders'] != null && data['store_orders'] is List) {
            for (var item in data['store_orders']) {
              fetchedList.add(InventoryOrderModel.fromJson(item));
            }
          }
        }

        allOrders.assignAll(fetchedList);
      }
    } catch (e) {
      debugPrint('Error fetching inventory orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchOrders();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
    }
  }

  void setFilter(InventoryOrderStatusFilter filter) {
    selectedFilter.value = filter;
  }

  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  void sortBy(String column) {
    if (sortColumn.value == column) {
      if (sortAscending.value) {
        sortAscending.value = false;
      } else {
        sortColumn.value = '';
        sortAscending.value = true;
      }
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
  }

  List<InventoryOrderModel> _filterOrders(List<InventoryOrderModel> sourceList) {
    final query = searchController.text.trim().toLowerCase();

    final filtered = sourceList.where((order) {
      // Status Filter
      bool matchesStatus = true;
      switch (selectedFilter.value) {
        case InventoryOrderStatusFilter.pending:
          matchesStatus = order.status == 0;
          break;
        case InventoryOrderStatusFilter.waitingForReceive:
          matchesStatus = order.status == 1;
          break;
        case InventoryOrderStatusFilter.completed:
          matchesStatus = order.status == 2;
          break;
        case InventoryOrderStatusFilter.allActive:
        default:
          matchesStatus = order.status == 0 || order.status == 1;
          break;
      }

      if (!matchesStatus) return false;

      // Search query filter
      if (query.isNotEmpty) {
        final itemMatch = order.itemName.toLowerCase().contains(query);
        final locationMatch = order.displayName.toLowerCase().contains(query);
        final requestedByMatch = (order.requestedBy?.name ?? '').toLowerCase().contains(query);
        final statusMatch = order.statusName.toLowerCase().contains(query);

        return itemMatch || locationMatch || requestedByMatch || statusMatch;
      }

      return true;
    }).toList();

    if (sortColumn.value.isEmpty) return filtered;

    final col = sortColumn.value;
    final asc = sortAscending.value;

    int compareStr(String a, String b) {
      return asc ? a.toLowerCase().compareTo(b.toLowerCase()) : b.toLowerCase().compareTo(a.toLowerCase());
    }

    int compareNum(num a, num b) {
      return asc ? a.compareTo(b) : b.compareTo(a);
    }

    filtered.sort((a, b) {
      switch (col) {
        case 'Order ID':
          return compareNum(a.orderId, b.orderId);
        case 'Unit':
        case 'Store':
        case 'Location':
          return compareStr(a.displayName, b.displayName);
        case 'Item':
          return compareStr(a.itemName, b.itemName);
        case 'Quantity':
          return compareNum(a.requestedQty, b.requestedQty);
        case 'Requested By':
          return compareStr(a.requestedBy?.name ?? '', b.requestedBy?.name ?? '');
        case 'Status':
          return compareNum(a.status, b.status);
        case 'Processed By':
          return compareStr(a.processedBy?.name ?? '', b.processedBy?.name ?? '');
        default:
          return 0;
      }
    });

    return filtered;
  }

  Future<void> completeOrder(InventoryOrderModel order) async {
    try {
      final response = await _repository.completeOrder(
        orderId: order.orderId,
        unitId: order.orderType == 'unit' ? (order.unitId ?? order.locationId) : null,
        storeId: order.orderType == 'store' ? (order.storeId ?? order.locationId) : null,
        itemId: order.itemId,
        qty: order.requestedQty,
      );

      if (response != null && (response['status'] == true || response['status'] == 'success')) {
        final message = response['message']?.toString() ?? 'Order completed successfully.';
        AppCommonToastMessage.show(
          message: message,
          type: ToastType.success,
        );
        fetchOrders();
      } else {
        final errorMessage = response?['message']?.toString() ?? 'Failed to complete order.';
        AppCommonToastMessage.show(
          message: errorMessage,
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to complete order: $e',
        type: ToastType.error,
      );
    }
  }

  // Pagination State for Unit Orders
  final unitCurrentPage = 1.obs;
  final unitItemsPerPage = 25.obs;

  // Pagination State for Store Orders
  final storeCurrentPage = 1.obs;
  final storeItemsPerPage = 25.obs;

  int get unitTotalPages {
    final count = filteredUnitOrders.length;
    if (count == 0) return 1;
    return (count / unitItemsPerPage.value).ceil();
  }

  int get storeTotalPages {
    final count = filteredStoreOrders.length;
    if (count == 0) return 1;
    return (count / storeItemsPerPage.value).ceil();
  }

  List<InventoryOrderModel> get paginatedUnitOrders {
    final list = filteredUnitOrders;
    if (list.isEmpty) return [];
    final start = (unitCurrentPage.value - 1) * unitItemsPerPage.value;
    if (start >= list.length) return [];
    final end = (start + unitItemsPerPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  List<InventoryOrderModel> get paginatedStoreOrders {
    final list = filteredStoreOrders;
    if (list.isEmpty) return [];
    final start = (storeCurrentPage.value - 1) * storeItemsPerPage.value;
    if (start >= list.length) return [];
    final end = (start + storeItemsPerPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void setUnitPage(int page) {
    if (page >= 1 && page <= unitTotalPages) {
      unitCurrentPage.value = page;
    }
  }

  void setStorePage(int page) {
    if (page >= 1 && page <= storeTotalPages) {
      storeCurrentPage.value = page;
    }
  }

  void previousUnitPage() {
    if (unitCurrentPage.value > 1) {
      unitCurrentPage.value--;
    }
  }

  void nextUnitPage() {
    if (unitCurrentPage.value < unitTotalPages) {
      unitCurrentPage.value++;
    }
  }

  void previousStorePage() {
    if (storeCurrentPage.value > 1) {
      storeCurrentPage.value--;
    }
  }

  void nextStorePage() {
    if (storeCurrentPage.value < storeTotalPages) {
      storeCurrentPage.value++;
    }
  }

  void setUnitItemsPerPage(int items) {
    unitItemsPerPage.value = items;
    unitCurrentPage.value = 1;
  }

  void setStoreItemsPerPage(int items) {
    storeItemsPerPage.value = items;
    storeCurrentPage.value = 1;
  }

  List<InventoryOrderModel> get unitOrders =>
      allOrders.where((e) => e.orderType == 'unit').toList();

  List<InventoryOrderModel> get storeOrders =>
      allOrders.where((e) => e.orderType == 'store').toList();

  List<InventoryOrderModel> get filteredUnitOrders => _filterOrders(unitOrders);

  List<InventoryOrderModel> get filteredStoreOrders => _filterOrders(storeOrders);

  int get allActiveCount => summary.value.pending + summary.value.waitingForReceive;
}
