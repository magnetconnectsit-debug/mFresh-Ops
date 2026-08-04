import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/asset_product_model.dart';
import 'package:mfresh_ops/data/repositories/asset_product_repository.dart';

class CreateAssetController extends GetxController {
  late final AssetProductRepository _repo;

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

  // Dropdown values
  final selectedItemType = RxnString(); // null, '0' (product), '1' (asset)
  final selectedProject = RxnString();
  final selectedWarrantyStatus = RxnString();
  final selectedWarrantyExpiry = RxnString(); // formatted date string

  // Available options (loaded from API or static)
  final availableItemTypes = <Map<String, String>>[
    {'label': 'Asset', 'value': '1'},
    {'label': 'Products', 'value': '0'},
  ].obs;

  final availableProjects = <Map<String, dynamic>>[].obs; // from API
  final availableWarrantyStatuses = <String>['NA', '0', '1'].obs;

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
    _repo = Get.find<AssetProductRepository>();
    _loadProjects();

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
    selectedWarrantyStatus.value = asset.warrantyType;
    selectedWarrantyExpiry.value =
        asset.warrantyDate == 'NA' ? null : asset.warrantyDate;
    selectedProject.value = asset.project;
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
                  final picked =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    filesList.add(File(picked.path));
                    namesList.add(picked.name);
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
      selectedWarrantyExpiry.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
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
          warrantyType: selectedWarrantyStatus.value ?? 'NA',
          location: locationCtrl.text.trim(),
          unit: unitCtrl.text.trim(),
          position: positionCtrl.text.trim(),
          vendor: vendorCtrl.text.trim(),
          itemType: selectedItemType.value ?? '1',
          spec: specificationCtrl.text.trim(),
          project: selectedProject.value ?? '',
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
          warrantyType: selectedWarrantyStatus.value ?? 'NA',
          location: locationCtrl.text.trim(),
          unit: unitCtrl.text.trim(),
          position: positionCtrl.text.trim(),
          vendor: vendorCtrl.text.trim(),
          itemType: selectedItemType.value ?? '1',
          spec: specificationCtrl.text.trim(),
          project: selectedProject.value ?? '',
          invoiceFiles: invoiceFiles.toList(),
          warrantyFiles: warrantyFiles.toList(),
          othersFiles: othersFiles.toList(),
        );
      }

      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: isEdit.value
              ? 'Asset updated successfully'
              : 'Asset created successfully',
          type: ToastType.success,
        );
        Get.back(result: true);
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
}
