import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/data/repositories/payment_reminder_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class PaymentReminderController extends GetxController {
  final PaymentReminderRepository _paymentReminderRepository = Get.find<PaymentReminderRepository>();

  final isLoading = false.obs;
  final isSearching = false.obs;
  final isNoInternet = false.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final paymentReminders = <PaymentReminderItem>[].obs;
  final users = <PaymentReminderUser>[].obs;

  // Selected filters
  final Rxn<int> selectedYear = Rxn<int>(DateTime.now().year);
  final Rxn<int> selectedFromMonth = Rxn<int>();
  final Rxn<int> selectedToMonth = Rxn<int>();
  final selectedAssignees = <PaymentReminderUser>[].obs;
  final selectedStatus = <String>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 50.obs;

  // Sorting
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignees();
    fetchPaymentReminders();
  }

  Future<void> fetchAssignees() async {
    try {
      final commonRepo = Get.isRegistered<CommonRepository>()
          ? Get.find<CommonRepository>()
          : Get.put(CommonRepository());
      final assignees = await commonRepo.getAllAssignees();
      if (assignees.isNotEmpty) {
        final mapped = assignees
            .map((a) => PaymentReminderUser(id: a.id, name: a.name))
            .toList();
        users.assignAll(mapped);
        return;
      }
    } catch (e) {
      debugPrint("Error fetching assignees via CommonRepository: $e");
    }

    try {
      final fetchedUsers = await _paymentReminderRepository.getUsers();
      if (fetchedUsers.isNotEmpty) {
        users.assignAll(fetchedUsers);
      }
    } catch (e) {
      debugPrint("Error fetching users via PaymentReminderRepository: $e");
    }
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
      searchQuery.value = '';
      applyFilters();
    }
  }

  Future<void> fetchPaymentReminders() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        isNoInternet.value = true;
        isLoading.value = false;
        return;
      }
    } catch (_) {}

    isLoading.value = true;
    try {
      final yearStr = selectedYear.value != null ? selectedYear.value.toString() : DateTime.now().year.toString();
      final fromMonthStr = selectedFromMonth.value != null ? selectedFromMonth.value.toString() : "";
      final toMonthStr = selectedToMonth.value != null ? selectedToMonth.value.toString() : "";
      final assigneeList = selectedAssignees.map((e) => e.id).toList();
      final statusList = selectedStatus.toList();
      final searchStr = searchQuery.value;

      final response = await _paymentReminderRepository.getPaymentReminders(
        year: yearStr,
        fromMonth: fromMonthStr,
        toMonth: toMonthStr,
        assignee: assigneeList,
        status: statusList,
        search: searchStr,
      );

      if (response.status == true || response.success == true) {
        isNoInternet.value = false;
        if (response.users.isNotEmpty) {
          for (final u in response.users) {
            if (!users.any((existing) => existing.id == u.id)) {
              users.add(u);
            }
          }
        }
        paymentReminders.assignAll(response.paymentReminders);
      } else {
        AppCommonToastMessage.show(
          message: response.message ?? "Failed to load payment reminders",
          type: ToastType.error,
        );
      }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('connection failed') ||
          errStr.contains('network is unreachable') ||
          errStr.contains('host lookup failed') ||
          errStr.contains('dioexception')) {
        isNoInternet.value = true;
      } else {
        AppCommonToastMessage.show(
          message: "Error loading payment reminders",
          type: ToastType.error,
        );
      }
      debugPrint("Error fetching payment reminders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchPaymentReminders();
  }

  void resetFilters() {
    selectedYear.value = DateTime.now().year;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    selectedAssignees.clear();
    selectedStatus.clear();
    searchQuery.value = '';
    searchController.clear();
    applyFilters();
  }

  String getAssigneeName(int? userId) {
    if (userId == null) return "-";
    final user = users.firstWhereOrNull((u) => u.id == userId);
    return user?.name ?? "-";
  }

  Map<String, dynamic> getDueInStatus(String? dueDateStr, {String? serverDueIn}) {
    if (serverDueIn != null && serverDueIn.isNotEmpty) {
      final isOverdue = serverDueIn.toLowerCase().contains('overdue');
      return {'text': serverDueIn, 'isOverdue': isOverdue, 'days': isOverdue ? -1 : 1};
    }
    if (dueDateStr == null || dueDateStr.isEmpty) {
      return {'text': '-', 'isOverdue': false, 'days': 0};
    }
    try {
      final dueDate = DateTime.parse(dueDateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final difference = target.difference(today).inDays;

      if (difference < 0) {
        return {'text': 'Overdue ${difference.abs()} Days', 'isOverdue': true, 'days': difference};
      } else if (difference == 0) {
        return {'text': 'Due Today', 'isOverdue': false, 'days': 0};
      } else {
        return {'text': '$difference Days', 'isOverdue': false, 'days': difference};
      }
    } catch (e) {
      return {'text': '-', 'isOverdue': false, 'days': 0};
    }
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

  List<PaymentReminderItem> get displayedReminders {
    List<PaymentReminderItem> filtered = paymentReminders.toList();
    
    // Client-side search fallback / filtering if needed
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

    // Status filtering for multiselect due, overdue, upcoming
    if (selectedStatus.isNotEmpty) {
      final selectedList = selectedStatus.map((s) => s.toLowerCase()).toList();
      filtered = filtered.where((item) {
        final st = (item.status ?? '').toLowerCase();
        if (selectedList.contains(st)) return true;
        final dueStatus = getDueInStatus(item.dueDate);
        for (final sel in selectedList) {
          if (sel == 'due' && (st == 'due' || dueStatus['text'].toString().toLowerCase().contains('today') || (dueStatus['days'] as int? ?? -1) == 0)) {
            return true;
          }
          if (sel == 'overdue' && (st == 'overdue' || (dueStatus['isOverdue'] as bool? ?? false))) {
            return true;
          }
          if (sel == 'upcoming' && (st == 'upcoming' || (!(dueStatus['isOverdue'] as bool? ?? false) && (dueStatus['days'] as int? ?? 0) > 0))) {
            return true;
          }
        }
        return false;
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
          case 'Status':
            result = (a.status ?? '').compareTo(b.status ?? '');
            break;
          case 'Due In':
            final aDue = getDueInStatus(a.dueDate);
            final bDue = getDueInStatus(b.dueDate);
            final aDays = (aDue['days'] as int? ?? 0);
            final bDays = (bDue['days'] as int? ?? 0);
            result = aDays.compareTo(bDays);
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

  int get totalPages => (paymentReminders.length / perPage.value).ceil();

  Future<void> deleteReminder(
    int id, {
    int? recurrenceId,
    String? recurrenceScope,
  }) async {
    try {
      final success = await _paymentReminderRepository.deleteReminder({
        "id": id,
        "recurrence_id": recurrenceId,
        "recurrence_scope": recurrenceScope ?? (recurrenceId != null ? "only_this" : "entire_schedule"),
      });
      if (success) {
        AppCommonToastMessage.show(
          message: 'Payment reminder deleted successfully.',
          type: ToastType.success,
        );
        fetchPaymentReminders();
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete payment reminder.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error deleting payment reminder.',
        type: ToastType.error,
      );
    }
  }

  Future<void> markComplete(int id, {int? recurrenceId}) async {
    try {
      final success = await _paymentReminderRepository.markAsComplete(
        id: id,
        recurrenceId: recurrenceId,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'Payment reminder marked as completed.',
          type: ToastType.success,
        );
        fetchPaymentReminders();
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to mark as completed.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error marking as completed.',
        type: ToastType.error,
      );
    }
  }
}
