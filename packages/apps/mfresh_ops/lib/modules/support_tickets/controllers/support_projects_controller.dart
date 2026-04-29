import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import '../models/support_project_model.dart';

class SupportProjectsController extends GetxController {
  final projectNameController = TextEditingController();

  final allProjects = <SupportProjectModel>[
    SupportProjectModel(siNo: 1, name: 'mFresh'),
    SupportProjectModel(siNo: 2, name: 'iFresh'),
    SupportProjectModel(siNo: 3, name: 'iEvent'),
  ].obs;

  void addProject() {
    if (projectNameController.text.trim().isNotEmpty) {
      final newProject = SupportProjectModel(
        siNo: allProjects.length + 1,
        name: projectNameController.text.trim(),
      );
      allProjects.add(newProject);
      projectNameController.clear();
      Get.back();
      AppCommonToastMessage.show(
        message: "Project added successfully!",
        type: ToastType.success,
      );
    } else {
      AppCommonToastMessage.show(
        message: "Please enter project name",
        type: ToastType.error,
      );
    }
  }

  void editProject(int index, String newName) {
    if (newName.trim().isNotEmpty) {
      allProjects[index] = SupportProjectModel(
        siNo: allProjects[index].siNo,
        name: newName.trim(),
      );
      projectNameController.clear();
      Get.back();
      AppCommonToastMessage.show(
        message: "Project updated successfully!",
        type: ToastType.success,
      );
    }
  }

  void deleteProject(int index) {
    allProjects.removeAt(index);
    // Re-assign SI numbers for consistency
    for (int i = 0; i < allProjects.length; i++) {
      allProjects[i] = SupportProjectModel(siNo: i + 1, name: allProjects[i].name);
    }
    AppCommonToastMessage.show(
      message: "Project deleted successfully!",
      type: ToastType.success,
    );
  }

  @override
  void onClose() {
    projectNameController.dispose();
    super.onClose();
  }
}
