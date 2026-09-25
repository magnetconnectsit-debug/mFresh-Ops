class PaymentReminderResponse {
  final bool? success;
  final bool? status;
  final String? message;
  final int? count;
  final String? financialYear;
  final dynamic fromMonth;
  final dynamic toMonth;
  final List<PaymentReminderUser> users;
  final List<PaymentReminderItem> paymentReminders;

  PaymentReminderResponse({
    this.success,
    this.status,
    this.message,
    this.count,
    this.financialYear,
    this.fromMonth,
    this.toMonth,
    required this.users,
    required this.paymentReminders,
  });

  factory PaymentReminderResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['result'] ?? json['payment_reminders'] ?? json['data'];
    return PaymentReminderResponse(
      success: json['success'],
      status: json['status'],
      message: json['message'],
      count: json['count'] ?? json['result_count'],
      financialYear: json['financial_year']?.toString(),
      fromMonth: json['from_month'],
      toMonth: json['to_month'],
      users: json['users'] != null && json['users'] is List
          ? List<PaymentReminderUser>.from(
              (json['users'] as List).map((x) => PaymentReminderUser.fromJson(x as Map<String, dynamic>)))
          : [],
      paymentReminders: rawList != null && rawList is List
          ? List<PaymentReminderItem>.from(
              (rawList as List).map((x) => PaymentReminderItem.fromJson(x as Map<String, dynamic>)))
          : [],
    );
  }
}

class PaymentReminderUser {
  final int id;
  final String? name;

  PaymentReminderUser({
    required this.id,
    this.name,
  });

  factory PaymentReminderUser.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['user_id'] ?? json['assignee_id'] ?? 0;
    final parsedId = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
    final rawName = json['name'] ?? json['user_name'] ?? json['full_name'] ?? json['username'] ?? json['label'] ?? json['to'];
    return PaymentReminderUser(
      id: parsedId,
      name: rawName?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentReminderUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PaymentReminderItem {
  final int id;
  final int? parentId;
  final dynamic recurrenceId;
  final String? forDesc;
  final String? brand;
  final String? location;
  final String? to;
  final int? assigneeId;
  final String? assigneeName;
  final String? expenseHead;
  final String? subHead;
  final String? costCenter;
  final String? expenseType;
  final String? dueDate;
  final String? reminderSetupDate;
  final String? reminderDate;
  final String? endDate;
  final String? notificationDate;
  final String? notificationTime;
  final String? completedAt;
  final String? dueIn;
  final String? status;
  final dynamic remindBefore;
  final String? additionalNumber;
  final dynamic whatsappNotification;
  final dynamic appNotification;
  final dynamic recurringReminder;

  PaymentReminderItem({
    required this.id,
    this.parentId,
    this.recurrenceId,
    this.forDesc,
    this.brand,
    this.location,
    this.to,
    this.assigneeId,
    this.assigneeName,
    this.expenseHead,
    this.subHead,
    this.costCenter,
    this.expenseType,
    this.dueDate,
    this.reminderSetupDate,
    this.reminderDate,
    this.endDate,
    this.notificationDate,
    this.notificationTime,
    this.completedAt,
    this.dueIn,
    this.status,
    this.remindBefore,
    this.additionalNumber,
    this.whatsappNotification,
    this.appNotification,
    this.recurringReminder,
  });

  factory PaymentReminderItem.fromJson(Map<String, dynamic> json) {
    return PaymentReminderItem(
      id: json['id'] ?? 0,
      parentId: json['parent_id'],
      recurrenceId: json['recurrence_id'],
      forDesc: json['for'],
      brand: json['brand'],
      location: json['location'],
      to: json['to']?.toString() ?? json['customer_id']?.toString(),
      assigneeId: json['assignee_id'],
      assigneeName: json['assignee_name'],
      expenseHead: json['expense_head'],
      subHead: json['sub_head'],
      costCenter: json['cost_center'],
      expenseType: json['expense_type'],
      dueDate: json['due_date'],
      reminderSetupDate: json['reminder_setup_date'] ?? json['notification_date'],
      reminderDate: json['reminder_date'] ?? json['notification_date'],
      endDate: json['end_date'] ?? json['reminder_end_date'],
      notificationDate: json['notification_date'],
      notificationTime: json['notification_time'],
      completedAt: json['completed_at'],
      dueIn: json['due_in'],
      status: json['status'],
      remindBefore: json['remind_before'],
      additionalNumber: json['additional_number']?.toString(),
      whatsappNotification: json['whatsapp_notification'],
      appNotification: json['app_notification'],
      recurringReminder: json['recurring_reminder'],
    );
  }
}
