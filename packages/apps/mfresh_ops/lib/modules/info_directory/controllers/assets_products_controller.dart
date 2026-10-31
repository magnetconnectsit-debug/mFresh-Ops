// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/assignee_model.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_product_model.dart';
import 'package:mfresh_ops/data/repositories/asset_category_repository.dart';
import 'package:mfresh_ops/data/repositories/asset_product_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart' as mfresh_auth;
// endregion

// region Controller
class AssetsProductsController extends GetxController {
  // region Dependencies & Repositories
  late final AssetProductRepository _repo;
  late final AssetCategoryRepository _categoryRepo;
  late final CommonRepository _commonRepo;
  // endregion

  // region Observables & State Variables
  final isLoading = false.obs;
  final RxList<AssetProductModel> assets = <AssetProductModel>[].obs;

  // Pagination
  final perPage = 10.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalRecords = 0.obs;

  // Sorting
  final sortColumn = RxnString();
  final sortOrder = Rx<AppTableSortOrder>(AppTableSortOrder.none);

  AppTableSortOrder get currentSortOrder => sortOrder.value;

  // Expanded Row IDs for responsive row expansion
  final expandedRowIds = <dynamic>{}.obs;

  // Filter state
  final selectedItemType = ''.obs; // '' = all, '0' = product, '1' = asset
  final isSearching = false.obs;
  final searchQuery = ''.obs;

  // Multi-select filters
  final RxSet<AssetCategoryModel> selectedCategories =
      <AssetCategoryModel>{}.obs;
  final RxSet<AssigneeModel> selectedAssignees = <AssigneeModel>{}.obs;

  // Available filter options
  final RxList<String> availableItemTypes =
      <String>['All', 'Asset', 'Products'].obs;
  final RxList<AssetCategoryModel> availableCategories =
      <AssetCategoryModel>[].obs;
  final RxList<AssigneeModel> availableAssignees = <AssigneeModel>[].obs;
  final isFiltersLoading = false.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final searchController = TextEditingController(); // For appbar global search
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _repo = Get.isRegistered<AssetProductRepository>()
        ? Get.find<AssetProductRepository>()
        : Get.put(AssetProductRepository());
    _categoryRepo = Get.isRegistered<AssetCategoryRepository>()
        ? Get.find<AssetCategoryRepository>()
        : Get.put(AssetCategoryRepository());
    _commonRepo = Get.isRegistered<CommonRepository>()
        ? Get.find<CommonRepository>()
        : Get.put(CommonRepository());

    _initData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _initData() async {
    await Future.wait([
      _loadFilterOptions(),
      fetchAssets(),
    ]);
  }
  // endregion

