import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/account_subscription_model.dart';
import 'package:mfresh_ops/data/repositories/account_subscription_repository.dart';

class CreateAccountSubscriptionController extends GetxController {
  late final AccountSubscriptionRepository _repo;

  final formKey = GlobalKey<FormState>();

  final isEdit = false.obs;
  AccountSubscriptionModel? editingModel;

  final isLoading = false.obs;
  
  final RxList<AccountDropdownModel> accountList = <AccountDropdownModel>[].obs;
  final RxString selectedAccount = ''.obs;

  final brandCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final mobileNoCtrl = TextEditingController();
  final userNameCtrl = TextEditingController();
  final urlsCtrl = TextEditingController();
  final planNameCtrl = TextEditingController();
  final billingCycleCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final serviceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final customerIdCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final paymentDetailsCtrl = TextEditingController();
  final commentsCtrl = TextEditingController();

  final RxString selectedPayment = '1'.obs;
  final Rxn<String> selectedNextDue = Rxn<String>();
  final Rxn<String> selectedLastPayment = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _repo = Get.find<AccountSubscriptionRepository>();

    if (Get.arguments != null && Get.arguments is AccountSubscriptionModel) {
      isEdit.value = true;
      editingModel = Get.arguments as AccountSubscriptionModel;
    }

    _initData();
  }

  @override
  void onClose() {
    brandCtrl.dispose();
    unitCtrl.dispose();
    locationCtrl.dispose();
    mobileNoCtrl.dispose();
    userNameCtrl.dispose();
    urlsCtrl.dispose();
    planNameCtrl.dispose();
    billingCycleCtrl.dispose();
    companyCtrl.dispose();
    serviceCtrl.dispose();
    cityCtrl.dispose();
    customerIdCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    remarksCtrl.dispose();
    paymentDetailsCtrl.dispose();
    commentsCtrl.dispose();
    super.onClose();
  }

  Future<void> _initData() async {
    await fetchAccountList();
    if (isEdit.value && editingModel != null) {
      _populateForm(editingModel!);
    }
  }

  Future<void> fetchAccountList() async {
    try {
      final response = await _repo.fetchAccountList();
      if (response != null && response['status'] == true) {
        final dataList = response['data'] as List?;
        if (dataList != null) {
          accountList.value = dataList
              .map((e) => AccountDropdownModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[CreateAccountSubscriptionController] fetchAccountList error: $e');
    }
  }

  void _populateForm(AccountSubscriptionModel data) {
    selectedAccount.value = data.account;
    brandCtrl.text = data.brand == 'NA' ? '' : data.brand;
    unitCtrl.text = data.unit == 'NA' ? '' : data.unit;
    locationCtrl.text = data.location == 'NA' ? '' : data.location;
    mobileNoCtrl.text = data.mobileNo == 'NA' ? '' : data.mobileNo;
    userNameCtrl.text = data.username == 'NA' ? '' : data.username;
    urlsCtrl.text = data.urls ?? '';
    planNameCtrl.text = data.planName == 'NA' ? '' : data.planName;
    billingCycleCtrl.text = data.billingCycleDue == 'NA' ? '' : data.billingCycleDue;
    companyCtrl.text = data.company == 'NA' ? '' : data.company;
    serviceCtrl.text = data.service == 'NA' ? '' : data.service;
    cityCtrl.text = data.city == 'NA' ? '' : data.city;
    customerIdCtrl.text = data.customerID == 'NA' ? '' : data.customerID;
    emailCtrl.text = data.email == 'NA' ? '' : data.email;
    passwordCtrl.text = data.password == 'NA' ? '' : data.password;
    remarksCtrl.text = data.remarks ?? '';
    paymentDetailsCtrl.text = data.paymentDetails ?? '';
    commentsCtrl.text = data.comments ?? '';

    selectedPayment.value = data.payment;
    
    if (data.nextDue.isNotEmpty && data.nextDue != 'NA' && data.nextDue != '-') {
      selectedNextDue.value = data.nextDue;
    }
    if (data.lastPayment.isNotEmpty && data.lastPayment != 'NA' && data.lastPayment != '-') {
      selectedLastPayment.value = data.lastPayment;
    }
  }

  Future<void> selectDate(BuildContext context, Rxn<String> target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF6B35)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      // API expects format like 04-Aug-2026 or YYYY-MM-DD
      // We will send it as YYYY-MM-DD
      target.value = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    if (selectedAccount.value.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please select an account',
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;

    try {
      final Map<String, dynamic>? response;

      if (isEdit.value && editingModel != null) {
        response = await _repo.updateSubscription(
          id: editingModel!.id,
          account: selectedAccount.value,
          brand: brandCtrl.text.trim(),
          service: serviceCtrl.text.trim(),
          unit: unitCtrl.text.trim(),
          city: cityCtrl.text.trim(),
          location: locationCtrl.text.trim(),
          customerID: customerIdCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          username: userNameCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
          comments: commentsCtrl.text.trim(),
          company: companyCtrl.text.trim(),
          mobileNo: mobileNoCtrl.text.trim(),
          urls: urlsCtrl.text.trim(),
          remarks: remarksCtrl.text.trim(),
          planName: planNameCtrl.text.trim(),
          payment: selectedPayment.value,
          scheduledDueDate: billingCycleCtrl.text.trim(),
          nextDue: selectedNextDue.value ?? '',
          lastPayment: selectedLastPayment.value ?? '',
          paymentDetails: paymentDetailsCtrl.text.trim(),
        );
      } else {
        response = await _repo.storeSubscription(
          account: selectedAccount.value,
          brand: brandCtrl.text.trim(),
          service: serviceCtrl.text.trim(),
          unit: unitCtrl.text.trim(),
          city: cityCtrl.text.trim(),
          location: locationCtrl.text.trim(),
          customerID: customerIdCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          username: userNameCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
          comments: commentsCtrl.text.trim(),
          company: companyCtrl.text.trim(),
          mobileNo: mobileNoCtrl.text.trim(),
          urls: urlsCtrl.text.trim(),
          remarks: remarksCtrl.text.trim(),
          planName: planNameCtrl.text.trim(),
          payment: selectedPayment.value,
          scheduledDueDate: billingCycleCtrl.text.trim(),
          nextDue: selectedNextDue.value ?? '',
          lastPayment: selectedLastPayment.value ?? '',
          paymentDetails: paymentDetailsCtrl.text.trim(),
        );
      }

      if (response != null && response['status'] == true) {
        Get.back(result: true);
        AppCommonToastMessage.show(
          message: isEdit.value
              ? 'Subscription updated successfully'
              : 'Subscription created successfully',
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? 'Something went wrong',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('[CreateAccountSubscriptionController] submit error: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred. Please try again.',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
