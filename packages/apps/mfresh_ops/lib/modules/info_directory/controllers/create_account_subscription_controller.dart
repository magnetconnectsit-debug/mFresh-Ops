// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/info_directory/account_subscription_model.dart';
import 'package:mfresh_ops/data/repositories/account_subscription_repository.dart';
// endregion

// region CreateAccountSubscriptionController Class
class CreateAccountSubscriptionController extends GetxController {
  // region Dependencies & Repositories
  final AccountSubscriptionRepository _repo =
      Get.find<AccountSubscriptionRepository>();
  // endregion

  // region Observables & State Variables
  final formKey = GlobalKey<FormState>();

  final isEdit = false.obs;
  AccountSubscriptionModel? editingModel;

  final isLoading = false.obs;

  final RxList<AccountDropdownModel> accountList = <AccountDropdownModel>[].obs;
  final RxString selectedAccount = ''.obs;

  final RxString selectedPayment = '1'.obs;
  final Rxn<String> selectedNextDue = Rxn<String>();
  final Rxn<String> selectedLastPayment = Rxn<String>();
  // endregion

  // region Text Controllers & Focus Nodes
  final companyCtrl = TextEditingController();
  final companyFocus = FocusNode();

  final brandCtrl = TextEditingController();
  final brandFocus = FocusNode();

  final serviceCtrl = TextEditingController();
  final serviceFocus = FocusNode();

  final unitCtrl = TextEditingController();
  final unitFocus = FocusNode();

  final cityCtrl = TextEditingController();
  final cityFocus = FocusNode();

  final locationCtrl = TextEditingController();
  final locationFocus = FocusNode();

  final customerIdCtrl = TextEditingController();
  final customerIdFocus = FocusNode();

  final mobileNoCtrl = TextEditingController();
  final mobileNoFocus = FocusNode();

  final emailCtrl = TextEditingController();
  final emailFocus = FocusNode();

  final userNameCtrl = TextEditingController();
  final userNameFocus = FocusNode();

  final passwordCtrl = TextEditingController();
  final passwordFocus = FocusNode();

  final urlsCtrl = TextEditingController();
  final urlsFocus = FocusNode();

  final remarksCtrl = TextEditingController();
  final remarksFocus = FocusNode();

  final planNameCtrl = TextEditingController();
  final planNameFocus = FocusNode();

  final billingCycleCtrl = TextEditingController();
  final billingCycleFocus = FocusNode();

  final paymentDetailsCtrl = TextEditingController();
  final paymentDetailsFocus = FocusNode();

  final commentsCtrl = TextEditingController();
  final commentsFocus = FocusNode();

  final nextDueFocus = FocusNode();
  final lastPaymentFocus = FocusNode();
  // endregion

  // region Dropdown & Date GlobalKeys
  final accountKey = GlobalKey<AppCommonMultiSelectDropdownState<String>>();
  final paymentKey = GlobalKey<AppCommonMultiSelectDropdownState<String>>();
  final nextDueKey = GlobalKey<AppCommonDateFieldState>();
  final lastPaymentKey = GlobalKey<AppCommonDateFieldState>();
  // endregion

  // region Date Helpers
  DateTime? get nextDueDateTime {
    if (selectedNextDue.value == null || selectedNextDue.value!.isEmpty) {
      return null;
    }
    return DateTime.tryParse(selectedNextDue.value!);
  }

