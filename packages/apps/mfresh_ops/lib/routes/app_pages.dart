import 'package:get/get.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:dev/views/dev_passcode_screen.dart';
import 'package:dev/views/dev_settings_screen.dart';
import 'package:dev/views/log_viewer_screen.dart';
import 'package:dev/controllers/dev_passcode_controller.dart';
import 'package:dev/controllers/dev_settings_controller.dart';
import 'package:dev/controllers/log_viewer_controller.dart';
import 'package:mfresh_ops/modules/splash/views/splash_screen.dart';
import 'package:mfresh_ops/modules/authentication/views/login_screen.dart';
import 'package:mfresh_ops/modules/home/views/home_screen.dart';
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
import 'package:mfresh_ops/modules/inventory/views/store_inventory_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/unit_inventory_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/all_consumption_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/allotment_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/measurement_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/item_screen.dart';
import 'package:mfresh_ops/modules/inventory/views/store_room_screen.dart';
import 'package:mfresh_ops/modules/home/views/notification_screen.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/create_ticket_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_category_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_subcategory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_projects_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/support_template_screen.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_template_controller.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: DevRoutes.devPasscode,
      page: () => const DevPasscodeScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DevPasscodeController())),
    ),
    GetPage(
      name: DevRoutes.devSettings,
      page: () => const DevSettingsScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DevSettingsController())),
    ),
    GetPage(
      name: DevRoutes.logViewer,
      page: () => const LogViewerScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LogViewerController())),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationScreen()),
    GetPage(name: AppRoutes.allTasks, page: () => const AllTasksScreen()),
    GetPage(name: AppRoutes.dailyTasks, page: () => const DailyTasksScreen()),
    GetPage(
      name: AppRoutes.supportTickets,
      page: () => const SupportTicketsScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SupportTicketsController())),
    ),
    GetPage(name: AppRoutes.createTask, page: () => const CreateTaskScreen()),
    GetPage(name: AppRoutes.taskReview, page: () => const TaskReviewScreen()),
    GetPage(
      name: AppRoutes.createSupportTicket,
      page: () => const CreateTicketScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CreateTicketController())),
    ),
    GetPage(
      name: AppRoutes.ticketDetails,
      page: () => const TicketDetailsScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TicketDetailsController())),
    ),
    GetPage(
      name: AppRoutes.supportDashboard,
      page: () => const SupportDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.supportCategory,
      page: () => const SupportCategoryScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SupportCategoryController())),
    ),
    GetPage(
      name: AppRoutes.supportSubCategory,
      page: () => const SupportSubCategoryScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SupportSubCategoryController())),
    ),
    GetPage(
      name: AppRoutes.supportProjects,
      page: () => const SupportProjectsScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SupportProjectsController())),
    ),
    GetPage(
      name: AppRoutes.supportTemplate,
      page: () => const SupportTemplateScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SupportTemplateController())),
    ),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(
      name: AppRoutes.editTicket,
      page: () => const EditTicketScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TicketDetailsController())),
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
  ];
}
