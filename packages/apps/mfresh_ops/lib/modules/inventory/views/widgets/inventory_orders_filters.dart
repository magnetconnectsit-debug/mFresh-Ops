import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import '../../controllers/inventory_orders_controller.dart';

class InventoryOrdersFilters extends StatelessWidget {
  const InventoryOrdersFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryOrdersController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Obx(() {
        final summary = controller.summary.value;
        final selected = controller.selectedFilter.value;

        return Row(
          children: [
            Expanded(
              child: _buildFilterBtn(
                label: 'Pending',
                count: summary.pending,
                isSelected: selected == InventoryOrderStatusFilter.pending,
                onTap: () => controller.setFilter(
                  selected == InventoryOrderStatusFilter.pending
                      ? InventoryOrderStatusFilter.all
                      : InventoryOrderStatusFilter.pending,
                ),
                color: const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildFilterBtn(
                label: 'Waiting',
                count: summary.waitingForReceive,
                isSelected: selected == InventoryOrderStatusFilter.waitingForReceive,
                onTap: () => controller.setFilter(
                  selected == InventoryOrderStatusFilter.waitingForReceive
                      ? InventoryOrderStatusFilter.all
                      : InventoryOrderStatusFilter.waitingForReceive,
                ),
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildFilterBtn(
                label: 'Completed',
                count: summary.completed,
                isSelected: selected == InventoryOrderStatusFilter.completed,
                onTap: () => controller.setFilter(
                  selected == InventoryOrderStatusFilter.completed
                      ? InventoryOrderStatusFilter.all
                      : InventoryOrderStatusFilter.completed,
                ),
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBtn({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: AppTextStyle.style_10_600(
                  color: isSelected ? Colors.white : AppColors.black,
                ).copyWith(fontSize: 9.sp),
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              width: 16.r,
              height: 16.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : color,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: AppTextStyle.style_10_700(
                  color: Colors.white,
                ).copyWith(fontSize: 9.sp, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
