import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mfresh_ops/data/models/assignee_model.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_product_model.dart';
import 'package:mfresh_ops/data/repositories/asset_category_repository.dart';
import 'package:mfresh_ops/data/repositories/asset_product_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';

class CreateAssetController extends GetxController {
  late final AssetProductRepository _repo;
  late final AssetCategoryRepository _categoryRepo;
  late final CommonRepository _commonRepo;

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isEdit = false.obs;
  AssetProductModel? editingAsset;

  // Text Controllers
  final itemCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final serialNoCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final vendorCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final warrantyCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final specificationCtrl = TextEditingController();
  final warrantyExpiryDisplayCtrl = TextEditingController();

  // Focus Nodes for jumping to next unfilled field
  final itemFocus = FocusNode();
  final brandFocus = FocusNode();
  final modelFocus = FocusNode();
  final serialNoFocus = FocusNode();
  final locationFocus = FocusNode();
  final unitFocus = FocusNode();
  final positionFocus = FocusNode();
  final vendorFocus = FocusNode();
  final qtyFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final specificationFocus = FocusNode();
  final warrantyExpiryFocus = FocusNode();

  // Dropdown GlobalKeys to open menus programmatically
  final itemTypeKey = GlobalKey<MultiSelectDropdownWidgetState<String>>();
  final categoryKey =
      GlobalKey<MultiSelectDropdownWidgetState<AssetCategoryModel>>();
  final assigneeKey = GlobalKey<MultiSelectDropdownWidgetState<AssigneeModel>>();
  final projectKey = GlobalKey<MultiSelectDropdownWidgetState<String>>();
  final warrantyStatusKey = GlobalKey<MultiSelectDropdownWidgetState<String>>();