  DateTime? get lastPaymentDateTime {
    if (selectedLastPayment.value == null ||
        selectedLastPayment.value!.isEmpty) {
      return null;
    }
    return DateTime.tryParse(selectedLastPayment.value!);
  }
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is AccountSubscriptionModel) {
      isEdit.value = true;
      editingModel = Get.arguments as AccountSubscriptionModel;
    }

    _initData();
  }

  @override
  void onClose() {
    companyCtrl.dispose();
    companyFocus.dispose();

    brandCtrl.dispose();
    brandFocus.dispose();

    serviceCtrl.dispose();
    serviceFocus.dispose();

    unitCtrl.dispose();
    unitFocus.dispose();

    cityCtrl.dispose();
    cityFocus.dispose();

    locationCtrl.dispose();
    locationFocus.dispose();

    customerIdCtrl.dispose();
    customerIdFocus.dispose();

    mobileNoCtrl.dispose();
    mobileNoFocus.dispose();

    emailCtrl.dispose();
    emailFocus.dispose();

    userNameCtrl.dispose();
    userNameFocus.dispose();

    passwordCtrl.dispose();
    passwordFocus.dispose();

    urlsCtrl.dispose();
    urlsFocus.dispose();

    remarksCtrl.dispose();
    remarksFocus.dispose();

    planNameCtrl.dispose();
    planNameFocus.dispose();

    billingCycleCtrl.dispose();
    billingCycleFocus.dispose();

    paymentDetailsCtrl.dispose();
    paymentDetailsFocus.dispose();

    commentsCtrl.dispose();
    commentsFocus.dispose();

    nextDueFocus.dispose();
    lastPaymentFocus.dispose();

    super.onClose();
  }
  // endregion

  // region Field Progression / Pointer Navigation
  void focusNextUnfilledField(int currentIndex, [BuildContext? context]) {
    final fields = [
      // 0: Account
      (
        isMandatory: true,
        isFilled: () => selectedAccount.value.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          accountKey.currentState?.openMenu();
        },
      ),
      // 1: Company
      (
        isMandatory: false,
        isFilled: () => companyCtrl.text.trim().isNotEmpty,
        onFocus: () => companyFocus.requestFocus(),
      ),
      // 2: Brand
      (
        isMandatory: false,
        isFilled: () => brandCtrl.text.trim().isNotEmpty,
        onFocus: () => brandFocus.requestFocus(),
      ),
      // 3: Service
      (
        isMandatory: false,
        isFilled: () => serviceCtrl.text.trim().isNotEmpty,
        onFocus: () => serviceFocus.requestFocus(),
      ),
      // 4: Unit
      (
        isMandatory: false,
        isFilled: () => unitCtrl.text.trim().isNotEmpty,
        onFocus: () => unitFocus.requestFocus(),
      ),
      // 5: City
      (
        isMandatory: false,
        isFilled: () => cityCtrl.text.trim().isNotEmpty,
        onFocus: () => cityFocus.requestFocus(),
      ),
      // 6: Location
      (
        isMandatory: false,
        isFilled: () => locationCtrl.text.trim().isNotEmpty,
        onFocus: () => locationFocus.requestFocus(),
      ),
      // 7: Customer ID
      (
        isMandatory: false,
        isFilled: () => customerIdCtrl.text.trim().isNotEmpty,
        onFocus: () => customerIdFocus.requestFocus(),
      ),
      // 8: Mobile No
      (
        isMandatory: false,
        isFilled: () => mobileNoCtrl.text.trim().isNotEmpty,
        onFocus: () => mobileNoFocus.requestFocus(),
      ),
      // 9: Email
      (
        isMandatory: false,
        isFilled: () => emailCtrl.text.trim().isNotEmpty,
        onFocus: () => emailFocus.requestFocus(),
      ),
      // 10: User Name
      (
        isMandatory: false,
        isFilled: () => userNameCtrl.text.trim().isNotEmpty,
        onFocus: () => userNameFocus.requestFocus(),
      ),
      // 11: Password
      (
        isMandatory: false,
        isFilled: () => passwordCtrl.text.trim().isNotEmpty,
        onFocus: () => passwordFocus.requestFocus(),
      ),
      // 12: URLs
      (
        isMandatory: false,
        isFilled: () => urlsCtrl.text.trim().isNotEmpty,
        onFocus: () => urlsFocus.requestFocus(),
      ),
      // 13: Remarks
      (
        isMandatory: false,
        isFilled: () => remarksCtrl.text.trim().isNotEmpty,
        onFocus: () => remarksFocus.requestFocus(),
      ),
      // 14: Plan Name
      (
        isMandatory: false,
        isFilled: () => planNameCtrl.text.trim().isNotEmpty,
        onFocus: () => planNameFocus.requestFocus(),
      ),
      // 15: Payment
      (
        isMandatory: false,
        isFilled: () => selectedPayment.value.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          paymentKey.currentState?.openMenu();
        },
      ),
      // 16: Billing cycle & Due
      (
        isMandatory: false,
        isFilled: () => billingCycleCtrl.text.trim().isNotEmpty,
        onFocus: () => billingCycleFocus.requestFocus(),
      ),
      // 17: Next Due On
      (
        isMandatory: false,
        isFilled: () =>
            selectedNextDue.value != null &&
            selectedNextDue.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          nextDueKey.currentState?.openDatePicker();
        },
      ),
      // 18: Last Payment
      (
        isMandatory: false,
        isFilled: () =>
            selectedLastPayment.value != null &&
            selectedLastPayment.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          lastPaymentKey.currentState?.openDatePicker();
        },
      ),
      // 19: Payment Details
      (
        isMandatory: false,
        isFilled: () => paymentDetailsCtrl.text.trim().isNotEmpty,
        onFocus: () => paymentDetailsFocus.requestFocus(),
      ),
      // 20: Comments
      (
        isMandatory: false,
        isFilled: () => commentsCtrl.text.trim().isNotEmpty,
        onFocus: () => commentsFocus.requestFocus(),
      ),
    ];

    if (currentIndex < 0) {
      // Focus first unfilled mandatory field on form validation
      for (int i = 0; i < fields.length; i++) {
        if (fields[i].isMandatory && !fields[i].isFilled()) {
          fields[i].onFocus();
          return;
        }
      }
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    // Forward progression from current field onwards
    final int start = currentIndex + 1;
    for (int i = start; i < fields.length; i++) {
      if (!fields[i].isFilled()) {
        fields[i].onFocus();
        return;
      }
    }

    // End of form reached or no unfilled fields forward - unfocus instead of wrapping to previous non-mandatory fields
    FocusManager.instance.primaryFocus?.unfocus();
  }
  // endregion

  // region Initialization & Data Fetching
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
              .map(
                (e) =>
                    AccountDropdownModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint(
        '[CreateAccountSubscriptionController] fetchAccountList error: $e',
      );
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
    billingCycleCtrl.text =
        data.billingCycleDue == 'NA' ? '' : data.billingCycleDue;
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

    if (data.nextDue.isNotEmpty &&
        data.nextDue != 'NA' &&
        data.nextDue != '-') {
      selectedNextDue.value = data.nextDue;
    }
    if (data.lastPayment.isNotEmpty &&
        data.lastPayment != 'NA' &&
        data.lastPayment != '-') {
      selectedLastPayment.value = data.lastPayment;
    }
  }
  // endregion

  // region API & Network Operations
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      focusNextUnfilledField(-1);
      return;
    }

    if (selectedAccount.value.trim().isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      accountKey.currentState?.openMenu();
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
  // endregion
}
// endregion
