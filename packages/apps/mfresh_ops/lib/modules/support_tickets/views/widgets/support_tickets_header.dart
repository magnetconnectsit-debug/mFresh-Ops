// region SupportTicketsHeader
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';

class SupportTicketsHeader extends StatelessWidget {
  final SupportTicketsController controller;
  final bool showSkeleton;
  final bool canViewFilter;

  const SupportTicketsHeader({
    super.key,
    required this.controller,
    required this.showSkeleton,
    required this.canViewFilter,
  });

  // region build
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Skeletonizer(
                enabled: showSkeleton,
                child: Obx(
                  () => Text(
                    "Total Tickets: ${controller.totalTickets.value}",
                    style: AppTextStyle.style_14_600(color: AppColors.grey900),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Obx(() {
          if (controller.unitCounts.isEmpty && !showSkeleton) {
            return const SizedBox.shrink();
          }
          return Skeletonizer(
            enabled: showSkeleton,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    (showSkeleton
                            ? List.generate(5, (index) => "Unit - 0")
                            : (() {
                                final list = controller.unitCounts.toList();
                                list.sort(
                                  (a, b) => (b.totalTickets).compareTo(
                                    a.totalTickets,
                                  ),
                                );
                                return list
                                    .map((e) => "${e.unit} - ${e.totalTickets}")
                                    .toList();
                              })())
                        .asMap()
                        .entries
                        .map((entry) {
                          int index = entry.key;
                          String label = entry.value;
                          Color color = [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.orange,
                            Colors.teal,
                          ][index % 5];
                          return Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          );
                        })
                        .toList(),
              ),
            ),
          );
        }),
      ],
    );
  }
  // endregion
}
// endregion