  void focusNextUnfilledField(int currentIndex, [BuildContext? context]) {
    final effectiveContext = context ?? Get.context;
    final fields = [
      // 0: Item
      (
        isFilled: () => itemCtrl.text.trim().isNotEmpty,
        onFocus: () => itemFocus.requestFocus(),
      ),
      // 1: Item Type
      (
        isFilled: () =>
            selectedItemType.value != null &&
            selectedItemType.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          itemTypeKey.currentState?.openMenu();
        },
      ),
      // 2: Brand
      (
        isFilled: () => brandCtrl.text.trim().isNotEmpty,
        onFocus: () => brandFocus.requestFocus(),
      ),
      // 3: Model
      (
        isFilled: () => modelCtrl.text.trim().isNotEmpty,
        onFocus: () => modelFocus.requestFocus(),
      ),
      // 4: Category
      (
        isFilled: () => selectedAssetCategory.value != null,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          categoryKey.currentState?.openMenu();
        },
      ),
      // 5: Assigned To
      (
        isFilled: () => selectedAssignee.value != null,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          assigneeKey.currentState?.openMenu();
        },
      ),
      // 6: Serial No
      (
        isFilled: () => serialNoCtrl.text.trim().isNotEmpty,
        onFocus: () => serialNoFocus.requestFocus(),
      ),
      // 7: Project
      (
        isFilled: () =>
            selectedProject.value != null &&
            selectedProject.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          projectKey.currentState?.openMenu();
        },
      ),
      // 8: Warranty Expiry Date
      (
        isFilled: () =>
            warrantyExpiryDisplayCtrl.text.trim().isNotEmpty ||
            (selectedWarrantyExpiry.value != null &&
                selectedWarrantyExpiry.value!.trim().isNotEmpty),
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          warrantyExpiryFocus.requestFocus();
          if (effectiveContext != null) {
            selectWarrantyExpiryDate(effectiveContext);
          }
        },
      ),
      // 9: Warranty Status
      (
        isFilled: () =>
            selectedWarrantyStatus.value != null &&
            selectedWarrantyStatus.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          warrantyStatusKey.currentState?.openMenu();
        },
      ),
      // 10: Installed At (Location)
      (
        isFilled: () => locationCtrl.text.trim().isNotEmpty,
        onFocus: () => locationFocus.requestFocus(),
      ),
      // 11: Unit
      (
        isFilled: () => unitCtrl.text.trim().isNotEmpty,
        onFocus: () => unitFocus.requestFocus(),
      ),
      // 12: Position
      (
        isFilled: () => positionCtrl.text.trim().isNotEmpty,
        onFocus: () => positionFocus.requestFocus(),
      ),
      // 13: Vendor
      (
        isFilled: () => vendorCtrl.text.trim().isNotEmpty,
        onFocus: () => vendorFocus.requestFocus(),
      ),
      // 14: Qty
      (
        isFilled: () => qtyCtrl.text.trim().isNotEmpty,
        onFocus: () => qtyFocus.requestFocus(),
      ),
      // 15: Description
      (
        isFilled: () => descriptionCtrl.text.trim().isNotEmpty,
        onFocus: () => descriptionFocus.requestFocus(),
      ),
      // 16: Specification
      (
        isFilled: () => specificationCtrl.text.trim().isNotEmpty,
        onFocus: () => specificationFocus.requestFocus(),
      ),
    ];

    final int start = currentIndex >= 0 ? currentIndex + 1 : 0;
    // Search forward from start
    for (int i = start; i < fields.length; i++) {
      if (!fields[i].isFilled()) {
        fields[i].onFocus();
        return;
      }
    }
    // Wrap around to search from 0 up to currentIndex
    if (currentIndex >= 0) {
      for (int i = 0; i <= currentIndex; i++) {
        if (!fields[i].isFilled()) {
          fields[i].onFocus();
          return;
        }
      }
    }
    // All fields filled
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Dropdown values
  final selectedItemType = RxnString(); // null, '0' (product), '1' (asset)
  final selectedProject = RxnString();
  final selectedWarrantyStatus = RxnString();
  final selectedWarrantyExpiry = RxnString(); // formatted date string
  final selectedAssetCategory = Rxn<AssetCategoryModel>();
  final selectedAssignee = Rxn<AssigneeModel>();

  // Available options (loaded from API or static)
  final availableItemTypes = <Map<String, String>>[
    {'label': 'Asset', 'value': '1'},
    {'label': 'Products', 'value': '0'},
  ].obs;

  final availableProjects = <Map<String, dynamic>>[].obs; // from API
  final availableWarrantyStatuses = <String>['Expired', 'Available'].obs;
  final availableCategories = <AssetCategoryModel>[].obs;
  final availableAssignees = <AssigneeModel>[].obs;
  final isDropdownsLoading = false.obs;

  // File pickers for 3 attachment types
  final invoiceFiles = <File>[].obs;
  final invoiceFileNames = <String>[].obs;
  final warrantyFiles = <File>[].obs;
  final warrantyFileNames = <String>[].obs;
  final othersFiles = <File>[].obs;
  final othersFileNames = <String>[].obs;

  final ImagePicker _picker = ImagePicker();

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

    _loadProjects();
    _loadDropdownOptions();

    // Populate fields if editing
    final args = Get.arguments;
    if (args is AssetProductModel) {
      editingAsset = args;
      isEdit.value = true;
      _populateFields(args);
    }
  }

  @override
  void onClose() {
    itemCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    serialNoCtrl.dispose();
    locationCtrl.dispose();
    unitCtrl.dispose();
    positionCtrl.dispose();
    vendorCtrl.dispose();
    qtyCtrl.dispose();
    warrantyCtrl.dispose();
    descriptionCtrl.dispose();
    specificationCtrl.dispose();
    warrantyExpiryDisplayCtrl.dispose();

    itemFocus.dispose();
    brandFocus.dispose();
    modelFocus.dispose();
    serialNoFocus.dispose();
    locationFocus.dispose();
    unitFocus.dispose();
    positionFocus.dispose();
    vendorFocus.dispose();
    qtyFocus.dispose();
    descriptionFocus.dispose();
    specificationFocus.dispose();
    warrantyExpiryFocus.dispose();
    super.onClose();
  }

  Future<void> _loadProjects() async {
    try {
      final response = await _repo.fetchProjects();
      if (response != null && response['status'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        availableProjects.value = list;
      }
    } catch (e) {
      debugPrint('[CreateAssetController] _loadProjects error: $e');
    }
  }

  Future<void> _loadDropdownOptions() async {
    isDropdownsLoading.value = true;
    try {
      final results = await Future.wait([
        _categoryRepo.fetchCategories(),
        _commonRepo.getAllAssignees(),
      ]);
      availableCategories.assignAll(results[0] as List<AssetCategoryModel>);
      availableAssignees.assignAll(results[1] as List<AssigneeModel>);

      if (editingAsset != null) {
        _matchCategoryAndAssignee(editingAsset!);
      }
    } catch (e) {
      debugPrint('[CreateAssetController] _loadDropdownOptions error: $e');
    } finally {
      isDropdownsLoading.value = false;
    }
  }

  void _matchCategoryAndAssignee(AssetProductModel asset) {
    if (asset.assetCategoryId.isNotEmpty && asset.assetCategoryId != 'NA') {
      final catId = int.tryParse(asset.assetCategoryId);
      if (catId != null) {
        selectedAssetCategory.value =
            availableCategories.firstWhereOrNull((c) => c.id == catId);
      }
    }
    if (selectedAssetCategory.value == null &&
        asset.assetCategoryName.isNotEmpty &&
        asset.assetCategoryName != 'NA') {
      selectedAssetCategory.value = availableCategories.firstWhereOrNull(
        (c) =>
            c.assetCatName.toLowerCase() ==
            asset.assetCategoryName.toLowerCase(),
      );
    }

    if (asset.assignedTo.isNotEmpty && asset.assignedTo != 'NA') {
      final assId = int.tryParse(asset.assignedTo);
      if (assId != null) {
        selectedAssignee.value =
            availableAssignees.firstWhereOrNull((a) => a.id == assId);
      }
    }
    if (selectedAssignee.value == null &&
        asset.productOwnerName.isNotEmpty &&
        asset.productOwnerName != 'NA') {
      selectedAssignee.value = availableAssignees.firstWhereOrNull(
        (a) => a.name.toLowerCase() == asset.productOwnerName.toLowerCase(),
      );
    }
  }

  void _populateFields(AssetProductModel asset) {
    itemCtrl.text = asset.item;
    brandCtrl.text = asset.brand;
    modelCtrl.text = asset.model;
    serialNoCtrl.text = asset.serialNo;
    locationCtrl.text = asset.location;
    unitCtrl.text = asset.unit;
    positionCtrl.text = asset.position;
    vendorCtrl.text = asset.vendor;
    qtyCtrl.text = asset.qty;
    descriptionCtrl.text = asset.description;
    specificationCtrl.text = asset.specification;
    selectedItemType.value = asset.assetType;
    selectedWarrantyStatus.value = asset.formattedWarrantyType;
    selectedWarrantyExpiry.value =
        asset.warrantyDate == 'NA' ? null : asset.warrantyDate;
    if (selectedWarrantyExpiry.value != null &&
        selectedWarrantyExpiry.value!.isNotEmpty) {
      warrantyExpiryDisplayCtrl.text =
          AppDateUtils.formatToOrdinalDate(selectedWarrantyExpiry.value!);
    } else {
      warrantyExpiryDisplayCtrl.clear();
    }
    selectedProject.value = asset.project;
    _matchCategoryAndAssignee(asset);
  }

  Future<void> pickFiles(
    RxList<File> filesList,
    RxList<String> namesList,
  ) async {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () async {
                  Get.back();
                  final List<XFile> pickedImages =
                      await _picker.pickMultiImage();
                  if (pickedImages.isNotEmpty) {
                    for (final picked in pickedImages) {
                      filesList.add(File(picked.path));
                      namesList.add(picked.name);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back();
                  final picked =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    filesList.add(File(picked.path));
                    namesList.add(picked.name);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void removeFile(
      RxList<File> filesList, RxList<String> namesList, int index) {
    filesList.removeAt(index);
    namesList.removeAt(index);
  }

  Future<void> selectWarrantyExpiryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFFFF6B35)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      selectedWarrantyExpiry.value = formatted;
      warrantyExpiryDisplayCtrl.text = AppDateUtils.formatToOrdinalDate(formatted);
      focusNextUnfilledField(8, context);
    }
  }

  String get _warrantyTypeApiValue {
    if (selectedWarrantyStatus.value == 'Available') return '1';
    if (selectedWarrantyStatus.value == 'Expired') return '0';
    return '';
  }

  Future<void> saveAsset() async {
    if (itemCtrl.text.trim().isEmpty) {
      itemFocus.requestFocus();
      AppCommonToastMessage.show(
        message: 'Item name is required',
        type: ToastType.error,
      );
      return;
    }

    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      focusNextUnfilledField(-1);
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic>? response;

      if (isEdit.value && editingAsset != null) {
        response = await _repo.updateAsset(
          assetId: editingAsset!.id,
          itemName: itemCtrl.text.trim(),
          qty: qtyCtrl.text.trim(),
          brand: brandCtrl.text.trim(),
          model: modelCtrl.text.trim(),
          serialNo: serialNoCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          warrantyDate: selectedWarrantyExpiry.value ?? 'NA',
          warrantyType: _warrantyTypeApiValue,
          location: locationCtrl.text.trim(),
          unit: unitCtrl.text.trim(),
          position: positionCtrl.text.trim(),
          vendor: vendorCtrl.text.trim(),
          itemType: selectedItemType.value ?? '1',
          spec: specificationCtrl.text.trim(),
          project: selectedProject.value ?? '',
          assetCategoryId: selectedAssetCategory.value?.id.toString(),
          assignedTo: selectedAssignee.value?.id.toString(),
          invoiceFiles: invoiceFiles.toList(),
          warrantyFiles: warrantyFiles.toList(),
          othersFiles: othersFiles.toList(),
        );
      } else {
        response = await _repo.storeAsset(
          itemName: itemCtrl.text.trim(),
          qty: qtyCtrl.text.trim(),
          brand: brandCtrl.text.trim(),
          model: modelCtrl.text.trim(),
          serialNo: serialNoCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          warrantyDate: selectedWarrantyExpiry.value ?? 'NA',
          warrantyType: _warrantyTypeApiValue,
          location: locationCtrl.text.trim(),
          unit: unitCtrl.text.trim(),
          position: positionCtrl.text.trim(),
          vendor: vendorCtrl.text.trim(),
          itemType: selectedItemType.value ?? '1',
          spec: specificationCtrl.text.trim(),
          project: selectedProject.value ?? '',
          assetCategoryId: selectedAssetCategory.value?.id.toString(),
          assignedTo: selectedAssignee.value?.id.toString(),
          invoiceFiles: invoiceFiles.toList(),
          warrantyFiles: warrantyFiles.toList(),
          othersFiles: othersFiles.toList(),
        );
      }

      if (response != null && response['status'] == true) {
        Get.back(result: true);
        AppCommonToastMessage.show(
          message: isEdit.value
              ? 'Asset updated successfully'
              : 'Asset created successfully',
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? 'Something went wrong',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('[CreateAssetController] submit error: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred. Please try again.',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submit() => saveAsset();
}
