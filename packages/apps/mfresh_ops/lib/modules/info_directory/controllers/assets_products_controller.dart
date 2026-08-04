import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/asset_product_model.dart';

class AssetsProductsController extends GetxController {
  final isLoading = false.obs;
  final RxList<AssetProductModel> assets = <AssetProductModel>[].obs;
  final perPage = 10.obs;

  // Filter state
  final selectedItemType = ''.obs;
  final searchGlobalController = TextEditingController();

  // Available filter options
  final RxList<String> availableItemTypes = <String>[
    'All',
    'Asset',
    'Products',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssets();
  }

  @override
  void onClose() {
    searchGlobalController.dispose();
    super.onClose();
  }

  final searchQuery = ''.obs;

  final searchController = TextEditingController();
  final isSearching = false.obs;

  void toggleSearch() {
    isSearching.value = !isSearching.value;
  }

  Future<void> fetchAssets() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    assets.value = List.generate(
      20,
      (i) => AssetProductModel.dummy((i + 1).toString()),
    );
    isLoading.value = false;
  }

  void applyFilters() {
    // Filtering logic will go here when connected to real API
  }

  Future<void> resetFiltersAndRefresh() async {
    selectedItemType.value = '';
    searchGlobalController.clear();
    await fetchAssets();
  }
}
