// region Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/info_directory/contact_model.dart';
import 'package:mfresh_ops/data/repositories/contact_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region InfoDirectoryController Class
class InfoDirectoryController extends GetxController {
  // region Dependencies & Repositories
  final ContactRepository _contactRepo = Get.find<ContactRepository>();
  // endregion

  // region Observables & State Variables
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

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final perPage = 100.obs;
  final totalRecords = 0.obs;

  // Sorting
  final sortColumn = RxnString();
  final sortOrder = Rx<AppTableSortOrder>(AppTableSortOrder.none);

  AppTableSortOrder get currentSortOrder => sortOrder.value;

  void sortBy(String columnKey, AppTableSortOrder order) {
    sortColumn.value = order == AppTableSortOrder.none ? null : columnKey;
    sortOrder.value = order;

    if (order == AppTableSortOrder.none || sortColumn.value == null) {
      fetchContacts(showFullScreenLoader: false);
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

    final sorted = List<ContactModel>.from(contacts);
    sorted.sort((a, b) {
      String valA = '';
      String valB = '';
      switch (columnKey) {
        case 'name':
          valA = a.name;
          valB = b.name;
          break;
        case 'contact_type':
          valA = a.contactType;
          valB = b.contactType;
          break;
        case 'brand':
          valA = a.brand;
          valB = b.brand;
          break;
        case 'company':
          valA = a.company;
          valB = b.company;
          break;
        case 'mobile1':
          valA = a.mobile1;
          valB = b.mobile1;
          break;
        case 'mobile2':
          valA = a.mobile2;
          valB = b.mobile2;
          break;
        case 'services':
          valA = a.services;
          valB = b.services;
          break;
        case 'description':
          valA = a.description;
          valB = b.description;
          break;
        case 'worked_on':
          valA = a.workedOn;
          valB = b.workedOn;
          break;
        case 'location':
          valA = a.location;
          valB = b.location;
          break;
        case 'department':
          valA = a.department;
          valB = b.department;
          break;
        case 'designation':
          valA = a.designation;
          valB = b.designation;
          break;
        case 'email':
          valA = a.email;
          valB = b.email;
          break;
        case 'weblinks':
          valA = a.weblinks;
          valB = b.weblinks;
          break;
        case 'gstin':
          valA = a.gstin;
          valB = b.gstin;
          break;
        case 'address':
          valA = a.address;
          valB = b.address;
          break;
        default:
          valA = a.name;
          valB = b.name;
      }
      final cmp = valA.toLowerCase().compareTo(valB.toLowerCase());
      return order == AppTableSortOrder.ascending ? cmp : -cmp;
    });
    contacts.assignAll(sorted);
  }

  // Filter Options
  final availableBrands = <Map<String, dynamic>>[].obs;
  final availableCompanies = <Map<String, dynamic>>[].obs;
  final availableContactTypes = <String>[
    'Vendor',
    'Emp. Direct',
    'Emp. Contract',
    'Ads',
    'MT',
    'Jobs- Front',
    'Jobs- Corp',
    'Blank',
  ].obs;

  Timer? _debounce;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
    fetchContacts();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
  // endregion

  // region Search & Filters
  void toggleSearch() {
    isSearching.value = !isSearching.value;
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
    sortColumn.value = null;
    sortOrder.value = AppTableSortOrder.none;
    currentPage.value = 1;
    await fetchContacts();
    isRefreshing.value = false;
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchContacts(showFullScreenLoader: false);
  }
  // endregion

  // region Pagination
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
  // endregion

  // region API & Network Operations
  Future<void> fetchFilterOptions() async {
    final brands = await _contactRepo.fetchBrandList();
    if (brands.isNotEmpty) availableBrands.assignAll(brands);

    final companies = await _contactRepo.fetchCompanyList();
    if (companies.isNotEmpty) availableCompanies.assignAll(companies);
  }

  Future<void> fetchContacts({bool showFullScreenLoader = true}) async {
    try {
      if (showFullScreenLoader) {
        isLoading.value = true;
      } else {
        isFiltering.value = true;
      }

      final response = await _contactRepo.fetchContacts(
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
          totalPages.value =
              int.tryParse(dataObj['last_page']?.toString() ?? '1') ?? 1;
          totalRecords.value =
              int.tryParse(dataObj['total']?.toString() ?? '0') ?? 0;
          perPage.value =
              int.tryParse(dataObj['per_page']?.toString() ?? '100') ?? 100;
        }

        final newContacts = <ContactModel>[];
        for (final e in dataList) {
          if (e is Map) {
            try {
              newContacts.add(
                ContactModel.fromJson(Map<String, dynamic>.from(e)),
              );
            } catch (err) {
              debugPrint('Error parsing contact: $err');
            }
          }
        }
        contacts.assignAll(newContacts);
        if (sortColumn.value != null && sortOrder.value != AppTableSortOrder.none) {
          _applyCurrentSort();
        }
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
      final response = await _contactRepo.deleteContact(id: id);

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
  // endregion
}
// endregion
