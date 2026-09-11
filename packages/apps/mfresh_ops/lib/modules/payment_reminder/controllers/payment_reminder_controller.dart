import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/models/payment_reminder_model.dart';
import 'package:mfresh_ops/data/repositories/payment_reminder_repository.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class PaymentReminderController extends GetxController {
  final PaymentReminderRepository _paymentReminderRepository = Get.find<PaymentReminderRepository>();
  final TaskRepository _taskRepository = Get.find<TaskRepository>();

  final isLoading = false.obs;
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final paymentReminders = <PaymentReminderItem>[].obs;
  final users = <PaymentReminderUser>[].obs;

  // Filter lists from TaskRepository
  final projects = <TaskProject>[].obs;
  final units = <SupportUnit>[].obs;
  final groups = <TaskGroup>[].obs;

  // Selected filters
  final selectedProjects = <TaskProject>[].obs;
  final selectedUnits = <SupportUnit>[].obs;
  final selectedGroups = <TaskGroup>[].obs;
  final selectedAssignees = <PaymentReminderUser>[].obs;

  // Pagination (assuming standard pagination if needed, though API currently returns all in 'payment_reminders')
  final currentPage = 1.obs;
  final perPage = 50.obs;

  // Sorting
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFilters();
    fetchPaymentReminders();
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

  Future<void> fetchFilters() async {
    try {
      final prjs = await _taskRepository.getTaskProjects();
      projects.assignAll(prjs);
      
      final un = await _taskRepository.getTaskUnits();
      units.assignAll(un);

      final grps = await _taskRepository.getTaskGroups('');
      groups.assignAll(grps);
    } catch (e) {
      debugPrint("Error fetching filters: $e");
    }
  }

  Future<void> fetchPaymentReminders() async {
    isLoading.value = true;
    try {
      final projectIds = selectedProjects.map((e) => int.tryParse(e.projectId.toString()) ?? 0).where((id) => id != 0).toList();
      final unitId = selectedUnits.isNotEmpty ? selectedUnits.first.unitId.toString() : "";
      final assigneeIds = selectedAssignees.map((e) => e.id).toList();
      final groupIds = selectedGroups.map((e) => e.id).where((id) => id != 0).toList();

      final response = await _paymentReminderRepository.getPaymentReminders(
        projectIds: projectIds,
        unitId: unitId,
        assigneeIds: assigneeIds,
        sGroupIds: groupIds,
      );

      if (response.status == true && response.data != null) {
        users.assignAll(response.data!.users);
        paymentReminders.assignAll(response.data!.paymentReminders);
      } else {
        AppCommonToastMessage.show(message: response.message ?? "Failed to load payment reminders", type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: "Error loading payment reminders", type: ToastType.error);
      debugPrint("Error fetching payment reminders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchPaymentReminders();
  }

  String getAssigneeName(int? userId) {
    if (userId == null) return "-";
    final user = users.firstWhereOrNull((u) => u.id == userId);
    return user?.name ?? "-";
  }

  // Calculated "Due In" status
  Map<String, dynamic> getDueInStatus(String? dueDateStr) {
    if (dueDateStr == null || dueDateStr.isEmpty) {
      return {'text': '-', 'isOverdue': false};
    }
    try {
      final dueDate = DateTime.parse(dueDateStr);
      final now = DateTime.now();
      final difference = dueDate.difference(now).inDays;

      if (difference < 0) {
        return {'text': 'Overdue ${difference.abs()} Days', 'isOverdue': true};
      } else {
        return {'text': '$difference Days', 'isOverdue': false};
      }
    } catch (e) {
      return {'text': '-', 'isOverdue': false};
    }
  }

  void toggleSort(String column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
  }

  List<PaymentReminderItem> get displayedReminders {
    List<PaymentReminderItem> filtered = paymentReminders.toList();
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        return (item.forDesc ?? '').toLowerCase().contains(query) ||
               (item.customerId ?? '').toLowerCase().contains(query) ||
               getAssigneeName(item.notificationTo).toLowerCase().contains(query) ||
               (item.expenseHead ?? '').toLowerCase().contains(query) ||
               (item.costCenter ?? '').toLowerCase().contains(query);
      }).toList();
    }
    
    // Sorting
    if (sortColumn.value.isNotEmpty) {
      filtered.sort((a, b) {
        int result = 0;
        switch (sortColumn.value) {
          case 'For':
            result = (a.forDesc ?? '').compareTo(b.forDesc ?? '');
            break;
          case 'Costumer ID':
            result = (a.customerId ?? '').compareTo(b.customerId ?? '');
            break;
          case 'Assignee Name':
            result = getAssigneeName(a.notificationTo).compareTo(getAssigneeName(b.notificationTo));
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
          case 'Due In':
            final aDue = getDueInStatus(a.dueDate);
            final bDue = getDueInStatus(b.dueDate);
            result = aDue['text'].compareTo(bDue['text']);
            break;
          default:
            result = a.id.compareTo(b.id);
        }
        return sortAscending.value ? result : -result;
      });
    }

    // Pagination (since API doesn't seem to paginate this list directly based on the response format)
    int startIndex = (currentPage.value - 1) * perPage.value;
    if (startIndex >= filtered.length) return [];
    
    int endIndex = startIndex + perPage.value;
    if (endIndex > filtered.length) endIndex = filtered.length;
    
    return filtered.sublist(startIndex, endIndex);
  }

  int get totalPages => (paymentReminders.length / perPage.value).ceil();
}
