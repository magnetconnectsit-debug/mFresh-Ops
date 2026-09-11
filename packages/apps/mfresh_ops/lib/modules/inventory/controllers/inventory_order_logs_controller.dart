import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/inventory/inventory_order_receive_log_model.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class InventoryOrderLogsController extends GetxController {
  final InventoryRepository _repository = InventoryRepository();

  final RxList<InventoryOrderReceiveLogModel> allLogs = <InventoryOrderReceiveLogModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  // Pagination
  final RxInt pageSize = 50.obs;
  final RxInt currentPage = 1.obs;
  final List<int> pageSizeOptions = [10, 25, 50, 100];

  // Sorting
  final RxString sortColumn = ''.obs;
  final RxBool sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderLogs();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      currentPage.value = 1;
    }
  }

  Future<void> fetchOrderLogs() async {
    isLoading.value = true;
    try {
      final response = await _repository.getOrderReceiveLogs();
      if (response != null && (response['status'] == true || response['status'] == 'success')) {
        final List<dynamic> data = response['data'] ?? [];
        allLogs.assignAll(
          data.map((item) => InventoryOrderReceiveLogModel.fromJson(item)).toList(),
        );
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? 'Failed to fetch order receive logs.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error loading order receive logs: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchOrderLogs();
  }

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

  List<InventoryOrderReceiveLogModel> get filteredLogs {
    List<InventoryOrderReceiveLogModel> source = List.from(allLogs);

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      source = source.where((log) {
        final itemMatch = log.itemName.toLowerCase().contains(query);
        final orderIdMatch = log.orderId.toString().contains(query);
        final statusMatch = log.fulfillmentStatus.toLowerCase().contains(query);
        final receivedByMatch = log.receivedBy?.name?.toLowerCase().contains(query) ?? false;
        return itemMatch || orderIdMatch || statusMatch || receivedByMatch;
      }).toList();
    }

    if (sortColumn.value.isNotEmpty) {
      source.sort((a, b) {
        dynamic aVal;
        dynamic bVal;

        switch (sortColumn.value) {
          case 'sl_no':
            aVal = a.slNo;
            bVal = b.slNo;
            break;
          case 'order_id':
            aVal = a.orderId;
            bVal = b.orderId;
            break;
          case 'item_name':
            aVal = a.itemName;
            bVal = b.itemName;
            break;
          case 'requested_qty':
            aVal = a.rawRequestedQty;
            bVal = b.rawRequestedQty;
            break;
          case 'received_qty':
            aVal = a.rawReceivedQty;
            bVal = b.rawReceivedQty;
            break;
          case 'difference_qty':
            aVal = a.rawDifferenceQty;
            bVal = b.rawDifferenceQty;
            break;
          case 'requested_on':
            aVal = a.requestedOn;
            bVal = b.requestedOn;
            break;
          case 'received_on':
            aVal = a.receivedOn;
            bVal = b.receivedOn;
            break;
          case 'fulfilled_days':
            aVal = a.fulfilledDays;
            bVal = b.fulfilledDays;
            break;
          default:
            aVal = a.slNo;
            bVal = b.slNo;
        }

        int comparison;
        if (aVal is Comparable && bVal is Comparable) {
          comparison = aVal.compareTo(bVal);
        } else {
          comparison = 0;
        }
        return sortAscending.value ? comparison : -comparison;
      });
    }

    return source;
  }

  List<InventoryOrderReceiveLogModel> get paginatedLogs {
    final filtered = filteredLogs;
    final start = (currentPage.value - 1) * pageSize.value;
    if (start >= filtered.length) return [];
    final end = start + pageSize.value;
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  int get totalPages {
    final count = filteredLogs.length;
    if (count == 0) return 1;
    return (count / pageSize.value).ceil();
  }

  void setPageSize(int size) {
    pageSize.value = size;
    currentPage.value = 1;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }
}
