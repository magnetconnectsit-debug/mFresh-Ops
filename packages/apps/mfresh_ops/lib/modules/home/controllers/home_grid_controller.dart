import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';

class GridSubAction {
  final String title;
  final IconData icon;
  final bool isSolidIcon;
  final String? route;
  final Map<String, dynamic>? arguments;
  final String? permissionKey;

  GridSubAction({
    required this.title,
    required this.icon,
    this.isSolidIcon = false,
    this.route,
    this.arguments,
    this.permissionKey,
  });
}

class GridItemData {
  final String title;
  final String? headerTitle;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? route;
  final String? permissionKey;
  final String? actionPermissionKey;
  final List<GridSubAction> subActions;

  GridItemData({
    required this.title,
    this.headerTitle,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.route,
    this.permissionKey,
    this.actionPermissionKey,
    this.subActions = const [],
  });

  GridItemData copyWith({
    String? title,
    String? headerTitle,
    String? subtitle,
    IconData? icon,
    List<Color>? gradient,
    String? route,
    String? permissionKey,
    String? actionPermissionKey,
    List<GridSubAction>? subActions,
  }) {
    return GridItemData(
      title: title ?? this.title,
      headerTitle: headerTitle ?? this.headerTitle,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      gradient: gradient ?? this.gradient,
      route: route ?? this.route,
      permissionKey: permissionKey ?? this.permissionKey,
      actionPermissionKey: actionPermissionKey ?? this.actionPermissionKey,
      subActions: subActions ?? this.subActions,
    );
  }
}

