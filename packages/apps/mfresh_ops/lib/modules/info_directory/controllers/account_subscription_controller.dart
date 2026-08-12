import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/account_subscription_model.dart';
import 'package:mfresh_ops/data/repositories/account_subscription_repository.dart';

class AccountSubscriptionController extends GetxController {
  late final AccountSubscriptionRepository _repo;

  final isLoading = true.obs;
  final RxList<AccountSubscriptionModel> subscriptions = <AccountSubscriptionModel>[].obs;
  final RxList<AccountDropdownModel> accountList = <AccountDropdownModel>[].obs;

  // Pagination
  final perPage = 100.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalRecords = 0.obs;

  // Filters
  final unitLocationCtrl = TextEditingController();
  final companyBrandCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  final RxList<String> selectedAccount = <String>[].obs;
  final RxString selectedPayment = ''.obs;
  
  final isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    _repo = Get.find<AccountSubscriptionRepository>();
    _initData();
  }

  @override
  void onClose() {
    unitLocationCtrl.dispose();
    companyBrandCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> _initData() async {
    await fetchAccountList();
    await fetchSubscriptions();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value && searchCtrl.text.isNotEmpty) {
      searchCtrl.clear();
      fetchSubscriptions(resetPage: true);
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
          subscriptions.value = (dataObj['data'] as List)
              .map((e) => AccountSubscriptionModel.fromJson(e as Map<String, dynamic>))
              .toList();

          lastPage.value = dataObj['last_page'] ?? 1;
          totalRecords.value = dataObj['total'] ?? 0;
        } else {
          subscriptions.clear();
        }
      }
    } catch (e) {
      debugPrint('[AccountSubscriptionController] fetchList error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Timer? _debounce;

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
    unitLocationCtrl.clear();
    companyBrandCtrl.clear();
    searchCtrl.clear();
    selectedAccount.clear();
    selectedPayment.value = '';
    await fetchSubscriptions(resetPage: true);
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

  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) return;
    currentPage.value = page;
    fetchSubscriptions();
  }
}
