import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/inventory_audit_controller.dart';
import 'widgets/audit_filter_widget.dart';
import 'widgets/audit_table_widget.dart';
import 'package:core/widgets/app_common_search_bar.dart';

class InventoryAuditScreen extends StatefulWidget {
  const InventoryAuditScreen({super.key});

  @override
  State<InventoryAuditScreen> createState() => _InventoryAuditScreenState();
}

class _InventoryAuditScreenState extends State<InventoryAuditScreen> {
  late final InventoryAuditController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryAuditController());
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
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search Item or Category...',
                  onChanged: (v) => controller.searchQuery.value = v,
                )
              : Text(
                  'Inventory Audit',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuditFilterWidget(),
            SizedBox(height: 12.h),
            const Flexible(child: AuditTableWidget()),
            SizedBox(height: 25.h)
          ],
        ),
      ),
    );
  }
}
