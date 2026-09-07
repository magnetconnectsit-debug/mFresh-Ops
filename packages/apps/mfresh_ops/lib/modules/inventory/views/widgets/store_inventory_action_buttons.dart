import 'package:core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'store_inventory_dialogs.dart';

class StoreInventoryActionButtons extends StatelessWidget {
  const StoreInventoryActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canAddInventory = userPermissions.contains('add_inventory_stock');
      final canExport = userPermissions.contains('S_Inv_export');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      child: Row(
        children: [
          if (canAddInventory) ...[
            SizedBox(
              height: 24.h,
              child: ElevatedButton(
                onPressed: () => StoreInventoryDialogs.showAddInventorySheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A3B8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  elevation: 1,
                ),
                child: Text('Add Inventory', style: AppTextStyle.style_12_500(color: Colors.white)),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          if (canExport) ...[
            SizedBox(
              height: 24.h,
              child: ElevatedButton(
                onPressed: () => controller.exportToExcel(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF389D6A), // Match the greenish color in screenshot
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  elevation: 1,
                ),
                child: Text('Export Excel', style: AppTextStyle.style_12_500(color: Colors.white)),
              ),
            ),
          ],
          const Spacer(),
          Container(
            height: 24.h,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.itemsPerPage.value,
                icon: Icon(Icons.arrow_drop_down, size: 16.r),
                isDense: true,
                style: AppTextStyle.style_12_500(color: AppColors.black),
                items: const [10, 25, 50, 100].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val per page'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.setItemsPerPage(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
    });
  }
}
