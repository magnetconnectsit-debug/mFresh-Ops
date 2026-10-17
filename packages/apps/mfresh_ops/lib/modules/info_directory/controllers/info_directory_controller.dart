import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/info_directory/contact_model.dart';
import 'package:mfresh_ops/data/repositories/contact_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class InfoDirectoryController extends GetxController {
  final contacts = <ContactModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isFiltering = false.obs;

  // Filters
  final searchQuery = ''.obs;
  final Rx<Set<String>> selectedBrands = Rx<Set<String>>({});
  final Rx<Set<String>> selectedCompanies = Rx<Set<String>>({});
  final contactType = ''.obs;

  final searchController = TextEditingController();
  final isSearching = false.obs;

  void toggleSearch() {
    isSearching.value = !isSearching.value;
  }

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final perPage = 100.obs;
  final totalRecords = 0.obs;
  
  // Filter Options
  var availableBrands = <Map<String, dynamic>>[].obs;
  var availableCompanies = <Map<String, dynamic>>[].obs;
  var availableContactTypes = <String>[
    'Vendor',
    'Emp. Direct',
    'Emp. Contract',
    'Ads',
    'MT',
    'Jobs- Front',
    'Jobs- Corp',
    'Blank'
  ].obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
    fetchContacts();
  }

  Future<void> fetchFilterOptions() async {
    final repo = Get.find<ContactRepository>();
    final brands = await repo.fetchBrandList();
    if (brands.isNotEmpty) availableBrands.assignAll(brands);
    
    final companies = await repo.fetchCompanyList();
    if (companies.isNotEmpty) availableCompanies.assignAll(companies);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value != query) {
        searchQuery.value = query;
        currentPage.value = 1;
        fetchContacts(showFullScreenLoader: false);
      }
    });
  }

  Future<void> resetFiltersAndRefresh() async {
    isRefreshing.value = true;
    try {
      await Get.find<AuthRepository>().fetchProfile();
    } catch (_) {}
    searchQuery.value = '';
    searchController.clear();
    selectedBrands.value = {};
    selectedCompanies.value = {};
    contactType.value = '';
    currentPage.value = 1;
    await fetchContacts();
    isRefreshing.value = false;
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchContacts(showFullScreenLoader: false);
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchContacts(showFullScreenLoader: false);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchContacts(showFullScreenLoader: false);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchContacts(showFullScreenLoader: false);
    }
  }

  Future<void> fetchContacts({bool showFullScreenLoader = true}) async {
    try {
      debugPrint('Fetching contacts for page: ${currentPage.value} and perPage: ${perPage.value}');
      
      if (showFullScreenLoader) {
        isLoading.value = true;
      } else {
        isFiltering.value = true;
      }

      final repo = Get.find<ContactRepository>();
      final response = await repo.fetchContacts(
        globalSearch: searchQuery.value,
        contactType: contactType.value,
        brand: selectedBrands.value.toList(),
        company: selectedCompanies.value.toList(),
        page: currentPage.value,
        perPage: perPage.value,
      );

      if (response != null && response['status'] == true) {
        contacts.clear();
        
        var dataList = <dynamic>[];
        if (response['data'] is List) {
          dataList = response['data'] as List;
        } else if (response['data'] is Map) {
          final Map dataObj = response['data'] as Map;
          if (dataObj['data'] is List) {
            dataList = dataObj['data'] as List;
          }
          totalPages.value = int.tryParse(dataObj['last_page']?.toString() ?? '1') ?? 1;
          totalRecords.value = int.tryParse(dataObj['total']?.toString() ?? '0') ?? 0;
          perPage.value = int.tryParse(dataObj['per_page']?.toString() ?? '100') ?? 100;
        }

        final newContacts = <ContactModel>[];
        for (final e in dataList) {
          if (e is Map) {
            try {
              newContacts.add(ContactModel.fromJson(Map<String, dynamic>.from(e)));
            } catch (err) {
              debugPrint('Error parsing contact: $err');
            }
          }
        }
        contacts.assignAll(newContacts);
      } else {
        contacts.clear();
        totalRecords.value = 0;
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to load contacts',
          type: ToastType.error,
        );
      }
    } catch (e) {
      contacts.clear();
      totalRecords.value = 0;
      debugPrint('Error fetching contacts: $e');
      AppCommonToastMessage.show(
        message: 'Error: $e',
        type: ToastType.error,
      );
    } finally {
      if (showFullScreenLoader) {
        isLoading.value = false;
      } else {
        isFiltering.value = false;
      }
    }
  }



  Future<void> deleteContact(String id) async {
    try {
      final repo = Get.find<ContactRepository>();
      final response = await repo.deleteContact(id: id);
      
      if (response != null && response['status'] == true) {
        fetchContacts(showFullScreenLoader: false);
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Contact deleted successfully',
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to delete contact',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred while deleting',
        type: ToastType.error,
      );
    }
  }
}