class HomeGridController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final RxList<GridItemData> gridItems = <GridItemData>[].obs;
  final RxBool isEditMode = false.obs;

  void toggleEditMode() {
    if (_authRepo.rxUserPermissions.contains('Dashboard_Customisation')) {
      isEditMode.value = !isEditMode.value;
    }
  }

  final List<GridItemData> _allItems = [
    GridItemData(
      title: 'Revenue Report',
      headerTitle: 'Reports',
      subtitle: 'View analytics',
      icon: Icons.dashboard_rounded,
      gradient: const [Color(0xFFE85D04), Color(0xFFDC2F02)],
      route: AppRoutes.dashboard,
      permissionKey: 'Dashboard_Panel',
    ),
    GridItemData(
      title: 'Support Ticket',
      headerTitle: 'Ticket Management',
      subtitle: 'Manage helpdesk',
      icon: Icons.support_agent_rounded,
      gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
      route: AppRoutes.supportTickets,
      permissionKey: 'maintenance_panel',
      subActions: [
        GridSubAction(
          title: 'Add',
          icon: Icons.add,
          isSolidIcon: true,
          route: AppRoutes.createSupportTicket,
          permissionKey: 'add_maintenance',
        ),
        GridSubAction(
          title: 'Search',
          icon: Icons.search,
          route: AppRoutes.supportTickets,
          arguments: const {'focusSearch': true},
        ),
      ],
    ),
    GridItemData(
      title: 'Daily Task',
      headerTitle: 'Task Scheduler',
      subtitle: 'Daily operations',
      icon: Icons.assignment_rounded,
      gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      route: AppRoutes.dailyTasks,
      permissionKey: 'Task_Sheduler_Pannel',
      actionPermissionKey: 'Daily_Task',
      subActions: [
        GridSubAction(
          title: 'Add',
          icon: Icons.add,
          isSolidIcon: true,
          route: AppRoutes.createTask,
          permissionKey: 'create_new_task',
        ),
        GridSubAction(
          title: 'All',
          icon: Icons.format_list_bulleted,
          route: AppRoutes.allTasks,
          permissionKey: 'All_Task',
        ),
      ],
    ),
    GridItemData(
      title: 'Unit Inventory',
      headerTitle: 'Inventory',
      subtitle: 'Stock & Items',
      icon: Icons.inventory_2_rounded,
      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      route: AppRoutes.unitInventory,
      permissionKey: 'unit_inventory_stock',
      actionPermissionKey: 'unit_inventory_stock',
      subActions: [
        GridSubAction(
          title: 'Store Inventory',
          icon: Icons.store,
          route: AppRoutes.storeInventory,
          permissionKey: 'store_inventory_stock',
        ),
        GridSubAction(
          title: 'Consumption',
          icon: Icons.restaurant,
          route: AppRoutes.allConsumption,
          permissionKey: 'consumption_report',
        ),
        GridSubAction(
          title: 'Allotments',
          icon: Icons.receipt_long,
          route: AppRoutes.allotments,
          permissionKey: 'allotments_report',
        ),
        GridSubAction(
          title: 'Measurements',
          icon: Icons.straighten,
          route: AppRoutes.measurements,
          permissionKey: 'measurements_panel',
        ),
        GridSubAction(
          title: 'Items',
          icon: Icons.category,
          route: AppRoutes.items,
          permissionKey: 'inventory_item',
        ),
        GridSubAction(
          title: 'Store',
          icon: Icons.storefront,
          route: AppRoutes.storeRooms,
          permissionKey: 'store_room',
        ),
      ],
    ),
    GridItemData(
      title: 'Attendance',
      subtitle: 'Team attendance',
      icon: Icons.people_alt_rounded,
      gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
      route: AppRoutes.staffTracking,
      permissionKey: 'tracking_panel',
      subActions: [
        GridSubAction(
          title: 'Log',
          icon: Icons.assignment_rounded,
          route: AppRoutes.attendanceLog,
          permissionKey: 'Attendance_Log',
        ),
      ],
    ),
    GridItemData(
      title: 'Collection',
      headerTitle: 'Collections',
      subtitle: 'Manage collections',
      icon: Icons.account_balance_wallet_rounded,
      gradient: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
      route: AppRoutes.adminCollections,
      permissionKey: 'collection_panel',
      subActions: [
        GridSubAction(
          title: 'Collections',
          icon: Icons.payments,
          route: AppRoutes.collections,
          permissionKey: 'normal_admin_collection',
        ),
        GridSubAction(
          title: 'Deposits',
          icon: Icons.account_balance,
          route: AppRoutes.deposits,
          permissionKey: 'deposit_panel',
        ),
      ],
    ),
    GridItemData(
      title: 'Contacts',
      headerTitle: 'Info Directory',
      subtitle: 'Contacts & brands',
      icon: Icons.contact_phone_rounded,
      gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      route: AppRoutes.infoDirectory,
      permissionKey: 'c_directory_panel',
      subActions: [
        GridSubAction(
          title: 'Assets & Products',
          icon: Icons.inventory,
          route: AppRoutes.assetsProducts,
          permissionKey: 'Asset_Panel',
        ),
        GridSubAction(
          title: 'Account Details',
          icon: Icons.account_box,
          route: AppRoutes.accountSubscription,
          permissionKey: 'Account_subscription_panel',
        ),
        GridSubAction(
          title: 'Brands',
          icon: Icons.branding_watermark,
          route: AppRoutes.contactBrands,
          permissionKey: 'brand_details',
        ),
        GridSubAction(
          title: 'Companies',
          icon: Icons.business,
          route: AppRoutes.contactCompanies,
          permissionKey: 'company_details',
        ),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initGridItems();
    ever(_authRepo.rxUserPermissions, (_) {
      _initGridItems();
    });
  }

  void _initGridItems() {
    final userPermissions = _authRepo.rxUserPermissions;

    // Filter items based on permissions
    final availableItems = <GridItemData>[];

    for (final item in _allItems) {
      if (item.title == 'Support Ticket') {
        if (userPermissions.contains('maintenance_panel')) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        }
      } else if (item.title == 'Daily Task') {
        if (userPermissions.contains('Task_Sheduler_Pannel') &&
            userPermissions.contains('Daily_Task')) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        }
      } else if (item.title == 'Unit Inventory') {
        if (userPermissions.contains('inventory_panel') &&
            userPermissions.contains('unit_inventory_stock')) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        } else if (userPermissions.contains('store_inventory_stock')) {
          availableItems.add(
            GridItemData(
              title: 'Store Inventory',
              subtitle: 'Manage Store',
              icon: Icons.store,
              gradient: item.gradient,
              route: AppRoutes.storeInventory,
              subActions: [],
            ),
          );
        } 
      } else if (item.title == 'Attendance') {
        if (userPermissions.contains('tracking_panel')) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        } else if (userPermissions.contains('Attendance_Log')) { 
          availableItems.add(
            GridItemData(
              title: 'Attendance Log',
              subtitle: 'View attendance records',
              icon: Icons.assignment_rounded,
              gradient: item.gradient,
              route: AppRoutes.attendanceLog,
              subActions: [],
            ),
          );
        }
      } else if (item.title == 'Collection') {
        if (userPermissions.contains('collection_panel')) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        } else if (userPermissions.contains('normal_admin_collection')) {
          availableItems.add(
            GridItemData(
              title: 'Collections',
              subtitle: 'Admin Collections',
              icon: Icons.payments,
              gradient: item.gradient,
              route: AppRoutes.collections,
              subActions: [],
            ),
          );
        } else if (userPermissions.contains('deposit_panel')) {
          availableItems.add(
            GridItemData(
              title: 'Deposits',
              subtitle: 'Admin Deposits',
              icon: Icons.account_balance,
              gradient: item.gradient,
              route: AppRoutes.deposits,
              subActions: [],
            ),
          );
        }
      } else if (item.title == 'Contacts') {
        if (userPermissions.contains('c_directory_panel')) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        } else if (userPermissions.contains('Asset_Panel')) {
          availableItems.add(
            GridItemData(
              title: 'Assets',
              subtitle: 'Manage Assets',
              icon: Icons.inventory,
              gradient: item.gradient,
              route: AppRoutes.infoDirectory,
              subActions: [],
            ),
          );
        } else if (userPermissions.contains('account_details')) {
          availableItems.add(
            GridItemData(
              title: 'Accounts',
              subtitle: 'Manage Accounts',
              icon: Icons.account_box,
              gradient: item.gradient,
              route: null,
              subActions: [],
            ),
          );
        }
      } else {
        // Fallback for any unknown items
        if (item.permissionKey == null ||
            userPermissions.contains(item.permissionKey)) {
          final sub = item.subActions
              .where(
                (s) =>
                    s.permissionKey == null ||
                    userPermissions.contains(s.permissionKey),
              )
              .toList();
          availableItems.add(item.copyWith(subActions: sub));
        }
      }
    }

    // Load advanced config
    final config = _storage.getHomeGridConfig();

    // Fallback to legacy order if config doesn't exist
    final legacyOrder = _storage.getHomeGridOrder();

    final savedOrder = config?['order'] as List<dynamic>? ?? legacyOrder;
    final savedSubActions = config?['subActions'] as Map<dynamic, dynamic>?;
    final savedHeaderTitles = config?['headerTitles'] as Map<dynamic, dynamic>?;

    final orderedItems = <GridItemData>[];

    if (savedOrder != null && savedOrder.isNotEmpty) {
      for (final title in savedOrder) {
        final index = availableItems.indexWhere((item) => item.title == title);
        if (index != -1) {
          orderedItems.add(availableItems[index]);
          availableItems.removeAt(index);
        }
      }
    }

    // Add any new items that weren't in the saved order to the end
    orderedItems.addAll(availableItems);

    // Apply sub-action filtering based on saved config
    for (int i = 0; i < orderedItems.length; i++) {
      final item = orderedItems[i];
      String? savedHeaderTitle = item.headerTitle;
      if (savedHeaderTitles != null &&
          savedHeaderTitles.containsKey(item.title)) {
        savedHeaderTitle = savedHeaderTitles[item.title] as String;
      }

      final originalSubs = [
        GridSubAction(
          title: item.title,
          icon: item.icon,
          route: item.route,
          permissionKey: item.actionPermissionKey ?? item.permissionKey,
        ),
        ...item.subActions,
      ];

      if (savedSubActions != null && savedSubActions.containsKey(item.title)) {
        final savedSubs = (savedSubActions[item.title] as List<dynamic>)
            .cast<String>();

        if (!savedSubs.contains(item.title)) {
          savedSubs.insert(0, item.title);
        }

        final filteredSubs = <GridSubAction>[];
        for (final savedTitle in savedSubs) {
          final found = originalSubs.firstWhereOrNull(
            (s) => s.title == savedTitle,
          );
          if (found != null) {
            filteredSubs.add(found);
          }
        }
        if (filteredSubs.length > 4) {
          filteredSubs.removeRange(4, filteredSubs.length);
        }
        orderedItems[i] = item.copyWith(
          subActions: filteredSubs,
          headerTitle: savedHeaderTitle,
        );
      } else {
        if (originalSubs.length > 4) {
          originalSubs.removeRange(4, originalSubs.length);
        }
        orderedItems[i] = item.copyWith(
          subActions: originalSubs,
          headerTitle: savedHeaderTitle,
        );
      }
    }

    gridItems.value = orderedItems;
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = gridItems.removeAt(oldIndex);
    gridItems.insert(newIndex, item);
    saveCurrentConfig();
  }

  void saveCurrentConfig() {
    final order = gridItems.map((e) => e.title).toList();
    final subActions = <String, List<String>>{};
    final headerTitles = <String, String>{};
    for (final item in gridItems) {
      subActions[item.title] = item.subActions.map((s) => s.title).toList();
      if (item.headerTitle != null) {
        headerTitles[item.title] = item.headerTitle!;
      }
    }
    _storage.saveHomeGridConfig({
      'order': order,
      'subActions': subActions,
      'headerTitles': headerTitles,
    });
  }

  List<GridSubAction> getAvailableSubActionsFor(String cardTitle) {
    final userPermissions = _authRepo.rxUserPermissions;
    final originalItem = _allItems.firstWhereOrNull(
      (e) => e.title == cardTitle,
    );
    if (originalItem == null) return [];

    final mainAction = GridSubAction(
      title: originalItem.title,
      icon: originalItem.icon,
      route: originalItem.route,
      permissionKey:
          originalItem.actionPermissionKey ?? originalItem.permissionKey,
    );

    final subs = originalItem.subActions
        .where(
          (s) =>
              s.permissionKey == null ||
              userPermissions.contains(s.permissionKey),
        )
        .toList();

    return [
      if (mainAction.permissionKey == null ||
          userPermissions.contains(mainAction.permissionKey))
        mainAction,
      ...subs,
    ];
  }

  void updateCardConfig(
    String cardTitle,
    List<GridSubAction> newSubs,
    String? newHeaderTitle,
  ) {
    final index = gridItems.indexWhere((e) => e.title == cardTitle);
    if (index != -1) {
      gridItems[index] = gridItems[index].copyWith(
        subActions: newSubs,
        headerTitle: newHeaderTitle,
      );
      saveCurrentConfig();
    }
  }

  bool hasPermission(String permissionKey) {
    return _authRepo.rxUserPermissions.contains(permissionKey);
  }
}
