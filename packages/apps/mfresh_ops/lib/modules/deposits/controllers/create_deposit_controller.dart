import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mfresh_ops/data/repositories/deposit_repository.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart' show DepositItem, DepositsController;
import 'package:core/utils/app_common_toast_message.dart';

class CreateDepositController extends GetxController {
  final depositedDate = Rxn<String>();
  final actualDepositController = TextEditingController();
  final forMonth = Rxn<String>();
  final supervisorFileName = Rxn<String>();
  final remarksController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  File? selectedFile;
  DepositItem? editingItem; // Non-null if editing an existing item

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is DepositItem) {
      editingItem = Get.arguments as DepositItem;
      _populateFields(editingItem!);
    }
  }

  void _populateFields(DepositItem item) {
    // Parse friendly date back if possible or use today's date
    // Note: item.date is 'dd-MMM'. For input, let's parse month to api format
    try {
      final parsedMonth = DateFormat('yyyy-MM').parse(item.month);
      forMonth.value = DateFormat('yyyy-MM').format(parsedMonth);
    } catch (_) {
      forMonth.value = item.month;
    }
    
    // Attempt to set a default deposit date
    depositedDate.value = DateFormat('dd-MM-yyyy').format(DateTime.now());
    actualDepositController.text = item.deposit.toStringAsFixed(0);
    remarksController.text = item.remark;
    supervisorFileName.value = item.fileUrl != null ? item.fileUrl!.split('/').last : null;
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      depositedDate.value = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  void selectMonth() {
    final now = DateTime.now();
    final List<String> months = [];
    final List<String> monthValues = [];
    
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMMM yyyy').format(date));
      monthValues.add(DateFormat('yyyy-MM').format(date));
    }

    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Select Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(months[index]),
                      onTap: () {
                        forMonth.value = monthValues[index];
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              )
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
      selectedFile = File(image.path);
      supervisorFileName.value = image.name;
    }
  }

  void clearFile() {
    selectedFile = null;
    supervisorFileName.value = null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (depositedDate.value == null) {
      AppCommonToastMessage.show(message: 'Please pick a deposited date', type: ToastType.warning);
      return;
    }

    if (forMonth.value == null) {
      AppCommonToastMessage.show(message: 'Please select month', type: ToastType.warning);
      return;
    }

    if (editingItem == null && selectedFile == null) {
      AppCommonToastMessage.show(message: 'Please choose supervisor file (image)', type: ToastType.warning);
      return;
    }

    try {
      final repo = Get.find<DepositRepository>();
      
      // format date from dd-MM-yyyy to yyyy-MM-dd
      String apiDate = depositedDate.value!;
      try {
        final parsed = DateFormat('dd-MM-yyyy').parse(depositedDate.value!);
        apiDate = DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {}

      Map<String, dynamic>? response;

      if (editingItem != null) {
        // UPDATE
        response = await repo.updateDeposit(
          id: editingItem!.id.toString(),
          depositDt: apiDate,
          actualDeposit: actualDepositController.text.trim(),
          forMonth: forMonth.value!,
          remarkVal: remarksController.text.trim(),
          folderPath: 'images/supervisor_files',
          supervisorFile: selectedFile,
        );
      } else {
        // STORE NEW
        response = await repo.storeDeposit(
          depositDt: apiDate,
          actualDeposit: actualDepositController.text.trim(),
          forMonth: forMonth.value!,
          remarkVal: remarksController.text.trim(),
          folderPath: 'images/supervisor_files',
          supervisorFile: selectedFile!,
        );
      }

      if (response != null && response['status'] == true) {
        Get.back(); // Back to main deposits list screen
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Deposit saved successfully',
          type: ToastType.success,
        );
        if (Get.isRegistered<DepositsController>()) {
          Get.find<DepositsController>().fetchDeposits();
        }
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to submit deposit',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error submitting deposit: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred during submission',
        type: ToastType.error,
      );
    }
  }

  @override
  void onClose() {
    actualDepositController.dispose();
    remarksController.dispose();
    super.onClose();
  }
}
