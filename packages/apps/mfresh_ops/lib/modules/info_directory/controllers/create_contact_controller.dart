// region Imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/info_directory/contact_model.dart';
import 'package:mfresh_ops/data/repositories/contact_repository.dart';
// endregion

// region CreateContactController
class CreateContactController extends GetxController {
  // region Dependencies & Repositories
  final ContactRepository _contactRepo = Get.find<ContactRepository>();
  // endregion

  // region Observables & State Variables
  final formKey = GlobalKey<FormState>();
  final isEdit = false.obs;
  ContactModel? editingContact;

  final isLoading = false.obs;

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
    'Blank',
  ].obs;

  // File Picker — supports multiple attachments
  final selectedFiles = <File>[].obs;
  final selectedFileNames = <String>[].obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final nameCtrl = TextEditingController();
  final nameFocus = FocusNode();

  final workedOnCtrl = TextEditingController();
  final workedOnFocus = FocusNode();

  final designationCtrl = TextEditingController();
  final designationFocus = FocusNode();

  final departmentCtrl = TextEditingController();
  final departmentFocus = FocusNode();

  final mobile1Ctrl = TextEditingController();
  final mobile1Focus = FocusNode();

  final mobile2Ctrl = TextEditingController();
  final mobile2Focus = FocusNode();

  final emailCtrl = TextEditingController();
  final emailFocus = FocusNode();

  final gstinCtrl = TextEditingController();
  final gstinFocus = FocusNode();

  final commentCtrl = TextEditingController();
  final commentFocus = FocusNode();

  final typeServiceCtrl = TextEditingController();
  final typeServiceFocus = FocusNode();

  final locationCtrl = TextEditingController();
  final locationFocus = FocusNode();

  final addressCtrl = TextEditingController();
  final addressFocus = FocusNode();

  final websiteLinksCtrl = TextEditingController();
  final websiteLinksFocus = FocusNode();
  // endregion

  // region Dropdown GlobalKeys
  final contactTypeKey = GlobalKey<AppCommonMultiSelectDropdownState<String>>();
  final brandKey = GlobalKey<AppCommonMultiSelectDropdownState<String>>();
  final companyKey = GlobalKey<AppCommonMultiSelectDropdownState<String>>();
  final levelKey = GlobalKey<AppCommonMultiSelectDropdownState<String>>();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
    final args = Get.arguments;
    if (args != null && args is ContactModel) {
      isEdit.value = true;
      editingContact = args;

      nameCtrl.text = args.name;
      selectedContactType.value =
          args.contactType.isEmpty || args.contactType == '-'
              ? null
              : args.contactType;
      selectedBrand.value =
          args.brand.isEmpty || args.brand == '-' ? null : args.brand;
      selectedCompany.value =
          args.company.isEmpty || args.company == '-' ? null : args.company;

      String parsedLevel = args.level.trim();
      if (parsedLevel.toLowerCase() == 'high') {
        parsedLevel = '1';
      } else if (parsedLevel.toLowerCase() == 'medium') {
        parsedLevel = '2';
      } else if (parsedLevel.toLowerCase() == 'low') {
        parsedLevel = '3';
      }
      selectedLevel.value =
          parsedLevel.isEmpty || parsedLevel == '-' ? null : parsedLevel;

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

  @override
  void onClose() {
    nameCtrl.dispose();
    nameFocus.dispose();

    workedOnCtrl.dispose();
    workedOnFocus.dispose();

    designationCtrl.dispose();
    designationFocus.dispose();

    departmentCtrl.dispose();
    departmentFocus.dispose();

    mobile1Ctrl.dispose();
    mobile1Focus.dispose();

    mobile2Ctrl.dispose();
    mobile2Focus.dispose();

    emailCtrl.dispose();
    emailFocus.dispose();

    gstinCtrl.dispose();
    gstinFocus.dispose();

    commentCtrl.dispose();
    commentFocus.dispose();

    typeServiceCtrl.dispose();
    typeServiceFocus.dispose();

    locationCtrl.dispose();
    locationFocus.dispose();

    addressCtrl.dispose();
    addressFocus.dispose();

    websiteLinksCtrl.dispose();
    websiteLinksFocus.dispose();

    super.onClose();
  }
  // endregion

  // region Field Progression / Pointer Navigation
  void focusNextUnfilledField(int currentIndex, [BuildContext? context]) {
    final fields = [
      // 0: Contact Type
      (
        isMandatory: true,
        isFilled: () =>
            selectedContactType.value != null &&
            selectedContactType.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          contactTypeKey.currentState?.openMenu();
        },
      ),
      // 1: Name
      (
        isMandatory: true,
        isFilled: () => nameCtrl.text.trim().isNotEmpty,
        onFocus: () => nameFocus.requestFocus(),
      ),
      // 2: Brand
      (
        isMandatory: false,
        isFilled: () =>
            selectedBrand.value != null &&
            selectedBrand.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          brandKey.currentState?.openMenu();
        },
      ),
      // 3: Company
      (
        isMandatory: false,
        isFilled: () =>
            selectedCompany.value != null &&
            selectedCompany.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          companyKey.currentState?.openMenu();
        },
      ),
      // 4: Worked On
      (
        isMandatory: false,
        isFilled: () => workedOnCtrl.text.trim().isNotEmpty,
        onFocus: () => workedOnFocus.requestFocus(),
      ),
      // 5: GST IN
      (
        isMandatory: false,
        isFilled: () => gstinCtrl.text.trim().isNotEmpty,
        onFocus: () => gstinFocus.requestFocus(),
      ),
      // 6: Designation
      (
        isMandatory: false,
        isFilled: () => designationCtrl.text.trim().isNotEmpty,
        onFocus: () => designationFocus.requestFocus(),
      ),
      // 7: Department
      (
        isMandatory: false,
        isFilled: () => departmentCtrl.text.trim().isNotEmpty,
        onFocus: () => departmentFocus.requestFocus(),
      ),
      // 8: Mobile 1
      (
        isMandatory: true,
        isFilled: () => mobile1Ctrl.text.trim().isNotEmpty,
        onFocus: () => mobile1Focus.requestFocus(),
      ),
      // 9: Mobile 2
      (
        isMandatory: false,
        isFilled: () => mobile2Ctrl.text.trim().isNotEmpty,
        onFocus: () => mobile2Focus.requestFocus(),
      ),
      // 10: Email
      (
        isMandatory: false,
        isFilled: () => emailCtrl.text.trim().isNotEmpty,
        onFocus: () => emailFocus.requestFocus(),
      ),
      // 11: Level
      (
        isMandatory: true,
        isFilled: () =>
            selectedLevel.value != null &&
            selectedLevel.value!.trim().isNotEmpty,
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          levelKey.currentState?.openMenu();
        },
      ),
      // 12: Type Service
      (
        isMandatory: true,
        isFilled: () => typeServiceCtrl.text.trim().isNotEmpty,
        onFocus: () => typeServiceFocus.requestFocus(),
      ),
      // 13: Location
      (
        isMandatory: false,
        isFilled: () => locationCtrl.text.trim().isNotEmpty,
        onFocus: () => locationFocus.requestFocus(),
      ),
      // 14: Address
      (
        isMandatory: false,
        isFilled: () => addressCtrl.text.trim().isNotEmpty,
        onFocus: () => addressFocus.requestFocus(),
      ),
      // 15: Website Links
      (
        isMandatory: false,
        isFilled: () => websiteLinksCtrl.text.trim().isNotEmpty,
        onFocus: () => websiteLinksFocus.requestFocus(),
      ),
      // 16: Comment/Description
      (
        isMandatory: false,
        isFilled: () => commentCtrl.text.trim().isNotEmpty,
        onFocus: () => commentFocus.requestFocus(),
      ),
    ];

    if (currentIndex < 0) {
      // Focus first unfilled mandatory field on form validation
      for (int i = 0; i < fields.length; i++) {
        if (fields[i].isMandatory && !fields[i].isFilled()) {
          fields[i].onFocus();
          return;
        }
      }
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    // Forward progression from current field onwards
    final int start = currentIndex + 1;
    for (int i = start; i < fields.length; i++) {
      if (!fields[i].isFilled()) {
        fields[i].onFocus();
        return;
      }
    }

    // End of form reached or no unfilled fields forward - unfocus instead of wrapping to previous non-mandatory fields
    FocusManager.instance.primaryFocus?.unfocus();
  }
  // endregion

  // region File Handling
  Future<void> pickFile() async {
    Get.bottomSheet(
      Container(
        color: AppColors.white,
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
  // endregion

  // region API & Network Operations
  Future<void> fetchFilterOptions() async {
    final brands = await _contactRepo.fetchBrandList();
    if (brands.isNotEmpty) availableBrands.assignAll(brands);

    final companies = await _contactRepo.fetchCompanyList();
    if (companies.isNotEmpty) availableCompanies.assignAll(companies);

    if (isEdit.value && editingContact != null) {
      final brandName = editingContact!.brand;
      if (brandName.isNotEmpty && brandName != '-') {
        final b = availableBrands.firstWhere(
          (e) => e['name'] == brandName,
          orElse: () => {},
        );
        if (b.isNotEmpty) selectedBrand.value = b['id'].toString();
      }

      final companyName = editingContact!.company;
      if (companyName.isNotEmpty && companyName != '-') {
        final c = availableCompanies.firstWhere(
          (e) => e['name'] == companyName,
          orElse: () => {},
        );
        if (c.isNotEmpty) selectedCompany.value = c['id'].toString();
      }
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      focusNextUnfilledField(-1);
      return;
    }

    if (nameCtrl.text.trim().isEmpty) {
      nameFocus.requestFocus();
      AppCommonToastMessage.show(
        message: 'Name is required',
        type: ToastType.warning,
      );
      return;
    }

    if (mobile1Ctrl.text.trim().isEmpty) {
      mobile1Focus.requestFocus();
      AppCommonToastMessage.show(
        message: 'Mobile 1 is required',
        type: ToastType.warning,
      );
      return;
    }

    if (selectedLevel.value == null || selectedLevel.value!.trim().isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      levelKey.currentState?.openMenu();
      AppCommonToastMessage.show(
        message: 'Level is required',
        type: ToastType.warning,
      );
      return;
    }

    if (typeServiceCtrl.text.trim().isEmpty) {
      typeServiceFocus.requestFocus();
      AppCommonToastMessage.show(
        message: 'Type Service is required',
        type: ToastType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;
      Map<String, dynamic>? response;

      if (isEdit.value && editingContact != null) {
        response = await _contactRepo.updateContact(
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
        response = await _contactRepo.storeContact(
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
              (isEdit.value
                  ? 'Contact Updated Successfully'
                  : 'Contact Added Successfully'),
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message:
              response?['message'] ?? 'Something went wrong. Please try again.',
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
  // endregion
}
// endregion
