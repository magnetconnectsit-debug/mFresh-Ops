import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/payment_reminder_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:intl/intl.dart';

class CreatePaymentReminderController extends GetxController {
  final PaymentReminderRepository _repository = Get.find<PaymentReminderRepository>();
  final PaymentReminderItem? reminderItem;

  CreatePaymentReminderController({this.reminderItem});
  
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isEditing = false.obs;

  // Users from the main controller
  final users = <PaymentReminderUser>[].obs;

  // Form Controllers
  final forCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final customerIdCtrl = TextEditingController();
  final expenseHeadCtrl = TextEditingController();
  final subHeadCtrl = TextEditingController();
  final costCenterCtrl = TextEditingController();
  final remindBeforeCtrl = TextEditingController(text: '0');
  final additionalNumberCtrl = TextEditingController();

  // Dropdowns
  final selectedAssignee = Rxn<PaymentReminderUser>();
  final selectedExpenseType = RxnString();
  final List<String> expenseTypes = ['OPEX', 'CAPEX'];

  // Dates
  final selectedDueDate = Rxn<DateTime>();
  final selectedReminderSetupDate = Rxn<DateTime>();
  final selectedReminderTime = Rxn<TimeOfDay>();

  // Recurrence & Notifications
  final isRecurring = false.obs;
  final recurrenceData = Rxn<RecurrenceData>();
  final recurrenceScope = 'only_this'.obs;
  final whatsappNotification = true.obs;
  final appNotification = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    _populateFieldsFromReminderItem();
  }

  void _populateFieldsFromReminderItem() {
    if (reminderItem == null) return;
    isEditing.value = true;
    forCtrl.text = reminderItem!.forDesc ?? '';
    brandCtrl.text = reminderItem!.brand ?? '';
    locationCtrl.text = reminderItem!.location ?? '';
    customerIdCtrl.text = reminderItem!.to ?? '';
    expenseHeadCtrl.text = reminderItem!.expenseHead ?? '';
    subHeadCtrl.text = reminderItem!.subHead ?? '';
    costCenterCtrl.text = reminderItem!.costCenter ?? '';
    if (reminderItem!.expenseType != null && reminderItem!.expenseType!.isNotEmpty) {
      selectedExpenseType.value = reminderItem!.expenseType;
    }
    if (reminderItem!.dueDate != null && reminderItem!.dueDate!.isNotEmpty) {
      selectedDueDate.value = DateTime.tryParse(reminderItem!.dueDate!);
    }
    if (reminderItem!.notificationDate != null && reminderItem!.notificationDate!.isNotEmpty) {
      selectedReminderSetupDate.value = DateTime.tryParse(reminderItem!.notificationDate!);
    }
    if (reminderItem!.notificationTime != null && reminderItem!.notificationTime!.isNotEmpty) {
      selectedReminderTime.value = parseTimeOfDay(reminderItem!.notificationTime!);
    }
    if (reminderItem!.remindBefore != null) {
      remindBeforeCtrl.text = reminderItem!.remindBefore.toString();
    }
    _matchAssignee();
  }

  void _matchAssignee() {
    if (reminderItem == null || users.isEmpty) return;
    final targetId = reminderItem!.assigneeId;
    final targetName = reminderItem!.assigneeName ?? reminderItem!.to;
    final match = users.firstWhereOrNull(
      (u) => (targetId != null && u.id == targetId) ||
             (targetName != null && targetName.isNotEmpty && u.name?.trim().toLowerCase() == targetName.trim().toLowerCase()),
    );
    if (match != null) {
      selectedAssignee.value = match;
    } else if (targetName != null && targetName.isNotEmpty) {
      final fallbackUser = PaymentReminderUser(id: targetId ?? 0, name: targetName);
      users.add(fallbackUser);
      selectedAssignee.value = fallbackUser;
    }
  }

  Future<void> fetchUsers() async {
    try {
      if (Get.isRegistered<PaymentReminderController>()) {
        final mainController = Get.find<PaymentReminderController>();
        if (mainController.users.isNotEmpty) {
          users.assignAll(mainController.users);
          return;
        }
      }

      // Try fetching all assignees via CommonRepository (all-assignee endpoint)
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
        debugPrint("Error fetching via CommonRepository: $e");
      }

      if (users.isEmpty) {
        final fetchedUsers = await _repository.getUsers();
        if (fetchedUsers.isNotEmpty) {
          users.assignAll(fetchedUsers);
        } else {
          final res = await _repository.getPaymentReminders(
            year: DateTime.now().year.toString(),
            fromMonth: "",
            toMonth: "",
            assignee: [],
            status: [],
            search: "",
          );
          if (res.users.isNotEmpty) {
            users.assignAll(res.users);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching users for create payment reminder: $e");
    } finally {
      _matchAssignee();
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    if (selectedAssignee.value == null) {
      AppCommonToastMessage.show(message: 'Please select Assignee Name', type: ToastType.error);
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (selectedDueDate.value != null && selectedDueDate.value!.isBefore(today)) {
      AppCommonToastMessage.show(message: 'Due Date cannot be a past date', type: ToastType.error);
      return;
    }
    if (selectedReminderSetupDate.value != null && selectedReminderSetupDate.value!.isBefore(today)) {
      AppCommonToastMessage.show(message: 'Reminder Date cannot be a past date', type: ToastType.error);
      return;
    }
    if (selectedReminderTime.value == null) {
      AppCommonToastMessage.show(message: 'Please configure Reminder Setup', type: ToastType.error);
      return;
    }
    if (isRecurring.value && selectedReminderSetupDate.value == null) {
      AppCommonToastMessage.show(message: 'Please select Recurrence Start Date in Reminder Setup', type: ToastType.error);
      return;
    }
    
    isLoading.value = true;
    try {
      final assigneeIdRaw = selectedAssignee.value?.id;
      final int? assigneeId = assigneeIdRaw != null
          ? int.tryParse(assigneeIdRaw.toString())
          : null;

      final data = <String, dynamic>{
        "for": forCtrl.text.trim(),
        "brand": brandCtrl.text.trim(),
        "location": locationCtrl.text.trim(),
        "customer_id": customerIdCtrl.text.trim(),
        "due_date": selectedDueDate.value != null
            ? DateFormat('yyyy-MM-dd').format(selectedDueDate.value!)
            : null,
        "reminder_setup_date": selectedReminderSetupDate.value != null
            ? DateFormat('yyyy-MM-dd').format(selectedReminderSetupDate.value!)
            : (selectedDueDate.value != null
                ? DateFormat('yyyy-MM-dd').format(selectedDueDate.value!)
                : DateFormat('yyyy-MM-dd').format(DateTime.now())),
        "notification_to": assigneeId ?? assigneeIdRaw,
        "additional_number": additionalNumberCtrl.text.trim(),
        "expense_head": expenseHeadCtrl.text.trim(),
        "sub_head": subHeadCtrl.text.trim(),
        "cost_center": costCenterCtrl.text.trim(),
        "expense_type": selectedExpenseType.value,
        "remind_before": int.tryParse(remindBeforeCtrl.text) ?? 0,
        "reminder_time": selectedReminderTime.value != null
            ? '${selectedReminderTime.value!.hour.toString().padLeft(2, '0')}:${selectedReminderTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
        "recurring_reminder": isRecurring.value ? 1 : 0,
        "whatsapp_notification": whatsappNotification.value ? 1 : 0,
        "app_notification": appNotification.value ? 1 : 0,
      };

      if (isRecurring.value && recurrenceData.value != null) {
        final rec = recurrenceData.value!;
        final rawFreq = rec.frequency.toLowerCase();
        final freq = rawFreq == 'month'
            ? 'monthly'
            : rawFreq == 'year'
                ? 'yearly'
                : rawFreq == 'week'
                    ? 'weekly'
                    : rawFreq == 'day'
                        ? 'daily'
                        : rawFreq;

        data["frequency"] = freq;
        data["repeat_interval"] = rec.repeatInterval;
        data["start_date"] = DateFormat('yyyy-MM-dd').format(rec.startDate);

        if (rec.endByDate != null) {
          data["end_date"] = DateFormat('yyyy-MM-dd').format(rec.endByDate!);
          data["occurrences"] = null;
        } else if (rec.occurrences != null) {
          data["end_date"] = null;
          data["occurrences"] = rec.occurrences;
        } else {
          data["end_date"] = null;
          data["occurrences"] = null;
        }

        if (freq == 'weekly' && rec.selectedDays != null && rec.selectedDays!.isNotEmpty) {
          data["selected_days"] = rec.selectedDays;
        }

        if (freq == 'monthly') {
          if (rec.monthlyMode == 'day' || rec.monthlyMode == null) {
            data["monthly_pattern"] = "date";
            data["month_day"] = rec.monthDay ?? 1;
          } else if (rec.monthlyMode == 'the') {
            data["monthly_pattern"] = "weekday";
            data["monthly_week"] = rec.monthOrdinal;
            data["monthly_day_name"] = rec.monthWeekday;
          }
        }

        if (freq == 'yearly') {
          data["yearly_month"] = rec.yearlyMonth ?? "January";
          if (rec.yearlyMode == 'on' || rec.yearlyMode == null) {
            data["yearly_pattern"] = "date";
            data["yearly_day"] = rec.yearlyDay ?? 1;
          } else if (rec.yearlyMode == 'the') {
            data["yearly_pattern"] = "weekday";
            data["yearly_week"] = rec.yearlyOrdinal;
            data["yearly_day_name"] = rec.yearlyWeekday;
          }
        }
      } else {
        data["frequency"] = null;
        data["repeat_interval"] = null;
        data["start_date"] = null;
        data["end_date"] = null;
        data["occurrences"] = null;
      }

      if (isEditing.value && reminderItem != null) {
        data["id"] = reminderItem!.parentId ?? reminderItem!.id;
        if (reminderItem!.recurrenceId != null) {
          data["recurrence_id"] = reminderItem!.recurrenceId;
        }
        data["recurrence_scope"] = recurrenceScope.value;
      }

      final success = (isEditing.value && reminderItem != null)
          ? await _repository.updatePaymentReminder(data)
          : await _repository.addPaymentReminder(data);

      if (success) {
        Get.back();
        AppCommonToastMessage.show(
          message: isEditing.value
              ? 'Payment reminder updated successfully.'
              : 'Payment reminder added successfully.',
          type: ToastType.success,
        );
        try {
          Get.find<PaymentReminderController>().fetchPaymentReminders();
        } catch (_) {}
      } else {
        AppCommonToastMessage.show(
          message: isEditing.value
              ? 'Failed to update payment reminder.'
              : 'Failed to add payment reminder.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'An error occurred.', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    if (timeString.isEmpty) return TimeOfDay.now();
    try {
      final format = DateFormat.jm(); // "6:00 AM"
      final time = format.parse(timeString);
      return TimeOfDay(hour: time.hour, minute: time.minute);
    } catch (_) {
      try {
        final parts = timeString.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {
        return TimeOfDay.now();
      }
    }
  }
}
