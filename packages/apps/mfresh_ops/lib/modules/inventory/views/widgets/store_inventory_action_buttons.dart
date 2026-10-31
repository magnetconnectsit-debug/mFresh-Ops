// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'store_inventory_dialogs.dart';
import 'store_required_orders_dialog.dart';
// endregion

// region View Definition
class StoreInventoryActionButtons extends StatelessWidget {
  // region Constructor
  const StoreInventoryActionButtons({super.key});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canAddInventory = userPermissions.contains('add_inventory_stock');
      final canExport = userPermissions.contains('S_Inv_export');
      final canRequestOrder = userPermissions.contains('Inv_Store_Order');

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
        child: Row(
          children: [
            if (canAddInventory) ...[
              AppCommonButton(
                text: 'Inventory',
                icon: Icons.add,
                height: 24.h,
                borderRadius: 4.r,
                textSize: 10.sp,
                buttonColor: AppColors.info,
                onPressed: () => _handleAddInventory(context),
              ),
              SizedBox(width: 4.w),
            ],
            if (canExport) ...[
              AppCommonExportButton(
                onExportExcel: () => controller.exportToExcel(),
              ),
              SizedBox(width: 4.w),
            ],
            if (canRequestOrder) ...[
              AppCommonButton(
                text: 'Request Orders',
                height: 24.h,
                borderRadius: 4.r,
                textSize: 10.sp,
                buttonColor: const Color(0xFF6F42C1),
                onPressed: () => _handleRequestOrders(context),
              ),
              SizedBox(width: 4.w),
            ],
            const Spacer(),
            _buildPaginationDropdown(controller),
          ],
        ),
      );
    });
  }
  // endregion

  // region Section Builders
  Widget _buildPaginationDropdown(InventoryController controller) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: controller.itemsPerPage.value,
          icon: Icon(Icons.arrow_drop_down, size: 14.r, color: AppColors.black),
          isDense: true,
          padding: EdgeInsets.zero,
          style: AppTextStyle.style_10_500(color: AppColors.black),
          items: const [10, 25, 50, 100].map((int val) {
            return DropdownMenuItem<int>(
              value: val,
              child: Text('$val / page'),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              controller.setItemsPerPage(val);
            }
          },
        ),
      ),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  void _handleAddInventory(BuildContext context) {
    final authRepo = Get.find<AuthRepository>();
    if (!authRepo.rxUserPermissions.contains('add_inventory_stock')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to add inventory stock.',
        type: ToastType.warning,
      );
      return;
    }
    StoreInventoryDialogs.showAddInventorySheet(context);
  }

  void _handleRequestOrders(BuildContext context) {
    final authRepo = Get.find<AuthRepository>();
    if (!authRepo.rxUserPermissions.contains('Inv_Store_Order')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to request store orders.',
        type: ToastType.warning,
      );
      return;
    }
    StoreRequiredOrdersDialog.show(context: context);
  }
  // endregion
}
// endregion
