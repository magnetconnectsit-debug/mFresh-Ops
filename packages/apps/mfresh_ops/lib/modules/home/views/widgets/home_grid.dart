import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:mfresh_ops/modules/home/controllers/home_grid_controller.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeGridController());

    return Obx(() {
      final items = controller.gridItems;

      return ReorderableGridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        onReorder: controller.onReorder,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.r,
          mainAxisSpacing: 8.r,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            key: ValueKey(item.title),
            child: _buildGridCard(item, controller),
          );
        },
      );
    });
  }

  Widget _buildGridCard(GridItemData item, HomeGridController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFff895b),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title Pill
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      if (item.route != null) {
                        Get.toNamed(item.route!);
                      } else {
                        AppCommonToastMessage.show(
                          message: '${item.title} is coming soon....',
                          type: ToastType.info,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 10.w,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: AppTextStyle.style_14_600(
                            color: AppColors.black,
                          ).copyWith(fontSize: 13.5.sp),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Icon Pills
                if (item.subActions.isNotEmpty)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < item.subActions.length; i++) ...[
                          if (i > 0) SizedBox(width: 8.w),
                          Builder(
                            builder: (context) {
                              final action = item.subActions[i];
                              return Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: () {
                                      if (action.route != null) {
                                        Get.toNamed(
                                          action.route!,
                                          arguments: action.arguments,
                                        );
                                      } else if (item.route != null) {
                                        Get.toNamed(item.route!);
                                      } else {
                                        AppCommonToastMessage.show(
                                          message:
                                              '${action.title} is coming soon....',
                                          type: ToastType.info,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 6.h,
                                        horizontal: 4.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBEBEB),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          action.isSolidIcon
                                              ? Container(
                                                  padding: EdgeInsets.all(2.r),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF4A4A4A,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Icon(
                                                    action.icon,
                                                    color: Colors.white,
                                                    size: 16.r,
                                                  ),
                                                )
                                              : Icon(
                                                  action.icon,
                                                  color: AppColors.black,
                                                  size: 20.r,
                                                ),
                                          SizedBox(height: 2.h),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              action.title,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyle.style_10_500(
                                                color: AppColors.grey700,
                                              ).copyWith(fontSize: 9.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        if (item.subActions.length == 1) ...[
                          SizedBox(width: 8.w),
                          const Expanded(child: SizedBox()),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
