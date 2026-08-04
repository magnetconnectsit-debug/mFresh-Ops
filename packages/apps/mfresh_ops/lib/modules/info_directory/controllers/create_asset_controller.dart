import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:core/utils/app_common_toast_message.dart';

class CreateAssetController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

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
  final selectedItemType = RxnString();
  final selectedProject = RxnString();
  final selectedWarrantyStatus = RxnString();
  final selectedWarrantyExpiry = RxnString(); // will store formatted date

  // Available options
  final availableItemTypes = <String>['Asset', 'Products'].obs;
  final availableProjects = <String>['mFresh'].obs;
  final availableWarrantyStatuses = <String>['Available', 'Expired'].obs;

  // File pickers for 3 attachment types
  final invoiceFiles = <File>[].obs;
  final invoiceFileNames = <String>[].obs;

  final warrantyFiles = <File>[].obs;
  final warrantyFileNames = <String>[].obs;

  final othersFiles = <File>[].obs;
  final othersFileNames = <String>[].obs;

  final ImagePicker _picker = ImagePicker();

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
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
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
                  final picked = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
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

  void removeFile(RxList<File> filesList, RxList<String> namesList, int index) {
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
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF6B35)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedWarrantyExpiry.value =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    AppCommonToastMessage.show(
      message: 'Asset created successfully',
      type: ToastType.success,
    );
    Get.back(result: true);
  }
}
