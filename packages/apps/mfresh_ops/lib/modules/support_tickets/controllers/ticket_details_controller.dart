import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/constants/app_colors.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart' as dio;

class TicketDetailsController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final commentController = TextEditingController();
  final isInternal = false.obs;
  final ImagePicker _picker = ImagePicker();
  final selectedImages = <File>[].obs;
  final isLoading = false.obs;
  
  final ticketId = Rxn<int>();
  final ticketDetail = Rxn<SupportTicketDetail>();
  
  // Controllers for editing ticket
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitController = TextEditingController();
  
  // Selected values for dropdowns
  final selectedStatus = Rxn<String>();
  final selectedPriority = Rxn<String>();
  final selectedCategory = Rxn<SupportCategory>();
  final selectedSubCategory = Rxn<SupportSubCategory>();
  final selectedAssignee = Rxn<AssigneeModel>();
  final selectedProject = Rxn<SupportProject>();
  final selectedUnit = Rxn<SupportUnit>();
  
  // Reminder Logic for Edit
  final reminderDate = Rxn<DateTime>();
  final reminderTime = Rxn<TimeOfDay>();
  final whatsappNotification = true.obs;
  final appNotification = true.obs;
  final displayReminder = 'Reminder'.obs;
  final followUpDate = Rxn<DateTime>();

  // Options for dropdowns
  final statusOptions = ['New', 'WIP', 'Hold', 'Awaited', 'Resolved', 'Closed'];
  final priorityOptions = ['Low', 'Medium', 'High', 'Top Priority'];
  final categories = <SupportCategory>[].obs;
  final subCategories = <SupportSubCategory>[].obs;
  final assignees = <AssigneeModel>[].obs;
  final projects = <SupportProject>[].obs;
  final units = <SupportUnit>[].obs;

  // For timeline and history
  final activities = <ActivityModel>[].obs;
  final history = <HistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is int) {
      ticketId.value = Get.arguments;
      fetchAllData();
    }
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      // Fetch core details first to show the screen
      await fetchTicketDetails();
      
      // Fetch metadata in background
      Future.wait([
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchAssignees(),
      ]).then((_) async {
         // After fetching categories, fetch subcategories if we have a ticket category
         if (selectedCategory.value != null) {
           await fetchSubCategories(selectedCategory.value!.categoryId);
         }
      });
    } catch (e) {
      debugPrint('Error fetching all data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnits() async {
    try {
      final result = await _supportRepository.getSupportUnits();
      units.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching units: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _supportRepository.getSupportCategories();
      categories.assignAll(result);
      
      // If we have a ticket, match the category object
      if (ticketDetail.value?.categoryId != null) {
        selectedCategory.value = categories.firstWhereOrNull(
          (c) => c.categoryId == ticketDetail.value!.categoryId
        );
        if (selectedCategory.value != null) {
          fetchSubCategories(selectedCategory.value!.categoryId);
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchProjects() async {
    try {
      final result = await _supportRepository.getSupportProjects();
      projects.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

  Future<void> fetchSubCategories(int categoryId) async {
    try {
      final result = await _supportRepository.getSupportSubCategories(categoryId);
      subCategories.assignAll(result);
      
      // If we have a ticket, match the subcategory object
      if (ticketDetail.value?.subcategoryId != null) {
        selectedSubCategory.value = subCategories.firstWhereOrNull(
          (sc) => sc.subCategoryId == ticketDetail.value!.subcategoryId
        );
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  Future<void> fetchAssignees() async {
    try {
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;
      final result = await Get.find<CommonRepository>().getAllAssignees(mainId: user.id.toString());
      assignees.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  Future<void> fetchTicketDetails() async {
    if (ticketId.value == null) return;
    try {
      final response = await _supportRepository.viewSupportTicket(ticketId.value!);
      if (response != null) {
        ticketDetail.value = response;
        
        // Map fields to controllers for editing
        subjectController.text = response.subject ?? '';
        descriptionController.text = response.description ?? '';
        unitController.text = response.unitNo ?? '';
        
        // Map labels to options (In a real app, you'd match by ID from an edit API)
        selectedStatus.value = response.status;
        selectedPriority.value = response.priority;
        
        // Map logs and comments to UI models
        if (response.comments != null) {
          activities.assignAll(response.comments!.map((c) => ActivityModel(
            user: c['commented_by'] ?? 'User',
            action: 'commented',
            comment: c['comment'] ?? '',
            timestamp: c['created_at'] ?? '',
            color: AppColors.primary,
          )).toList());
        }

        if (response.logs != null) {
          history.assignAll(response.logs!.map((l) => HistoryModel(
            date: l['created_at'] ?? '',
            user: l['user_name'] ?? 'System',
            action: l['action'] ?? '',
          )).toList());
        }
        // Map Reminder
        if (response.reminder != null) {
          final r = response.reminder!;
          if (r.reminderDate != null) {
            reminderDate.value = DateTime.tryParse(r.reminderDate!);
          }
          if (r.reminderTime != null) {
             final timeParts = r.reminderTime?.split(":");
             if (timeParts != null && timeParts.length >= 2) {
               int hour = int.parse(timeParts[0]);
               int minute = int.parse(timeParts[1]);
               String period = r.timeType ?? "AM";
               if (period == "PM" && hour != 12) hour += 12;
               if (period == "AM" && hour == 12) hour = 0;
               reminderTime.value = TimeOfDay(hour: hour, minute: minute);
             }
          }
          whatsappNotification.value = r.whatsappNotification == "1";
          appNotification.value = r.appNotification == "1";
          
          if (reminderDate.value != null && reminderTime.value != null) {
             displayReminder.value = "${DateFormat("dd MMM").format(reminderDate.value!)} ${reminderTime.value!.format(Get.context!)}";
          }
        }

        if (response.followUp != null && response.followUp!.isNotEmpty) {
          followUpDate.value = DateTime.tryParse(response.followUp!);
        }
      }

      // Also fetch edit data to get IDs for dropdowns
      final editData = await _supportRepository.editSupportTicket(ticketId.value!);
      if (editData != null) {
        // Here we can set the selected models based on IDs
        // This requires the models to be fetched first (handled in fetchAllData)
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch ticket details: $e');
    }
  }

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedImages.addAll(images.map((image) => File(image.path)));
    }
  }

  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      selectedImages.add(File(image.path));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }


  Future<void> saveTicket() async {
    if (ticketId.value == null) return;
    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      
      final Map<String, dynamic> data = {
        'ticket_id': ticketId.value.toString(),
        'unit': selectedUnit.value?.unitId.toString() ?? '',
        'mcat_id': selectedCategory.value?.categoryId.toString() ?? '',
        'projectid': selectedProject.value?.projectId.toString() ?? '',
        'subcat_id': selectedSubCategory.value?.subCategoryId.toString() ?? '',
        'priority': _getPriorityId(selectedPriority.value),
        'subject': subjectController.text,
        'description': descriptionController.text,
        'comment': commentController.text,
        'userid': user?.id.toString() ?? '',
        'created_by': ticketDetail.value?.createdBy.toString() ?? '',
        'assigned_to': selectedAssignee.value?.id.toString() ?? '',
        'follow_up': '',
        'reminder_date': '', // Add date picker if needed
        'reminder_time': '', // Add time picker if needed
      };

      final formData = dio.FormData.fromMap(data);

      // Add attachments
      for (var file in selectedImages) {
        formData.files.add(MapEntry(
          'attachments[]',
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      final response = await _supportRepository.updateSupportTicket(formData);
      
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', 'Ticket updated successfully', backgroundColor: AppColors.success, colorText: AppColors.white);
        // Refresh details
        fetchTicketDetails();
      } else {
        Get.snackbar('Error', response?['message'] ?? 'Failed to update ticket');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getPriorityId(String? priority) {
    switch (priority) {
      case 'Low': return '1';
      case 'Medium': return '2';
      case 'High': return '3';
      case 'Top Priority': return '6';
      default: return '2';
    }
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty && selectedImages.isEmpty) {
      Get.snackbar('Error', 'Please enter a comment or attach an image');
      return;
    }

    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;

      final Map<String, dynamic> data = {
        'ticket_id': ticketId.value.toString(),
        'comment': text,
        'is_internal': isInternal.value ? '1' : '0',
        'user_id': user.id.toString(),
        'folder_path': 'uploads/tickets',
      };

      final formData = dio.FormData.fromMap(data);
      for (var file in selectedImages) {
        formData.files.add(MapEntry(
          'ticket_images[]',
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      final response = await _supportRepository.addComment(formData);
      if (response != null && response['status'] == true) {
        commentController.clear();
        selectedImages.clear();
        isInternal.value = false;
        Get.snackbar('Success', 'Comment added successfully');
        fetchTicketDetails();
      } else {
        Get.snackbar('Error', response?['message'] ?? 'Failed to add comment');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String statusName) async {
    final ticket = ticketDetail.value;
    if (ticket == null) return;

    // Map label to ID
    String statusId = "0";
    switch (statusName) {
      case "New": statusId = "0"; break;
      case "WIP": statusId = "1"; break;
      case "Resolved": statusId = "2"; break;
      case "Closed": statusId = "3"; break;
      case "Hold": statusId = "4"; break;
      case "Awaited": statusId = "5"; break;
    }

    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;

      final success = await _supportRepository.updateTicketStatus(
        ticketId: ticket.id,
        status: statusId,
        projectId: ticket.projectId ?? 0,
        userId: user.id,
        unitId: ticket.unitId ?? 0,
        assigneeId: ticket.assignedToId ?? 0,
        creatorId: ticket.createdById ?? 0,
        categoryId: ticket.categoryId ?? 0,
        subCategoryId: ticket.subcategoryId,
        priority: ticket.priorityId ?? "1",
        subject: ticket.subject ?? "",
        description: ticket.description ?? "",
        followUpDate: ticket.followUp ?? "",
      );

      if (success) {
        Get.snackbar('Success', 'Status updated to $statusName');
        fetchTicketDetails();
      } else {
        Get.snackbar('Error', 'Failed to update status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void shareToWhatsApp() async {
    final ticket = ticketDetail.value;
    if (ticket == null) return;

    final String ticketNo = ticket.caseId ?? ticket.id.toString();
    final String category = ticket.category ?? '-';
    final String subject = ticket.subject ?? '-';
    final String unit = ticket.unitNo ?? '-';

    final message = "Ticket Number: $ticketNo\n"
        "Category: $category\n"
        "Subject: $subject\n"
        "Unit: $unit\n"
        "Link: https://mfreshops.magnetconnects.com/view-ticket/${ticket.id}";

    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web link
      final webUrl = "https://wa.me/?text=${Uri.encodeComponent(message)}";
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
}

class ActivityModel {
  final String user;
  final String action;
  final String comment;
  final String timestamp;
  final Color color;
  final bool isReverseAction;

  ActivityModel({
    required this.user,
    required this.action,
    required this.comment,
    required this.timestamp,
    required this.color,
    this.isReverseAction = false,
  });
}

class HistoryModel {
  final String date;
  final String user;
  final String action;

  HistoryModel({
    required this.date,
    required this.user,
    required this.action,
  });
}
