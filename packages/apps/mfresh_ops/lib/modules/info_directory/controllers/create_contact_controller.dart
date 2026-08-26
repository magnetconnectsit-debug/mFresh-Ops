import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mfresh_ops/data/models/info_directory/contact_model.dart';
import 'package:mfresh_ops/data/repositories/contact_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class CreateContactController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isEdit = false.obs;
  ContactModel? editingContact;

  // Loading state
  final isLoading = false.obs;

  // Text Controllers
  final nameCtrl = TextEditingController();
  final workedOnCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final mobile1Ctrl = TextEditingController();
  final mobile2Ctrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final gstinCtrl = TextEditingController();
  final commentCtrl = TextEditingController();
  final typeServiceCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final websiteLinksCtrl = TextEditingController();

  // Dropdown Values
  final selectedContactType = RxnString();
  final selectedBrand = RxnString();
  final selectedCompany = RxnString();
  final selectedLevel = RxnString();

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
    'Blank'
  ].obs;

  // File Picker — supports multiple attachments
  final selectedFiles = <File>[].obs;
  final selectedFileNames = <String>[].obs;

  Future<void> pickFile() async {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      selectedFiles.add(File(image.path));
      selectedFileNames.add(image.name);
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      selectedFileNames.removeAt(index);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
    final args = Get.arguments;
    if (args != null && args is ContactModel) {
      isEdit.value = true;
      editingContact = args;

      nameCtrl.text = args.name;
      selectedContactType.value = args.contactType.isEmpty || args.contactType == '-' ? null : args.contactType;
      selectedBrand.value = args.brand.isEmpty || args.brand == '-' ? null : args.brand;
      selectedCompany.value = args.company.isEmpty || args.company == '-' ? null : args.company;
      
      String parsedLevel = args.level.trim();
      if (parsedLevel.toLowerCase() == 'high') parsedLevel = '1';
      else if (parsedLevel.toLowerCase() == 'medium') parsedLevel = '2';
      else if (parsedLevel.toLowerCase() == 'low') parsedLevel = '3';
      selectedLevel.value = parsedLevel.isEmpty || parsedLevel == '-' ? null : parsedLevel;
      
      workedOnCtrl.text = args.workedOn;
      gstinCtrl.text = args.gstin;
      designationCtrl.text = args.designation;
      departmentCtrl.text = args.department;
      mobile1Ctrl.text = args.mobile1;
      mobile2Ctrl.text = args.mobile2;
      emailCtrl.text = args.email;
      commentCtrl.text = args.description;
      typeServiceCtrl.text = args.services;
      locationCtrl.text = args.location;
      addressCtrl.text = args.address;
      websiteLinksCtrl.text = args.weblinks;
    }
  }

  Future<void> fetchFilterOptions() async {
    final repo = Get.find<ContactRepository>();
    final brands = await repo.fetchBrandList();
    if (brands.isNotEmpty) availableBrands.assignAll(brands);
    
    final companies = await repo.fetchCompanyList();
    if (companies.isNotEmpty) availableCompanies.assignAll(companies);

    if (isEdit.value && editingContact != null) {
      final brandName = editingContact!.brand;
      if (brandName.isNotEmpty && brandName != '-') {
        final b = availableBrands.firstWhere((e) => e['name'] == brandName, orElse: () => {});
        if (b.isNotEmpty) selectedBrand.value = b['id'].toString();
      }
      
      final companyName = editingContact!.company;
      if (companyName.isNotEmpty && companyName != '-') {
        final c = availableCompanies.firstWhere((e) => e['name'] == companyName, orElse: () => {});
        if (c.isNotEmpty) selectedCompany.value = c['id'].toString();
      }
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (nameCtrl.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Name is required',
        type: ToastType.warning,
      );
      return;
    }

    if (mobile1Ctrl.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Mobile 1 is required',
        type: ToastType.warning,
      );
      return;
    }

    if (selectedLevel.value == null || selectedLevel.value!.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Level is required',
        type: ToastType.warning,
      );
      return;
    }

    if (typeServiceCtrl.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Type Service is required',
        type: ToastType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;
      final repo = Get.find<ContactRepository>();

      Map<String, dynamic>? response;

      if (isEdit.value && editingContact != null) {
        response = await repo.updateContact(
          id: editingContact!.id,
          name: nameCtrl.text.trim(),
          workedOn: workedOnCtrl.text.trim(),
          level: selectedLevel.value ?? '',
          brand: selectedBrand.value ?? '',
          designation: designationCtrl.text.trim(),
          department: departmentCtrl.text.trim(),
          mobile1: mobile1Ctrl.text.trim(),
          mobile2: mobile2Ctrl.text.trim(),
          email: emailCtrl.text.trim(),
          location: locationCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          weblinks: websiteLinksCtrl.text.trim(),
          typeService: typeServiceCtrl.text.trim(),
          company: selectedCompany.value ?? '',
          description: commentCtrl.text.trim(),
          gstin: gstinCtrl.text.trim(),
          contactType: selectedContactType.value ?? '',
          attachments: selectedFiles.toList(),
        );
      } else {
        response = await repo.storeContact(
          name: nameCtrl.text.trim(),
          workedOn: workedOnCtrl.text.trim(),
          level: selectedLevel.value ?? '',
          brand: selectedBrand.value ?? '',
          designation: designationCtrl.text.trim(),
          department: departmentCtrl.text.trim(),
          mobile1: mobile1Ctrl.text.trim(),
          mobile2: mobile2Ctrl.text.trim(),
          email: emailCtrl.text.trim(),
          location: locationCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          weblinks: websiteLinksCtrl.text.trim(),
          typeService: typeServiceCtrl.text.trim(),
          company: selectedCompany.value ?? '',
          description: commentCtrl.text.trim(),
          gstin: gstinCtrl.text.trim(),
          contactType: selectedContactType.value ?? '',
          attachments: selectedFiles.toList(),
        );
      }

      if (response != null && response['status'] == true) {
        Get.back(result: true);
        AppCommonToastMessage.show(
          message: response['message'] ??
              (isEdit.value ? 'Contact Updated Successfully' : 'Contact Added Successfully'),
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Something went wrong. Please try again.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred. Please check your connection.',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    workedOnCtrl.dispose();
    designationCtrl.dispose();
    departmentCtrl.dispose();
    mobile1Ctrl.dispose();
    mobile2Ctrl.dispose();
    emailCtrl.dispose();
    gstinCtrl.dispose();
    commentCtrl.dispose();
    typeServiceCtrl.dispose();
    locationCtrl.dispose();
    addressCtrl.dispose();
    websiteLinksCtrl.dispose();
    super.onClose();
  }
}
