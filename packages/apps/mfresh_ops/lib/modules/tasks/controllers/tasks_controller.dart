import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TasksController extends GetxController {
  final activeTab = 0.obs; // 0 for Active, 1 for Completed

  // Mock data for tasks
  final tasks = <TaskModel>[
    TaskModel(
      title: 'Cleaning Mirrors',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Overdue',
      statusColor: 'red',
    ),
    TaskModel(
      title: 'Cleaning Outside',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Due',
      statusColor: 'orange',
    ),
    TaskModel(
      title: 'Refill Handwash',
      subtitle: 'iFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Due',
      statusColor: 'orange',
    ),
    TaskModel(
      title: 'Refill Shower Gel',
      subtitle: 'Stock Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Due',
      statusColor: 'orange',
    ),
    TaskModel(
      title: 'Cleaning Reception',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Due',
      statusColor: 'orange',
    ),
    TaskModel(
      title: 'Cleaning Mirrors',
      subtitle: 'MCV Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Upcoming',
      statusColor: 'yellow',
    ),
  ].obs;

  final completedTasks = <TaskModel>[
    TaskModel(
      title: 'Cleaning Mirrors',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Review',
      statusColor: 'darkRed',
    ),
    TaskModel(
      title: 'Cleaning Outside',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Review',
      statusColor: 'darkRed',
    ),
    TaskModel(
      title: 'Cleaning Mirrors',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Completed',
      statusColor: 'green',
    ),
    TaskModel(
      title: 'Cleaning Outside',
      subtitle: 'mFresh Operations',
      time: '8:00 - 9:00 AM',
      date: '12-Sep-25',
      assignee: 'Tapas Ranjan',
      status: 'Completed',
      statusColor: 'green',
    ),
  ].obs;

  void changeTab(int index) {
    activeTab.value = index;
  }

  // Form states for Create/Edit Task
  final photoRequired = true.obs;
  final approvalRequired = true.obs;
  final isRecurring = false.obs;

  void resetForm() {
    photoRequired.value = true;
    approvalRequired.value = true;
    isRecurring.value = false;
    titleController.clear();
    descriptionController.clear();
    securityGroupController.clear();
    attachments.clear();
  }

  // Attachments
  final attachments = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        attachments.add(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final securityGroupController = TextEditingController();

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    securityGroupController.dispose();
    super.onClose();
  }
}

class TaskModel {
  final String title;
  final String subtitle;
  final String time;
  final String date;
  final String assignee;
  final String status;
  final String statusColor;

  TaskModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
    required this.assignee,
    required this.status,
    required this.statusColor,
  });
}
