import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/roles_responsibilities_repository.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/responsibilities_master_controller.dart';

class AddResponsibilityController extends GetxController {
  final ResponsibilityItem? responsibilityItem;

  AddResponsibilityController({this.responsibilityItem});

  late final RolesResponsibilitiesRepository _repository;
  final formKey = GlobalKey<FormState>();

  final roles = <RoleItem>[].obs;
  final selectedRoleIds = <int>{}.obs;
  final isFetchingRoles = false.obs;

  final guidelinesEnglishCtrl = TextEditingController();
  final guidelinesOdiaCtrl = TextEditingController();

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

    if (responsibilityItem != null) {
      isEditing.value = true;
      guidelinesEnglishCtrl.text = _htmlToCleanText(responsibilityItem!.guidelinesEnglish);
      guidelinesOdiaCtrl.text = _htmlToCleanText(responsibilityItem!.guidelinesOdia);
    }

    fetchRoles();
  }

  String _htmlToCleanText(String? html) {
    if (html == null || html.trim().isEmpty) return '';
    String text = html;

    text = text.replaceAll(RegExp(r'<li[\s\S]*?>', caseSensitive: false), '• ');
    text = text.replaceAll(RegExp(r'<\/li>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<(h[1-6]|p)[\s\S]*?>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<\/(h[1-6]|p)>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    final lines = text.split('\n').map((l) => l.trimRight()).where((l) => l.isNotEmpty);
    return lines.join('\n');
  }

  String _cleanTextToHtml(String text) {
    if (text.trim().isEmpty) return '';
    final lines = text.split('\n');
    final sb = StringBuffer();
    bool inList = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('•') || line.startsWith('-') || line.startsWith('*')) {
        if (!inList) {
          sb.write('<ul>');
          inList = true;
        }
        final item = line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim();
        sb.write('<li>$item</li>');
      } else {
        if (inList) {
          sb.write('</ul>');
          inList = false;
        }
        if (i == 0) {
          sb.write('<h3>$line</h3>');
        } else {
          sb.write('<p>$line</p>');
        }
      }
    }
    if (inList) {
      sb.write('</ul>');
    }
    return sb.toString();
  }

  @override
  void onClose() {
    guidelinesEnglishCtrl.dispose();
    guidelinesOdiaCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchRoles() async {
    isFetchingRoles.value = true;
    try {
      final res = await _repository.getRoles(page: 1, perPage: 100);
      roles.assignAll(res.roles);

      if (responsibilityItem != null) {
        final match = roles.firstWhereOrNull((r) => r.id == responsibilityItem!.roleId);
        if (match != null) {
          selectedRoleIds.assignAll([match.id]);
        } else if (responsibilityItem!.roleName != null) {
          final fallback = RoleItem(
            id: responsibilityItem!.roleId,
            roleName: responsibilityItem!.roleName!,
          );
          roles.add(fallback);
          selectedRoleIds.assignAll([fallback.id]);
        }
      }
    } catch (e) {
      debugPrint("Error fetching roles: $e");
    } finally {
      isFetchingRoles.value = false;
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedRoleIds.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please select at least one Role',
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;
    try {
      final rawEng = guidelinesEnglishCtrl.text.trim();
      final rawOdia = guidelinesOdiaCtrl.text.trim();

      final gEnglish = rawEng.contains('<') ? rawEng : _cleanTextToHtml(rawEng);
      final gOdia = rawOdia.contains('<') ? rawOdia : _cleanTextToHtml(rawOdia);

      bool allSuccess = true;

      if (isEditing.value && responsibilityItem != null) {
        allSuccess = await _repository.updateResponsibility(
          id: responsibilityItem!.id,
          roleId: selectedRoleIds.first,
          guidelinesEnglish: gEnglish,
          guidelinesOdia: gOdia,
        );
      } else {
        for (final rId in selectedRoleIds) {
          final success = await _repository.storeResponsibility(
            roleId: rId,
            guidelinesEnglish: gEnglish,
            guidelinesOdia: gOdia,
          );
          if (!success) allSuccess = false;
        }
      }

      if (allSuccess) {
        Get.back();
        AppCommonToastMessage.show(
          message: isEditing.value
              ? 'Responsibility updated successfully.'
              : 'Responsibility created successfully.',
          type: ToastType.success,
        );
        if (Get.isRegistered<ResponsibilitiesMasterController>()) {
          Get.find<ResponsibilitiesMasterController>().fetchResponsibilities();
        }
      } else {
        AppCommonToastMessage.show(
          message: isEditing.value
              ? 'Failed to update responsibility.'
              : 'Failed to create responsibility.',
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
