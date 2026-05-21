import 'package:flutter/foundation.dart';
import 'package:mfresh_ops/core/config/app_config.dart';

class AppConstants {
  AppConstants._();

  // region Base URL
  static String baseUrl = AppConfig.baseUrl;
  static const bool isDevBuild = kDebugMode;
  // endregion

  // region API Endpoints
  static const String login = 'login';
  static const String profile = 'profile';
  static const String logout = 'logout';
  static const String passwordUpdate = 'password-update';
  static const String profileUpdate = 'profile-update';
  static const String allAssignee = 'all-assignee';
  static const String sendOtp = 'customer/send-otp';
  static const String verifyOtp = 'customer/login-with-otp';
  
  // Support Tickets
  static const String supportUnits = 'support-units';
  static const String supportCategory = 'support-category';
  static const String supportProjects = 'support-projects';
  static const String supportSubcategories = 'support-subcategories';
  static const String createSupportTicket = 'create-support-ticket';
  static const String viewSupportTicket = 'view-support-ticket';
  static const String editSupportTicket = 'edit-support-ticket';
  static const String updateSupportTicket = 'update-support-ticket';
  static const String allSupportTickets = 'all-supporttickets';
  static const String createSupportTicketComment = 'create-support-ticket-comment';
  static const String updateSupportTicketComment = 'update-support-ticket-comment';
  static const String bulkSupportTicketUpdate = 'bulksupport-ticket-update';
  static const String storeSubtask = 'store-subtask-api';
  static const String deleteSubtask = 'delete-subtask-api';
  static const String saveFilter = 'save-filter';
  static const String getFilters = 'get-filters';

  
  // Support Management
  static const String categoryList = 'category-support-ticket-list';
  static const String categoryStore = 'category-support-ticket-store';
  static const String categoryUpdate = 'category-support-ticket-update';
  static const String categoryDelete = 'category-support-ticket-delete';
  static const String categoryEdit = 'category-support-ticket-edit';

  static const String projectList = 'project-list';
  static const String projectStore = 'project-store';
  static const String projectUpdate = 'project-update';
  static const String projectDelete = 'project-delete';
  static const String projectEdit = 'project-edit';

  static const String subcategoryList = 'subcategory-support-ticket-list';
  static const String subcategoryStore = 'subcategory-support-ticket-store';
  static const String subcategoryUpdate = 'subcategory-support-ticket-update';
  static const String subcategoryDelete = 'subcategory-support-ticket-delete';

  // Templates
  static const String templateList = 'all-templates';
  static const String templateStore = 'store-template-api';
  static const String templateUpdate = 'update-template-api';

  // Task Scheduler
  static const String taskProjectList = 'task-project-list';
  static const String taskGroupList = 'task-group-list';
  static const String taskCreate = 'task-create';
  static const String taskIndex = 'task-index';
  static const String dailyTasks = 'daily-tasks';
  static const String taskSubmit = 'task-submit';
  static const String saveTask = 'save-task';
  static const String approveTask = 'approve-task';
  static const String rejectTask = 'reject-task';
  static const String editTask = 'edit-task';
  static const String updateTask = 'update-task';
  static const String deleteTask = 'delete-Task';
  // endregion

  // region Hive Keys
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';
  // endregion
}
