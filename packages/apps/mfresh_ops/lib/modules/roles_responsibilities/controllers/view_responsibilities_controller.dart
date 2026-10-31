// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/roles_responsibilities_repository.dart';
// endregion

// region Controller
class ViewResponsibilitiesController extends GetxController {
  // region Dependencies & Repositories
  late final RolesResponsibilitiesRepository _repository;
  // endregion

  // region Observables & State Variables
  final roles = <RoleItem>[].obs;
  final selectedRoleId = Rxn<int>();
  final selectedLanguage = 'english'.obs;

  final isLoading = false.obs;
  final isFetchingRoles = false.obs;
  final guidelinesText = ''.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<RolesResponsibilitiesRepository>()) {
      _repository = Get.find<RolesResponsibilitiesRepository>();
    } else {
      _repository = Get.put(RolesResponsibilitiesRepository());
    }
    fetchRoles();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchRoles() async {
    isFetchingRoles.value = true;
    try {
      final res = await _repository.getRoles(page: 1, perPage: 100);
      roles.assignAll(res.roles);
    } catch (e) {
      debugPrint("Error fetching roles: $e");
    } finally {
      isFetchingRoles.value = false;
    }
  }

  Future<void> fetchGuidelines() async {
    if (selectedRoleId.value == null) {
      guidelinesText.value = '';
      return;
    }
    isLoading.value = true;
    try {
      final res = await _repository.viewResponsibility(
        roleId: selectedRoleId.value!,
        language: selectedLanguage.value,
      );

      if (res != null &&
          res.guidelines != null &&
          res.guidelines!.isNotEmpty) {
        guidelinesText.value = res.guidelines!;
      } else {
        guidelinesText.value = '';
      }
    } catch (e) {
      guidelinesText.value = '';
    } finally {
      isLoading.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  void onRoleSelected(int? roleId) {
    selectedRoleId.value = roleId;
    fetchGuidelines();
  }

  void onLanguageChanged(String lang) {
    if (selectedLanguage.value != lang) {
      selectedLanguage.value = lang;
      if (selectedRoleId.value != null) {
        fetchGuidelines();
      }
    }
  }
  // endregion
}
// endregion
