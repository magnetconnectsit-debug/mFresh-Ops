class AccountSubscriptionModel {
  final int id;
  final String account;
  final String company;
  final String brand;
  final String service;
  final String unit;
  final String city;
  final String location;
  final String customerID;
  final String mobileNo;
  final String email;
  final String username;
  final String password;
  final String? urls;
  final String? remarks;
  final String planName;
  final String payment;
  final String billingCycleDue;
  final String nextDue;
  final String lastPayment;
  final String? paymentDetails;
  final String? comments;
  final String accountName;
  final String createdAt;
  final String updatedAt;

  AccountSubscriptionModel({
    required this.id,
    required this.account,
    required this.company,
    required this.brand,
    required this.service,
    required this.unit,
    required this.city,
    required this.location,
    required this.customerID,
    required this.mobileNo,
    required this.email,
    required this.username,
    required this.password,
    this.urls,
    this.remarks,
    required this.planName,
    required this.payment,
    required this.billingCycleDue,
    required this.nextDue,
    required this.lastPayment,
    this.paymentDetails,
    this.comments,
    this.accountName = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return AccountSubscriptionModel(
      id: json['id'] ?? 0,
      account: json['account']?.toString() ?? '',
      company: json['Company']?.toString() ?? '',
      brand: json['Brand']?.toString() ?? '',
      service: json['Service']?.toString() ?? '',
      unit: json['Unit']?.toString() ?? '',
      city: json['City']?.toString() ?? '',
      location: json['Location']?.toString() ?? '',
      customerID: json['CustomerID']?.toString() ?? '',
      mobileNo: json['MobileNo']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      username: json['Username']?.toString() ?? '',
      password: json['Password']?.toString() ?? '',
      urls: json['urls']?.toString(),
      remarks: json['remarks']?.toString(),
      planName: json['plan_name']?.toString() ?? '',
      payment: json['payment']?.toString() ?? '',
      billingCycleDue: json['BillingcycleDue']?.toString() ?? '',
      nextDue: json['NextDue']?.toString() ?? '',
      lastPayment: json['LastPayment']?.toString() ?? '',
      paymentDetails: json['PaymentDetails']?.toString(),
      comments: json['Comments']?.toString(),
      accountName: json['account_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class AccountDropdownModel {
  final int id;
  final String accountName;

  AccountDropdownModel({
    required this.id,
    required this.accountName,
  });

  factory AccountDropdownModel.fromJson(Map<String, dynamic> json) {
    return AccountDropdownModel(
      id: json['id'] ?? 0,
      accountName: json['account_name']?.toString() ?? '',
    );
  }
}
