import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/data/repositories/payment_reminder_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class CompletedPaymentController extends GetxController {
  final PaymentReminderRepository _repository = Get.find<PaymentReminderRepository>();

  final isLoading = false.obs;
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final completedPayments = <PaymentReminderItem>[].obs;
  final users = <PaymentReminderUser>[].obs;

  // Selected filters
  final Rxn<int> selectedYear = Rxn<int>(DateTime.now().year);
  final Rxn<int> selectedFromMonth = Rxn<int>();
  final Rxn<int> selectedToMonth = Rxn<int>();
  final selectedAssignees = <PaymentReminderUser>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 50.obs;

  // Sorting
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    // Fetch user list if empty using paymentIndex call or load users
    try {
      final indexResp = await _repository.getPaymentReminders(
        year: DateTime.now().year.toString(),
        fromMonth: '',
        toMonth: '',
        assignee: [],
        status: [],
        search: '',
      );
      if (indexResp.users.isNotEmpty) {
        users.assignAll(indexResp.users);
      }
    } catch (_) {}

    await fetchCompletedPayments();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
      applyFilters();
    }
  }

  Future<void> fetchCompletedPayments() async {
    isLoading.value = true;
    try {
      final yearStr = selectedYear.value != null ? selectedYear.value.toString() : "";
      final fromMonthStr = selectedFromMonth.value != null ? selectedFromMonth.value.toString() : "";
      final toMonthStr = selectedToMonth.value != null ? selectedToMonth.value.toString() : "";
      final assigneeList = selectedAssignees.map((e) => e.id).toList();
      final searchStr = searchQuery.value;

      final response = await _repository.getCompletedPayments(
        year: yearStr,
        fromMonth: fromMonthStr,
        toMonth: toMonthStr,
        assignees: assigneeList,
        search: searchStr,
      );

      if (response.status == true || response.success == true) {
        if (response.users.isNotEmpty) {
          users.assignAll(response.users);
        }
        completedPayments.assignAll(response.paymentReminders);
      } else {
        AppCommonToastMessage.show(
          message: response.message ?? "Failed to load completed payments",
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error loading completed payments",
        type: ToastType.error,
      );
      debugPrint("Error fetching completed payments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchCompletedPayments();
  }

  void resetFilters() {
    selectedYear.value = DateTime.now().year;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    selectedAssignees.clear();
    searchQuery.value = '';
    searchController.clear();
    applyFilters();
  }

  String getAssigneeName(int? userId) {
    if (userId == null) return "-";
    final user = users.firstWhereOrNull((u) => u.id == userId);
    return user?.name ?? "-";
  }

  void toggleSort(String column) {
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

  List<PaymentReminderItem> get displayedPayments {
    List<PaymentReminderItem> filtered = completedPayments.toList();

    // Client-side search fallback
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        return (item.forDesc ?? '').toLowerCase().contains(query) ||
               (item.to ?? '').toLowerCase().contains(query) ||
               (item.assigneeName ?? getAssigneeName(item.assigneeId)).toLowerCase().contains(query) ||
               (item.expenseHead ?? '').toLowerCase().contains(query) ||
               (item.costCenter ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Sorting
    if (sortColumn.value.isNotEmpty) {
      filtered.sort((a, b) {
        int result = 0;
        switch (sortColumn.value) {
          case 'SI No':
          case 'Sl No':
            result = a.id.compareTo(b.id);
            break;
          case 'For':
            result = (a.forDesc ?? '').compareTo(b.forDesc ?? '');
            break;
          case 'To':
            result = (a.to ?? '').compareTo(b.to ?? '');
            break;
          case 'Assignee':
          case 'Assignee Name':
            final aName = a.assigneeName ?? getAssigneeName(a.assigneeId);
            final bName = b.assigneeName ?? getAssigneeName(b.assigneeId);
            result = aName.compareTo(bName);
            break;
          case 'Expense Head':
            result = (a.expenseHead ?? '').compareTo(b.expenseHead ?? '');
            break;
          case 'Sub-Head':
            result = (a.subHead ?? '').compareTo(b.subHead ?? '');
            break;
          case 'Cost Center':
            result = (a.costCenter ?? '').compareTo(b.costCenter ?? '');
            break;
          case 'Due Date':
            result = (a.dueDate ?? '').compareTo(b.dueDate ?? '');
            break;
          case 'Reminder End Date':
            result = (a.endDate ?? '').compareTo(b.endDate ?? '');
            break;
          case 'Notification Date':
            result = (a.notificationDate ?? '').compareTo(b.notificationDate ?? '');
            break;
          case 'Time':
            result = (a.notificationTime ?? '').compareTo(b.notificationTime ?? '');
            break;
          case 'Completed At':
            result = (a.completedAt ?? '').compareTo(b.completedAt ?? '');
            break;
          case 'Status':
            result = (a.status ?? '').compareTo(b.status ?? '');
            break;
          default:
            result = 0;
        }
        return sortAscending.value ? result : -result;
      });
    }

    int startIndex = (currentPage.value - 1) * perPage.value;
    if (startIndex >= filtered.length) return [];

    int endIndex = startIndex + perPage.value;
    if (endIndex > filtered.length) endIndex = filtered.length;

    return filtered.sublist(startIndex, endIndex);
  }

  int get totalPages => (completedPayments.length / perPage.value).ceil();
}
