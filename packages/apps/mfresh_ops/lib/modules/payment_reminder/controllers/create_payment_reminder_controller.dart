import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/payment_reminder_repository.dart';
import 'package:mfresh_ops/data/models/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:intl/intl.dart';

class CreatePaymentReminderController extends GetxController {
  final PaymentReminderRepository _repository = Get.find<PaymentReminderRepository>();
  
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

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
  final whatsappNotification = true.obs;
  final appNotification = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch users from PaymentReminderController if available
    try {
      final mainController = Get.find<PaymentReminderController>();
      users.assignAll(mainController.users);
    } catch (_) {}
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    if (selectedAssignee.value == null) {
      AppCommonToastMessage.show(message: 'Please select Assignee Name', type: ToastType.error);
      return;
    }
    if (selectedReminderSetupDate.value == null) {
      AppCommonToastMessage.show(message: 'Please select Reminder Setup Date', type: ToastType.error);
      return;
    }
    
    isLoading.value = true;
    try {
      final data = {
        "for": forCtrl.text,
        "brand": brandCtrl.text,
        "location": locationCtrl.text,
        "customer_id": customerIdCtrl.text,
        "due_date": selectedDueDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedDueDate.value!) : null,
        "reminder_setup_date": DateFormat('yyyy-MM-dd').format(selectedReminderSetupDate.value!),
        "notification_to": selectedAssignee.value?.id,
        "additional_number": additionalNumberCtrl.text,
        "expense_head": expenseHeadCtrl.text,
        "sub_head": subHeadCtrl.text,
        "cost_center": costCenterCtrl.text,
        "expense_type": selectedExpenseType.value,
        "remind_before": int.tryParse(remindBeforeCtrl.text) ?? 0,
        "reminder_time": selectedReminderTime.value != null ? '${selectedReminderTime.value!.hour.toString().padLeft(2, '0')}:${selectedReminderTime.value!.minute.toString().padLeft(2, '0')}' : null,

        "recurring_reminder": isRecurring.value ? 1 : 0,
        "whatsapp_notification": whatsappNotification.value ? 1 : 0,
        "app_notification": appNotification.value ? 1 : 0,
      };

      if (isRecurring.value && recurrenceData.value != null) {
        final rec = recurrenceData.value!;
        data["frequency"] = rec.frequency.toLowerCase();
        data["repeat_interval"] = rec.repeatInterval;

        if (rec.frequency.toLowerCase() == 'month') {
          if (rec.monthlyMode == 'day') {
            data["monthly_pattern"] = "date";
            data["month_day"] = rec.monthDay;
          }
        }

        data["start_date"] = DateFormat('yyyy-MM-dd').format(rec.startDate);
        if (rec.endByDate != null) {
          data["end_date"] = DateFormat('yyyy-MM-dd').format(rec.endByDate!);
        }
        if (rec.occurrences != null) {
          data["occurrences"] = rec.occurrences;
        }
      }

      final success = await _repository.addPaymentReminder(data);
      if (success) {
        AppCommonToastMessage.show(message: 'Payment reminder added successfully.', type: ToastType.success);
        // Refresh list
        try {
          Get.find<PaymentReminderController>().fetchPaymentReminders();
        } catch (_) {}
        Get.back();
      } else {
        AppCommonToastMessage.show(message: 'Failed to add payment reminder.', type: ToastType.error);
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