  // region Sorting Methods
  void sortBy(String columnKey, AppTableSortOrder order) {
    sortColumn.value = order == AppTableSortOrder.none ? null : columnKey;
    sortOrder.value = order;

    if (order == AppTableSortOrder.none || sortColumn.value == null) {
      fetchAssets();
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

    final sorted = List<AssetProductModel>.from(assets);
    sorted.sort((a, b) {
      String valA = '';
      String valB = '';
      switch (columnKey) {
        case 'Item':
          valA = a.item;
          valB = b.item;
          break;
        case 'Item Type':
          valA = a.itemTypeLabel;
          valB = b.itemTypeLabel;
          break;
        case 'Brand':
          valA = a.brand;
          valB = b.brand;
          break;
        case 'Category':
          valA = a.assetCategoryName;
          valB = b.assetCategoryName;
          break;
        case 'Owned By':
          valA = a.productOwnerName;
          valB = b.productOwnerName;
          break;
        case 'Model':
          valA = a.model;
          valB = b.model;
          break;
        case 'Serial No':
          valA = a.serialNo;
          valB = b.serialNo;
          break;
        case 'Qty':
          valA = a.qty;
          valB = b.qty;
          break;
        case 'Location':
        case 'Installed At':
          valA = a.location;
          valB = b.location;
          break;
        case 'Unit':
          valA = a.unit;
          valB = b.unit;
          break;
        case 'Vendor':
          valA = a.vendor;
          valB = b.vendor;
          break;
        case 'Project':
          valA = a.project;
          valB = b.project;
          break;
        default:
          valA = a.item;
          valB = b.item;
      }
      final cmp = valA.toLowerCase().compareTo(valB.toLowerCase());
      return order == AppTableSortOrder.ascending ? cmp : -cmp;
    });
    assets.assignAll(sorted);
  }
  // endregion

  // region Search & Filter Methods
  void toggleRowExpansion(dynamic id) {
    if (expandedRowIds.contains(id)) {
      expandedRowIds.remove(id);
    } else {
      expandedRowIds.add(id);
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value && searchController.text.isNotEmpty) {
      searchController.clear();
      searchQuery.value = '';
      fetchAssets(resetPage: true);
    }
  }

  void onSearchSubmitted(String val) {
    searchQuery.value = val.trim();
    fetchAssets(resetPage: true);
  }

  Future<void> _loadFilterOptions() async {
    isFiltersLoading.value = true;
    try {
      final results = await Future.wait([
        _categoryRepo.fetchCategories(),
        _commonRepo.getAllAssignees(),
      ]);

      if (results[0] is List<AssetCategoryModel>) {
        availableCategories.value = results[0] as List<AssetCategoryModel>;
      }
      if (results[1] is List<AssigneeModel>) {
        availableAssignees.value = results[1] as List<AssigneeModel>;
      }
    } catch (e) {
      debugPrint('[AssetsProductsController] _loadFilterOptions error: $e');
    } finally {
      isFiltersLoading.value = false;
    }
  }

  String get _itemTypeApiValue {
    if (selectedItemType.value == 'Asset') return '1';
    if (selectedItemType.value == 'Products') return '0';
    return '';
  }

  void applyFilters() => fetchAssets(resetPage: true);

  Future<void> resetFiltersAndRefresh() async {
    try {
      await Get.find<mfresh_auth.AuthRepository>().fetchProfile();
    } catch (_) {}
    selectedItemType.value = '';
    selectedCategories.clear();
    selectedAssignees.clear();
    searchQuery.value = '';
    searchController.clear();
    sortColumn.value = null;
    sortOrder.value = AppTableSortOrder.none;
    await Future.wait([
      _loadFilterOptions(),
      fetchAssets(resetPage: true),
    ]);
  }
  // endregion

  // region Pagination Methods
  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) return;
    currentPage.value = page;
    fetchAssets();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchAssets({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;
    isLoading.value = true;

    try {
      final catIds = selectedCategories.map((c) => c.id).toList();
      final assigneeIds = selectedAssignees.map((a) => a.id).toList();

      final response = await _repo.fetchList(
        itemType: _itemTypeApiValue,
        globalSearch: searchController.text.trim(),
        perPage: perPage.value,
        page: currentPage.value,
        categories: catIds,
        assignees: assigneeIds,
      );

      if (response != null && response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null) {
          final list = (data['data'] as List? ?? [])
              .map(
                (e) => AssetProductModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          assets.value = list;
          currentPage.value = (data['current_page'] as num?)?.toInt() ?? 1;
          lastPage.value = (data['last_page'] as num?)?.toInt() ?? 1;
          totalRecords.value = (data['total'] as num?)?.toInt() ?? 0;

          if (sortColumn.value != null &&
              sortOrder.value != AppTableSortOrder.none) {
            _applyCurrentSort();
          }
        }
      }
    } catch (e) {
      debugPrint('[AssetsProductsController] fetchAssets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAsset(int assetId) async {
    isLoading.value = true;
    try {
      final response = await _repo.deleteAsset(assetId);
      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: 'Asset deleted successfully',
          type: ToastType.success,
        );
        await fetchAssets();
      }
    } catch (e) {
      debugPrint('[AssetsProductsController] deleteAsset error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // endregion
}
// endregion
