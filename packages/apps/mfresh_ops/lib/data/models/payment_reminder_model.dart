class PaymentReminderResponse {
  final bool? status;
  final String? message;
  final PaymentReminderData? data;

  PaymentReminderResponse({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentReminderResponse.fromJson(Map<String, dynamic> json) {
    return PaymentReminderResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? PaymentReminderData.fromJson(json['data']) : null,
    );
  }
}

class PaymentReminderData {
  final String? financialYear;
  final int? fromMonth;
  final int? toMonth;
  final List<PaymentReminderUser> users;
  final List<PaymentReminderItem> paymentReminders;

  PaymentReminderData({
    this.financialYear,
    this.fromMonth,
    this.toMonth,
    required this.users,
    required this.paymentReminders,
  });

  factory PaymentReminderData.fromJson(Map<String, dynamic> json) {
    return PaymentReminderData(
      financialYear: json['financial_year'],
      fromMonth: json['from_month'],
      toMonth: json['to_month'],
      users: json['users'] != null 
        ? List<PaymentReminderUser>.from(json['users'].map((x) => PaymentReminderUser.fromJson(x))) 
        : [],
      paymentReminders: json['payment_reminders'] != null 
        ? List<PaymentReminderItem>.from(json['payment_reminders'].map((x) => PaymentReminderItem.fromJson(x))) 
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
    return PaymentReminderUser(
      id: json['id'] ?? 0,
      name: json['name'],
    );
  }
}

class PaymentReminderItem {
  final int id;
  final String? forDesc;
  final String? brand;
  final String? expenseType;
  final String? expenseHead;
  final String? subHead;
  final String? costCenter;
  final String? location;
  final String? customerId;
  final String? dueDate;
  final int? notificationTo;

  PaymentReminderItem({
    required this.id,
    this.forDesc,
    this.brand,
    this.expenseType,
    this.expenseHead,
    this.subHead,
    this.costCenter,
    this.location,
    this.customerId,
    this.dueDate,
    this.notificationTo,
  });

  factory PaymentReminderItem.fromJson(Map<String, dynamic> json) {
    return PaymentReminderItem(
      id: json['id'] ?? 0,
      forDesc: json['for'],
      brand: json['brand'],
      expenseType: json['expense_type'],
      expenseHead: json['expense_head'],
      subHead: json['sub_head'],
      costCenter: json['cost_center'],
      location: json['location'],
      customerId: json['customer_id'],
      dueDate: json['due_date'],
      notificationTo: json['notification_to'],
    );
  }
}
