import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/asset_product_model.dart';
import 'package:mfresh_ops/data/repositories/asset_product_repository.dart';

class AssetsProductsController extends GetxController {
  late final AssetProductRepository _repo;

  final isLoading = false.obs;
  final RxList<AssetProductModel> assets = <AssetProductModel>[].obs;

  // Pagination
  final perPage = 100.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalRecords = 0.obs;

  // Filter state
  final selectedItemType = ''.obs; // '' = all, '0' = product, '1' = asset
  final searchController = TextEditingController(); // For appbar global search
  final isSearching = false.obs;
  final searchQuery = ''.obs;

  // Available filter options
  final RxList<String> availableItemTypes = <String>['All', 'Asset', 'Products'].obs;

  @override
  void onInit() {
    super.onInit();
    _repo = Get.find<AssetProductRepository>();
    fetchAssets();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Maps display label → API value
  String get _itemTypeApiValue {
    switch (selectedItemType.value) {
      case 'Asset':
        return '1';
      case 'Products':
        return '0';
      default:
        return ''; // All
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
      searchController.clear();
      applyFilters();
    }
  }

  Future<void> fetchAssets({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;
    isLoading.value = true;
    try {
      final response = await _repo.fetchList(
        itemType: _itemTypeApiValue,
        globalSearch: searchController.text.trim(),
        perPage: perPage.value,
        page: currentPage.value,
      );

      if (response != null && response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null) {
          final list = (data['data'] as List? ?? [])
              .map((e) => AssetProductModel.fromJson(e as Map<String, dynamic>))
              .toList();
          assets.value = list;
          currentPage.value = (data['current_page'] as num?)?.toInt() ?? 1;
          lastPage.value = (data['last_page'] as num?)?.toInt() ?? 1;
          totalRecords.value = (data['total'] as num?)?.toInt() ?? 0;
        }
      }
    } catch (e) {
      debugPrint('[AssetsProductsController] fetchAssets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() => fetchAssets(resetPage: true);

  Future<void> resetFiltersAndRefresh() async {
    selectedItemType.value = '';
    await fetchAssets(resetPage: true);
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

  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) return;
    currentPage.value = page;
    fetchAssets();
  }
}
