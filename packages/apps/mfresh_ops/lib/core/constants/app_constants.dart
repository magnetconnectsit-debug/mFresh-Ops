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
  static const String sendOtp = 'adminsend-otp';
  static const String verifyOtp = 'adminverify-otp';

  // Booking Module
  static const String customerBookingDetails = 'customer/customerbookingdetails';
  static const String resendBookingSms = 'customer/resend-booking-sms';
  static const String allUnitServices = 'customer/Api-get-Unit-services';
  static const String bookingHistory = 'customer/bookinghistory';
  static const String allUnits = 'customer/All-Units';
  static const String initiateBooking = 'customer/Api-initiateBooking';
  static const String successBooking = 'customer/Api-SuccessBooking';
  static const String validateMemPhone = 'customer/validate-mem-phone';
  static const String sendOtpMember = 'customer/send-otp-member';
  static const String verifyOtpMember = 'customer/verify-otp-member';
  static const String kioskScan = 'customer/kiosk-scan';

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
  static const String createSupportTicketComment =
      'create-support-ticket-comment';
  static const String updateSupportTicketComment =
      'update-support-ticket-comment';
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

  // Inventory
  static const String invGetStates = 'inv-get-states';
  static const String invStatesWiseDistrict = 'inv-states-Wise-District';
  static const String invStores = 'inv-stores';
  static const String invCategory = 'inv-Category';
  static const String inventoryAllItems = 'inventory/all-items';
  static const String invStoreStockView = 'inv-Store-stock-View';
  static const String invStoreToUnitAllocate = 'inv-Store-To-Unit-Allocate';
  static const String inventoryConsume = 'inventory/consume';
  static const String inventoryUnitStock = 'inventory/Unit/Stock';
  static const String invCategoryWiseItem = 'inv-Category-wise-Item';
  static const String invEntryStoreStock = 'inv-entry-store-stock';
  static const String consumptionReport = 'consumption/report';
  static const String consumptionReverse = 'consumption/reverse';
  static const String allotmentReport = 'inventory/allotment-report';
  static const String allotmentReverse = 'inventory/reverse-allotment';
  static const String storeRoomCreate = 'store-room/create';
  static const String storeRoomUpdate = 'store-room/update';
  static const String inventoryCreate = 'inventory/create';
  static const String inventoryUpdate = 'inventory/update';
  static const String measurementCreate = 'measurement/create';
  static const String measurementUpdate = 'measurement/update';
  static const String measurementDelete = 'measurement/delete';
  static const String measurementList = 'measurement/list';

  // Tracking
  static const String trackingStart = 'tracking/start';
  static const String trackingLocationUpdate = 'tracking/location-update';
  static const String trackingBulkSync = 'tracking/bulk-sync';
  static const String trackingStop = 'tracking/stop';
  static const String trackingDutyOn = 'tracking/duty-on';
  static const String trackingDutyOff = 'tracking/duty-off';
  static const String trackingCurrentStatus = 'tracking/current-status';
  static const String trackingMyRouteHistory = 'tracking/my-route-history';
  static const String trackingMyStoppages = 'tracking/my-stoppages';
  static const String trackingSegments = 'tracking/segments';
  static const String trackingTodaySummary = 'tracking/today-summary';

  // Staff Tracking (Admin)
  static const String staffEmployees = 'employees';
  static const String staffRouteHistory = 'route-history';
  static const String staffStoppages = 'stoppages';
  static const String staffSummary = 'summary';

  // Collection and deposit
  static const String adminCollectionIndex =
      'collectionindex'; // Admin Collection table data api
  static const String collectionIndex =
      'usercollectionindex'; // User Collection table data api
  static const String adminCollectionActualUpdate =
      'adminupdateActual'; // Admin actual value update api
  static const String collectionActualUpdate =
      'updateActual'; // User actual value update api
  static const String cashDepositList = 'cash-deposit'; // Cash deposit list api
  static const String cashDepositStore =
      'cash-deposit/store'; // Store cash deposit api
  static const String cashDepositUpdate =
      'cash-deposit/update'; // Update cash deposit api
  static const String cashDepositDelete =
      'deposit/delete'; // Delete cash deposit api

  // Info Directory / Contacts
  static const String contactStore = 'contact/store';
  static const String contactUpdate = 'contact/update';
  static const String contactList = 'contact/list';
  static const String contactDelete = 'contact/delete';
  static const String companyList = 'company/list';
  static const String companyCreate = 'company/create';
  static const String companyUpdate = 'company/update';
  static const String companyDelete = 'company/delete';
  
  static const String brandList = 'brand/list';
  static const String brandCreate = 'brand/create';
  static const String brandUpdate = 'brand/update';
  static const String brandDelete = 'brand/delete';
  // endregion

  // region Hive Keys
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';
  // endregion
}

