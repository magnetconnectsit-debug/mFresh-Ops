import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/roles_responsibilities_repository.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/roles_master_controller.dart';

class AddRoleController extends GetxController {
  final RoleItem? roleItem;

  AddRoleController({this.roleItem});

  late final RolesResponsibilitiesRepository _repository;
  final formKey = GlobalKey<FormState>();
  final roleNameCtrl = TextEditingController();
  final isLoading = false.obs;
  final isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<RolesResponsibilitiesRepository>()) {
      _repository = Get.find<RolesResponsibilitiesRepository>();
    } else {
      _repository = Get.put(RolesResponsibilitiesRepository());
    }

    if (roleItem != null) {
      isEditing.value = true;
      roleNameCtrl.text = roleItem!.roleName;
    }
  }

  @override
  void onClose() {
    roleNameCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final name = roleNameCtrl.text.trim();
      final bool success = isEditing.value && roleItem != null
          ? await _repository.updateRole(roleItem!.id, name)
          : await _repository.storeRole(name);

      if (success) {
        Get.back();
        AppCommonToastMessage.show(
          message: isEditing.value
              ? 'Role updated successfully.'
              : 'Role added successfully.',
          type: ToastType.success,
        );
        if (Get.isRegistered<RolesMasterController>()) {
          Get.find<RolesMasterController>().fetchRoles();
        }
      } else {
        AppCommonToastMessage.show(
          message: isEditing.value
              ? 'Failed to update role.'
              : 'Failed to add role.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred.',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
