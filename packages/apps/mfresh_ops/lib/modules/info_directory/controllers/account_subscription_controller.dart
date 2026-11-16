// region Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/info_directory/account_subscription_model.dart';
import 'package:mfresh_ops/data/repositories/account_subscription_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart' as mfresh_auth;
// endregion

// region Controller
class AccountSubscriptionController extends GetxController {
  // region Dependencies & Repositories
  late final AccountSubscriptionRepository _repo;
  // endregion

  // region Observables & State Variables
  final isLoading = true.obs;
  final RxList<AccountSubscriptionModel> subscriptions =
      <AccountSubscriptionModel>[].obs;
  final RxList<AccountDropdownModel> accountList = <AccountDropdownModel>[].obs;

  // Pagination
  final perPage = 100.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalRecords = 0.obs;

  // Filters
  final RxList<String> selectedAccount = <String>[].obs;
  final RxString selectedPayment = ''.obs;
  final isSearching = false.obs;

  // Sorting
  final sortColumn = RxnString();
  final sortOrder = Rx<AppTableSortOrder>(AppTableSortOrder.none);

  AppTableSortOrder get currentSortOrder => sortOrder.value;

  Timer? _debounce;
  // endregion

  // region Text Controllers & Focus Nodes
  final unitLocationCtrl = TextEditingController();
  final companyBrandCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _repo = Get.find<AccountSubscriptionRepository>();
    _initData();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    unitLocationCtrl.dispose();
    companyBrandCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> _initData() async {
    await fetchAccountList();
    await fetchSubscriptions();
  }
  // endregion

  // region Sorting Methods
  void sortBy(String columnKey, AppTableSortOrder order) {
    sortColumn.value = order == AppTableSortOrder.none ? null : columnKey;
    sortOrder.value = order;

    if (order == AppTableSortOrder.none || sortColumn.value == null) {
      fetchSubscriptions();
      return;
    }

    _applyCurrentSort();
  }

  void _applyCurrentSort() {
    if (sortColumn.value == null || sortOrder.value == AppTableSortOrder.none) {
      return;
    }

    final columnKey = sortColumn.value!;
    final order = sortOrder.value;

    final sorted = List<AccountSubscriptionModel>.from(subscriptions);
    sorted.sort((a, b) {
      String valA = '';
      String valB = '';
      switch (columnKey) {
        case 'account':
          valA = a.accountName;
          valB = b.accountName;
          break;
        case 'company':
          valA = a.company;
          valB = b.company;
          break;
        case 'brand':
          valA = a.brand;
          valB = b.brand;
          break;
        case 'service':
          valA = a.service;
          valB = b.service;
          break;
        case 'unit':
          valA = a.unit;
          valB = b.unit;
          break;
        case 'city':
          valA = a.city;
          valB = b.city;
          break;
        case 'location':
          valA = a.location;
          valB = b.location;
          break;
        case 'customerId':
          valA = a.customerID;
          valB = b.customerID;
          break;
        case 'mobileNo':
          valA = a.mobileNo;
          valB = b.mobileNo;
          break;
        case 'email':
          valA = a.email;
          valB = b.email;
          break;
        case 'username':
          valA = a.username;
          valB = b.username;
          break;
        case 'password':
          valA = a.password;
          valB = b.password;
          break;
        case 'urls':
          valA = a.urls ?? '';
          valB = b.urls ?? '';
          break;
        case 'remarks':
          valA = a.remarks ?? '';
          valB = b.remarks ?? '';
          break;
        case 'planName':
          valA = a.planName;
          valB = b.planName;
          break;
        case 'payment':
          valA = a.paymentText;
          valB = b.paymentText;
          break;
        case 'billingCycle':
          valA = a.billingCycleDue;
          valB = b.billingCycleDue;
          break;
        case 'nextDue':
          valA = a.nextDue;
          valB = b.nextDue;
          break;
        case 'lastPayment':
          valA = a.lastPayment;
          valB = b.lastPayment;
          break;
        case 'paymentDetails':
          valA = a.paymentDetails ?? '';
          valB = b.paymentDetails ?? '';
          break;
        default:
          valA = a.accountName;
          valB = b.accountName;
      }
      final cmp = valA.toLowerCase().compareTo(valB.toLowerCase());
      return order == AppTableSortOrder.ascending ? cmp : -cmp;
    });
    subscriptions.assignAll(sorted);
  }
  // endregion

  // region Search & Filter Methods
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value && searchCtrl.text.isNotEmpty) {
      searchCtrl.clear();
      fetchSubscriptions(resetPage: true);
    }
  }

  void applyFilters({bool debounce = false}) {
    if (debounce) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        fetchSubscriptions(resetPage: true);
      });
    } else {
      fetchSubscriptions(resetPage: true);
    }
  }

  Future<void> resetFiltersAndRefresh() async {
    try {
      await Get.find<mfresh_auth.AuthRepository>().fetchProfile();
    } catch (_) {}
    unitLocationCtrl.clear();
    companyBrandCtrl.clear();
    searchCtrl.clear();
    selectedAccount.clear();
    selectedPayment.value = '';
    sortColumn.value = null;
    sortOrder.value = AppTableSortOrder.none;
    await fetchSubscriptions(resetPage: true);
  }
  // endregion

  // region Pagination Methods
  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) return;
    currentPage.value = page;
    fetchSubscriptions();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchAccountList() async {
    try {
      final response = await _repo.fetchAccountList();
      if (response != null && response['status'] == true) {
        final dataList = response['data'] as List?;
        if (dataList != null) {
          accountList.value = dataList
              .map(
                (e) => AccountDropdownModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[AccountSubscriptionController] fetchAccountList error: $e');
    }
  }

  Future<void> fetchSubscriptions({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;
    isLoading.value = true;

    try {
      final response = await _repo.fetchList(
        unitLocation: unitLocationCtrl.text.trim(),
        companyBrand: companyBrandCtrl.text.trim(),
        account: selectedAccount.toList(),
        payment: selectedPayment.value,
        globalSearch: searchCtrl.text.trim(),
        perPage: perPage.value,
        page: currentPage.value,
      );

      if (response != null && response['status'] == true) {
        final dataObj = response['data'];
        if (dataObj != null && dataObj['data'] is List) {
          final newSubs = (dataObj['data'] as List)
              .map(
                (e) => AccountSubscriptionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();

          subscriptions.assignAll(newSubs);
          lastPage.value = dataObj['last_page'] ?? 1;
          totalRecords.value = dataObj['total'] ?? 0;

          if (sortColumn.value != null &&
              sortOrder.value != AppTableSortOrder.none) {
            _applyCurrentSort();
          }
        } else {
          subscriptions.clear();
          totalRecords.value = 0;
        }
      }
    } catch (e) {
      debugPrint('[AccountSubscriptionController] fetchList error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSubscription(int id) async {
    isLoading.value = true;
    try {
      final response = await _repo.deleteSubscription(id);
      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: 'Account & Subscription deleted successfully',
          type: ToastType.success,
        );
        await fetchSubscriptions();
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? 'Something went wrong',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('[AccountSubscriptionController] delete error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // endregion
}
// endregion
