import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/views/dashboard_view.dart';
import 'package:mfresh_ops/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:mfresh_ops/modules/info_directory/views/info_directory_screen.dart';
import 'package:mfresh_ops/modules/info_directory/views/create_contact_screen.dart';
import 'package:mfresh_ops/modules/info_directory/views/mcontact_brands_screen.dart';
import 'package:mfresh_ops/modules/info_directory/views/mcontact_companies_screen.dart';
import 'package:mfresh_ops/modules/info_directory/views/account_subscription_screen.dart';
import 'package:mfresh_ops/modules/info_directory/views/create_account_subscription_screen.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/account_subscription_controller.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_account_subscription_controller.dart';
import 'package:mfresh_ops/data/repositories/account_subscription_repository.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/payment_reminder_screen.dart';
import 'package:mfresh_ops/data/repositories/payment_reminder_repository.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:dev/views/dev_passcode_screen.dart';
import 'package:dev/views/dev_settings_screen.dart';
import 'package:dev/views/log_viewer_screen.dart';
import 'package:dev/controllers/dev_passcode_controller.dart';
import 'package:dev/controllers/dev_settings_controller.dart';
import 'package:dev/controllers/log_viewer_controller.dart';
import 'package:mfresh_ops/modules/splash/views/splash_screen.dart';
import 'package:mfresh_ops/modules/splash/views/location_permission_screen.dart';
import 'package:mfresh_ops/modules/authentication/views/login_screen.dart';
import 'package:mfresh_ops/modules/home/views/home_screen.dart';
import 'package:mfresh_ops/modules/collections/views/admin_collections_screen.dart';
import 'package:mfresh_ops/modules/collections/views/collections_screen.dart';
import 'package:mfresh_ops/modules/deposits/views/deposits_screen.dart';
import 'package:mfresh_ops/modules/deposits/views/create_deposit_screen.dart';
import 'package:mfresh_ops/modules/tasks/views/all_tasks_screen.dart';
import 'package:mfresh_ops/modules/tasks/views/daily_tasks_screen.dart';
import 'package:mfresh_ops/modules/tasks/views/create_task_screen.dart';
import 'package:mfresh_ops/modules/tasks/views/task_review_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_tickets_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_dashboard_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_category_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_subcategory_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_projects_screen.dart';
import 'package:mfresh_ops/modules/profile/views/profile_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/create_ticket_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/ticket_details_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/views/edit_ticket_screen.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/inventory/views/store_inventory_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/unit_inventory_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/all_consumption_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/allotment_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/measurement_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/item_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/store_room_screen.dart';
import 'package:mfresh_ops/modules/home/views/notification_screen.dart';
import 'package:mfresh_ops/modules/map/views/map_view.dart';
import 'package:mfresh_ops/modules/map/views/history_view.dart';
import 'package:mfresh_ops/modules/staff_tracking/bindings/staff_tracking_binding.dart';
import 'package:mfresh_ops/modules/staff_tracking/views/staff_tracking_screen.dart';
import 'package:mfresh_ops/modules/attendance_log/views/attendance_log_view.dart';
import 'package:mfresh_ops/modules/attendance_log/bindings/attendance_log_binding.dart';
import 'package:mfresh_ops/modules/attendance_log/views/attendance_breakdown_screen.dart';
import 'package:mfresh_ops/modules/service_details/views/service_details_screen.dart';
import 'package:mfresh_ops/modules/map/bindings/location_binding.dart';
import 'package:mfresh_ops/modules/map/controllers/history_controller.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/create_ticket_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_category_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_subcategory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_projects_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_template_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_template_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_dashboard_controller.dart';
import 'package:mfresh_ops/modules/booking/views/booking_confirmed_screen.dart';
import 'package:mfresh_ops/modules/booking/views/booking_history_screen.dart';
import 'package:mfresh_ops/modules/booking/views/print_receipt_screen.dart';
import 'package:mfresh_ops/modules/booking/views/booking_unit_selection_screen.dart';
import 'package:mfresh_ops/modules/service_details/views/service_details_screen.dart';
import 'package:mfresh_ops/modules/info_directory/views/assets_products_screen.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/assets_products_controller.dart';
import 'package:mfresh_ops/data/repositories/asset_product_repository.dart';
import 'package:mfresh_ops/modules/info_directory/views/create_asset_screen.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_asset_controller.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: DevRoutes.devPasscode,
      page: () => const DevPasscodeScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => DevPasscodeController()),
      ),
    ),
    GetPage(
      name: DevRoutes.devSettings,
      page: () => const DevSettingsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => DevSettingsController()),
      ),
    ),
    GetPage(
      name: DevRoutes.logViewer,
      page: () => const LogViewerScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LogViewerController())),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppRoutes.allTasks,
      page: () => const AllTasksScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TasksController())),
    ),
    GetPage(
      name: AppRoutes.dailyTasks,
      page: () => const DailyTasksScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TasksController())),
    ),
    GetPage(
      name: AppRoutes.supportTickets,
      page: () => const SupportTicketsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SupportTicketsController()),
      ),
    ),
    GetPage(
      name: AppRoutes.createTask,
      page: () => const CreateTaskScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TasksController())),
    ),
    GetPage(
      name: AppRoutes.taskReview,
      page: () => const TaskReviewScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TasksController())),
    ),
    GetPage(
      name: AppRoutes.createSupportTicket,
      page: () => const CreateTicketScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => CreateTicketController()),
      ),
    ),
    GetPage(
      name: AppRoutes.ticketDetails,
      page: () => const TicketDetailsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => TicketDetailsController()),
      ),
    ),
    GetPage(
      name: AppRoutes.supportDashboard,
      page: () => const SupportDashboardScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SupportDashboardController()),
      ),
    ),
    GetPage(
      name: AppRoutes.supportCategory,
      page: () => const SupportCategoryScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SupportCategoryController()),
      ),
    ),
    GetPage(
      name: AppRoutes.supportSubCategory,
      page: () => const SupportSubCategoryScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SupportSubCategoryController()),
      ),
    ),
    GetPage(
      name: AppRoutes.supportProjects,
      page: () => const SupportProjectsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SupportProjectsController()),
      ),
    ),
    GetPage(
      name: AppRoutes.supportTemplate,
      page: () => const SupportTemplateScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SupportTemplateController()),
      ),
    ),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(
      name: AppRoutes.editTicket,
      page: () => const EditTicketScreen(),
      opaque: false,
      binding: BindingsBuilder(
        () => Get.lazyPut(() => TicketDetailsController()),
      ),
    ),
    GetPage(
      name: AppRoutes.storeInventory,
      page: () => const StoreInventoryScreen(),
    ),
    GetPage(
      name: AppRoutes.unitInventory,
      page: () => const UnitInventoryScreen(),
    ),
    GetPage(
      name: AppRoutes.allConsumption,
      page: () => const AllConsumptionScreen(),
    ),
    GetPage(name: AppRoutes.allotments, page: () => const AllotmentScreen()),
    GetPage(
      name: AppRoutes.measurements,
      page: () => const MeasurementScreen(),
    ),
    GetPage(name: AppRoutes.items, page: () => const ItemScreen()),
    GetPage(name: AppRoutes.storeRooms, page: () => const StoreRoomScreen()),
    GetPage(
      name: AppRoutes.locationPermission,
      page: () => const LocationPermissionScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.liveTracking,
      page: () => const MapView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.routeHistory,
      page: () => const HistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TrackingRepository());
        Get.lazyPut(() => HistoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.staffTracking,
      page: () => const StaffTrackingScreen(),
      binding: StaffTrackingBinding(),
    ),
    GetPage(
      name: AppRoutes.attendanceLog,
      page: () => const AttendanceLogView(),
      binding: AttendanceLogBinding(),
    ),
    GetPage(
      name: AppRoutes.attendanceBreakdown,
      page: () => AttendanceBreakdownScreen(
        employeeName: Get.arguments['employeeName'],
        date: Get.arguments['date'],
      ),
    ),
    GetPage(
      name: AppRoutes.adminCollections,
      page: () => const AdminCollectionsScreen(),
    ),
    GetPage(
      name: AppRoutes.collections,
      page: () => const CollectionsScreen(),
    ),
    GetPage(
      name: AppRoutes.deposits,
      page: () => const DepositsScreen(),
    ),
    GetPage(
      name: AppRoutes.createDeposit,
      page: () => const CreateDepositScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingConfirmed,
      page: () => const BookingConfirmedScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingHistory,
      page: () => const BookingHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.printReceipt,
      page: () => PrintReceiptScreen(booking: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.bookingUnitSelection,
      page: () => const BookingUnitSelectionScreen(),
    ),
    GetPage(
      name: AppRoutes.serviceDetails,
      page: () => const ServiceDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.infoDirectory,
      page: () => const InfoDirectoryScreen(),
    ),
    GetPage(
      name: AppRoutes.createContact,
      page: () => const CreateContactScreen(),
    ),
    GetPage(
      name: AppRoutes.contactBrands,
      page: () => const MContactBrandsScreen(),
    ),
    GetPage(
      name: AppRoutes.contactCompanies,
      page: () => const MContactCompaniesScreen(),
    ),
    GetPage(
      name: AppRoutes.assetsProducts,
      page: () => const AssetsProductsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AssetProductRepository());
        Get.lazyPut(() => AssetsProductsController());
      }),
    ),
    GetPage(
      name: AppRoutes.createAsset,
      page: () => const CreateAssetScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AssetProductRepository());
        Get.lazyPut(() => CreateAssetController());
      }),
    ),
    GetPage(
      name: AppRoutes.accountSubscription,
      page: () => const AccountSubscriptionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AccountSubscriptionRepository());
        Get.lazyPut(() => AccountSubscriptionController());
      }),
    ),
    GetPage(
      name: AppRoutes.createAccountSubscription,
      page: () => const CreateAccountSubscriptionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AccountSubscriptionRepository());
        Get.lazyPut(() => CreateAccountSubscriptionController());
      }),
    ),
    GetPage(
      name: AppRoutes.paymentReminder,
      page: () => const PaymentReminderScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PaymentReminderRepository());
      }),
    ),
  ];
}
