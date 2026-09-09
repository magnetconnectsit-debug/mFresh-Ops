import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import '../../../data/models/inventory/inventory_order_model.dart';

enum InventoryOrderStatusFilter {
  all,
  pending,
  waitingForReceive,
  completed,
}

class InventoryOrdersController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  final RxList<InventoryOrderModel> allOrders = <InventoryOrderModel>[].obs;
  final RxList<InventoryOrderModel> filteredOrders = <InventoryOrderModel>[].obs;
  final Rx<InventoryOrderSummary> summary = InventoryOrderSummary().obs;

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  final Rx<InventoryOrderStatusFilter> selectedFilter = InventoryOrderStatusFilter.all.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 100.obs;

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
        applyFilters();
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
      applyFilters();
    }
  }

  void setFilter(InventoryOrderStatusFilter filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    final result = allOrders.where((order) {
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
        case InventoryOrderStatusFilter.all:
        default:
          matchesStatus = true;
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

    filteredOrders.assignAll(result);
    currentPage.value = 1;
  }

  int get totalPages => (filteredOrders.length / itemsPerPage.value).ceil().clamp(1, 9999);

  List<InventoryOrderModel> get paginatedOrders {
    if (filteredOrders.isEmpty) return [];
    final start = (currentPage.value - 1) * itemsPerPage.value;
    if (start >= filteredOrders.length) return [];
    final end = (start + itemsPerPage.value).clamp(0, filteredOrders.length);
    return filteredOrders.sublist(start, end);
  }

  void setItemsPerPage(int count) {
    itemsPerPage.value = count;
    currentPage.value = 1;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }
}
