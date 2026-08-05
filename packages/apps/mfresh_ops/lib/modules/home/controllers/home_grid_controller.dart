import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:services/storage_service.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

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
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? route;
  final String? permissionKey;
  final String? actionPermissionKey;
  final List<GridSubAction> subActions;

  GridItemData({
    required this.title,
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

  final List<GridItemData> _allItems = [
    GridItemData(
      title: 'Support Ticket',
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
      subtitle: 'Stock & Items',
      icon: Icons.inventory_2_rounded,
      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      route: AppRoutes.unitInventory,
      permissionKey: 'unit_inventory_stock',
      actionPermissionKey: 'unit_inventory_stock',
      subActions: [
        GridSubAction(
          title: 'Add',
          icon: Icons.add,
          isSolidIcon: true,
          route: AppRoutes.storeInventory,
          arguments: const {'openAddDialog': true},
          permissionKey: 'add_inventory_stock',
        ),
        GridSubAction(
          title: 'Store',
          icon: Icons.store,
          route: AppRoutes.storeInventory,
          permissionKey: 'store_inventory_stock',
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
        GridSubAction(title: 'Tracking', icon: Icons.format_list_bulleted),
      ],
    ),
    GridItemData(
      title: 'Admin',
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
      title: 'Info Directory',
      subtitle: 'Contacts & brands',
      icon: Icons.contact_phone_rounded,
      gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      route: AppRoutes.infoDirectory,
      permissionKey: 'c_directory_panel',
      subActions: [
        GridSubAction(
          title: 'Assets',
          icon: Icons.inventory,
          route: AppRoutes.assetsProducts,
          permissionKey: 'Asset_Panel',
        ),
        GridSubAction(
          title: 'Accounts',
          icon: Icons.account_box,
          route: AppRoutes.accountSubscription,
          permissionKey: 'Account_subscription_panel',
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
          availableItems.add(item);
        }
      } else if (item.title == 'Admin') {
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
      } else if (item.title == 'Info Directory') {
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

    // Load saved order
    final savedOrder = _storage.getHomeGridOrder();

    if (savedOrder != null && savedOrder.isNotEmpty) {
      // Reorder available items based on saved string titles
      final orderedItems = <GridItemData>[];

      for (final title in savedOrder) {
        final index = availableItems.indexWhere((item) => item.title == title);
        if (index != -1) {
          orderedItems.add(availableItems[index]);
          availableItems.removeAt(index);
        }
      }

      // Add any new items that weren't in the saved order to the end
      orderedItems.addAll(availableItems);
      gridItems.value = orderedItems;
    } else {
      // No saved order, use default
      gridItems.value = availableItems;
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    // ReorderableGridView already handles newIndex > oldIndex internally properly usually,
    // but standard Flutter ReorderableListView needs this:
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = gridItems.removeAt(oldIndex);
    gridItems.insert(newIndex, item);

    // Save new order to storage
    final newOrder = gridItems.map((e) => e.title).toList();
    _storage.saveHomeGridOrder(newOrder);
  }

  bool hasPermission(String permissionKey) {
    return _authRepo.rxUserPermissions.contains(permissionKey);
  }
}
