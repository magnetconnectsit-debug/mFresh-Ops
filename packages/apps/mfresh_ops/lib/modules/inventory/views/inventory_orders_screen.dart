import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import '../controllers/inventory_orders_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'widgets/inventory_orders_filters.dart';
import 'widgets/inventory_orders_table.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class InventoryOrdersScreen extends StatefulWidget {
  const InventoryOrdersScreen({super.key});

  @override
  State<InventoryOrdersScreen> createState() => _InventoryOrdersScreenState();
}

class _InventoryOrdersScreenState extends State<InventoryOrdersScreen> {
  late final InventoryOrdersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryOrdersController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Obx(() {
          return controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search order or item...',
                  onChanged: (v) => controller.allOrders.refresh(),
                )
              : Text(
                  'Inventory Orders',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                );
        }),
        actions: [
          Obx(() => IconButton(
                onPressed: () => controller.toggleSearch(),
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                ),
              )),
        ],
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const InventoryOrdersFilters(),
              SizedBox(height: 8.h),
              const InventoryOrdersTable(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
