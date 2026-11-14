// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/service_details/controllers/service_details_controller.dart';
// endregion

// region ServiceCard Class
class ServiceCard extends StatelessWidget {
  // region Dependencies & Fields
  final ServiceDetailsController controller;
  final int index;
  // endregion

  // region Constructor
  const ServiceCard({super.key, required this.controller, required this.index});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final service = controller.services[index];
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8.w : 6.w,
        vertical: isTablet ? 4.h : 2.h,
      ),
      decoration: AppColors.appCardDecoration(
        borderColor: AppColors.grey100,
        containerColor: AppColors.white,
        borderRadius: isTablet ? 10 : 12,
        isShadow: true,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImageView(
            imageUrl: service.image,
            height: isTablet ? 48.r : 50.w,
            width: isTablet ? 48.r : 50.w,
            borderRadius: isTablet ? 8.r : 10.r,
            fit: BoxFit.contain,
            backgroundColor: AppColors.aliceBlue,
          ),
          SizedBox(width: isTablet ? 8.w : 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isTablet
                      ? AppTextStyle.style_12_600(color: AppColors.black)
                      : AppTextStyle.style_11_500(color: AppColors.black),
                ),
                SizedBox(height: isTablet ? 2.h : 2.h),
                Row(
                  children: [
                    Text(
                      '₹ ${service.price}',
                      style: isTablet
                          ? AppTextStyle.style_12_700(color: AppColors.black)
                          : AppTextStyle.style_10_600(color: AppColors.black),
                    ),
                    Text(
                      ' / use',
                      style: isTablet
                          ? AppTextStyle.style_11_500(color: AppColors.grey500)
                          : AppTextStyle.style_10_500(color: AppColors.grey300),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 4.h : 4.h),
                // Compact Counter
                Obx(() {
                  final bool isAdded = service.quantity.value > 0;
                  final Color themeColor = AppColors.pineBlue;
                  return Container(
                    height: isTablet ? 26.h : 28.h,
                    decoration: BoxDecoration(
                      color: isAdded ? themeColor : AppColors.white,
                      border: Border.all(color: themeColor, width: 1.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.decrement(index),
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: isTablet ? 17.sp : 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isAdded
                                      ? AppColors.white
                                      : AppColors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${service.quantity.value}',
                          style: isTablet
                              ? AppTextStyle.style_12_700(
                                  color: isAdded
                                      ? AppColors.white
                                      : AppColors.black,
                                )
                              : AppTextStyle.style_12_700(
                                  color: isAdded
                                      ? AppColors.white
                                      : AppColors.black,
                                ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.increment(index),
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              child: Text(
                                '+',
                                style: TextStyle(
                                  fontSize: isTablet ? 17.sp : 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isAdded
                                      ? AppColors.white
                                      : AppColors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
    // endregion
  }

  // endregion
}
